
#!/usr/bin/env ruby

ENV['BUNDLE_GEMFILE'] = File.join( File.dirname( File.expand_path( __FILE__ ) ),  "Gemfile" )

require 'rubygems'
require 'bundler'
Bundler.require

require 'active_support/all'
require 'zlib'
require 'digest/md5'

class Aws < Thor

  KEY = ENV["KEY"] || ENV['AMAZON_ACCESS_KEY_ID']
  SECRET = ENV["SECRET"] || ENV['AMAZON_SECRET_ACCESS_KEY']

  no_tasks do

    def fog_opts
      opts = {
        :provider => 'AWS',
        :aws_access_key_id => KEY,
        :aws_secret_access_key => SECRET
      }      
      opts.merge!({ :region => options[:region] }) if !options[:region].blank?
      opts
    end

    def fog_storage
      @storage ||= Fog::Storage.new(fog_opts)
    end

    def fog_compute
      @compute ||= Fog::Compute.new(fog_opts)
    end

    def fog_cdn
      @cdn ||= Fog::CDN.new(fog_opts)
    end

    def show_buckets
      fog_storage.directories.sort { |a,b| a.key <=> b.key }.each { |b| puts "#{b.key}" }
    end

    def show_servers
      fog_compute.servers.sort { |a,b| a.key_name <=> b.key_name }.each do |s|
        puts "#{s.tags['Name']} (state: #{s.state}): id=#{s.id} keyname=#{s.key_name} dns=#{s.dns_name} flavor=#{s.flavor_id}"
      end
    end
    
    def show_cdns
      puts fog_cdn.get_distribution_list.body['DistributionSummary'].to_yaml
    end

    def with_bucket(bucket_name)
      d = fog_storage.directories.select { |d| d.key == bucket_name }.first
      if d.nil?
        say ("Could not find bucket with name #{bucket_name}")
        return
      end

      say ("Found bucket named #{bucket_name}")
      yield d
    end

    def fog_key_for(target_root, file_path)
      target_root_path_length ||= target_root.to_s.length + "/".length
      relative = file_path[ target_root_path_length, file_path.length]
      relative
    end

    def content_hash(s)
      Digest::MD5.hexdigest(s)
    end

  end

  desc "list_servers", "Show all servers"
  def list_servers
    show_servers
  end

  desc "start_server [SERVER_ID]", "Start a given EC2 server"
  def start_server(server_id)
    s = fog_compute.servers.select { |s| s.id == server_id}.first
    if s
      say("found server. starting/resuming. #{s.id}")
      s.start
      show_servers
    else
      say("no server with that id found. nothing done.")
    end
  end

  desc "stop_server [SERVER_ID]", "Stop a given EC2 server (does not terminate it)"
  def stop_server(server_id)
    s = fog_compute.servers.select { |s| s.id == server_id}.first
    if s
      say("found server. stopping. #{s.id}")
      s.stop
    else
      say("no server with that id found. nothing done.")
    end
  end

  desc "list_cloudfront", "List cloudfront distributions (CDNs)"
  def list_cloudfront
    show_cdns
  end

  desc "create_cloudfront [BUCKET_NAME]", "Create a cloudfront distribution (a CDN)"
  def create_cloudfront(bucket_id)
    fog_cdn.post_distribution({
                            'S3Origin' => {
                              'DNSName' => "#{bucket_id}.s3.amazonaws.com"
                            },
                            'Enabled' => true
                          })

    show_cdns
  end

  desc "list", "Show all buckets"
  method_options :region => "us-west-1"
  def list
    show_buckets
  end

  desc "afew [BUCKET_NAME]", "Show first 5 files in bucket"
  method_options :count => "5"
  def afew(bucket_name)
    d = fog_storage.directories.select { |d| d.key == bucket_name }.first
    if d.nil?
      say ("Found no bucket by name #{bucket_name}")
      return
    end

    i = 0
    d.files.each do |s3_file|
      break if i >= options[:count].to_i
      say("#{s3_file.key}")
      i += 1
    end
  end
  
  desc "download [BUCKET_NAME]", "Show files in  bucket"
  method_options :region => "us-west-1"
  def download(bucket_name)
    with_bucket bucket_name do |d|
      if yes?("Are you sure you want to download all files into the CWD?", :red)
        d.files.each do |s3_file|
          say ("Creating path for and downloading #{s3_file.key}")
          dir_path = Pathname.new(s3_file.key).dirname
          dir_path.mkpath
          File.open(s3_file.key, "w") do |f|
            f.write s3_file.body
          end
        end
      else
        say ("No action taken.")
      end
    end
  end

  desc "upsync [BUCKET_NAME] [DIRECTORY]", "Push local files matching glob PATTERN into bucket. Ignore unchanged files."
  method_options :public => false
  method_options :region => "us-west-1"
  method_options :noprompt => nil
  def upsync(bucket_name, directory)
    if !File.exists?(directory) || !File.directory?(directory)
      say("'#{directory} does not exist or is not a directory.")
      return
    end

    target_root = Pathname.new(directory)

    files = Dir.glob(target_root.join("**", "*")).select { |f| !File.directory?(f) }.map(&:to_s)
    if files.count == 0
      say("No files to upload.")
      return
    end

    say("Found #{files.count} candidate file upload(s).")

    sn = un = cn = 0
    with_bucket bucket_name do |d|
      if (options[:noprompt] == nil) && yes?("Proceed?", :red)
        files.each do |to_upload|
          k = fog_key_for(target_root, to_upload)

          existing = d.files.get(k)
          if existing && existing.etag != content_hash(File.read(to_upload))
            existing.body = File.open(to_upload)
            existing.save
            un += 1
          elsif existing.nil?
            file = d.files.create(
                                  :key    => k,
                                  :body   => File.open(to_upload),
                                  :public => options[:public]
                                  )
            cn += 1
          else
            sn += 1
            # skipped
          end
          say("#{to_upload}")          
        end
      else
        say ("No action taken.")
      end
    end
    say("Done. #{cn} created. #{un} updated. #{sn} skipped.")
  end


  desc "delete [BUCKET_NAME]", "Destroy a bucket"
  method_options :region => "us-west-1"
  def delete(bucket_name)
    d = fog_storage.directories.select { |d| d.key == bucket_name }.first

    if d.nil?
      say ("Found no bucket by name #{bucket_name}")
      return
    end

    if d.files.length > 0
      say "Bucket has #{d.files.length} files. Please empty before destroying."
      return
    end

    if yes?("Are you sure you want to delete this bucket #{d.key}?", :red)
      d.destroy
      say "Destroyed bucket named #{bucket_name}."
      show_buckets
    else
      say "No action taken."
    end

  end

  desc "create [BUCKET_NAME]", "Create a bucket"
  method_options :region => "us-west-1"
  def create(bucket_name = nil)
    if !bucket_name
      puts "No bucket name given." 
      return
    end

    fog_storage.directories.create(
                                   :key => bucket_name,
                                   :location => options[:region]
                                   )

    puts "Created bucket #{bucket_name}."
    show_buckets
  end

  desc "show [BUCKET_NAME]", "Show info about bucket"
  method_options :region => "us-west-1"
  def show(bucket_name = nil)
    if !bucket_name
      puts "No bucket name given." 
      return
    end

    with_bucket(bucket_name) do |d|
      say "#{d}: "
      say d.location
    end
  end

end

Aws.start
