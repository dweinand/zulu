require "slop"
require "rack"
require "reel"
require "redis"
require "celluloid/redis"

require "zulu/version"
require "zulu/server"
require "zulu/subscription_request"

module Zulu
  DEFAULTS = {
    port: 9292,
    host: "0.0.0.0",
    servers: 0,
    workers: 5,
    database: "redis://127.0.0.1:6379",
    keeper: false
  }
  
  def self.options
    @options ||= DEFAULTS.dup
  end
  
  def self.options=(opts)
    @options = opts
  end

  def self.parse_options(args=ARGV)
    banner = "Zulu #{Zulu::VERSION}\nUsage: zulu [options]"
    opts = Slop.parse args, strict: true, help: true, banner: banner do
      on :v, :version, 'Print the version' do
        puts "Version #{Zulu::VERSION}"
      end
        
      on :p, :port, 'Use PORT (default: 9292)', argument: true, as: Integer
      on :o, :host, 'Listen on HOST (default: 0.0.0.0)', argument: true
      on :s, :servers, 'Run SERVERS server workers (default: 0)', argument: true, as: Integer
      on :w, :workers, 'Run WORKERS background workers (default: 5)', argument: true, as: Integer
      on :d, :database, "Connect to DATABASE (default: redis://127.0.0.1:6379)", argument: true
      on :k, :keeper, "Run a keeper worker (default: false)"
    end
    opts.each do |option|
      next unless option.value
      option.value.is_a?(String) and option.value.strip!
      options[option.key.to_sym] = option.value
    end
  rescue Slop::Error => e
    abort "ERROR: #{e.message}"
  end
  
  def self.run
    if options[:servers] > 0
      run_servers
    end
  end
  
  def self.run_servers
    Rack::Handler::Reel.run Zulu::Server, port: options[:port],
                                          host: options[:host],
                                          workers: options[:servers]
  end
  
  def self.redis
    Thread.current[:redis] ||= Redis.new(url: options[:database], driver: :celluloid)
  end
  
end
