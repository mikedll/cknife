module CKnife
  class Config
    def self.config
      return @config if @config

      @config = {
        :key => ENV["KEY"] || ENV['AMAZON_ACCESS_KEY_ID'],
        :secret => ENV["SECRET"] || ENV['AMAZON_SECRET_ACCESS_KEY']
      }

      config_file = nil
      Pathname.new(Dir.getwd).tap do |here|
        config_file = [["cknife.yml"], ["tmp", "cknife.yml"]].map { |args|
          here.join(*args)
        }.select { |path|
          File.exists?(path)
        }.first
      end

      if config_file
        begin
          @config.merge!(YAML.load(config_file.read).symbolize_keys!)
        rescue
          say ("Found, but could not parse config: #{config_file}")
        end
      end

      @config
    end

    def self.[](s)
      get(s)
    end

    def self.get(path)
      cur = config
      path.to_s.split('.').each do |segment|
        cur = cur[segment.force_encoding('UTF-8').to_s] if cur
      end

      # retry, this time with env prefix.
      if cur.nil?
        cur = config[Rails.env]
        path.to_s.split('.').each do |segment|
          cur = cur[segment.force_encoding('UTF-8').to_s] if cur
        end
      end

      if cur.nil?
        cur = ENV[path]
      end

      cur
    end

  end
end