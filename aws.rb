
#!/usr/bin/env ruby

ENV['BUNDLE_GEMFILE'] = File.join( File.dirname( File.expand_path( __FILE__ ) ),  "Gemfile" )

require 'rubygems'
require 'bundler'
Bundler.require

require 'active_support/all'

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
    end

    def fog_storage
      @storage ||= Fog::Storage.new(fog_opts)
    end

    def fog_compute
      @compute ||= Fog::Compute.new(fog_opts)
    end

    def show_buckets
      fog_storage.directories.sort { |a,b| a.key <=> b.key }.each { |b| puts "#{b.key}" }
    end

    def show_servers
      fog_compute.servers.sort { |a,b| a.key_name <=> b.key_name }.each do |s|
        puts "#{s.tags['Name']} (state: #{s.state}): id=#{s.id} keyname=#{s.key_name} dns=#{s.dns_name} flavor=#{s.flavor_id}"
      end
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

  desc "list", "Show all buckets"
  def list
    show_buckets
  end

  desc "afew [BUCKET_NAME]", "Show first 5 files in bucket"
  def afew(bucket_name)
    d = fog_storage.directories.select { |d| d.key == bucket_name }.first
    if d.nil?
      say ("Found no bucket by name #{bucket_name}")
      return
    end

    i = 0
    d.files.each do |s3_file|
      break if i >= 5
      say("#{s3_file.key}")
      i += 1
    end
  end

  desc "download [BUCKET_NAME]", "Show files in  bucket"
  def download(bucket_name)
    d = fog_storage.directories.select { |d| d.key == bucket_name }.first
    if d.nil?
      say ("Found no bucket by name #{bucket_name}")
      return
    end

    if yes?("Found bucket. Are you sure you want to download all files into the CWD?", :red)
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


  desc "delete [BUCKET_NAME]", "Show all buckets"
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
  def create(bucket_name = nil)
    if !bucket_name
      puts "No bucket name given." 
      return
    end

    fog_storage.directories.create(:key => bucket_name)

    puts "Created bucket #{bucket_name}."
    show_buckets
  end

end

Aws.start
