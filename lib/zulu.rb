require "slop"
require "rack"
require "reel"
require "redis"
require "celluloid/redis"
require "logger"

require "zulu/version"
require "zulu/challenge"
require "zulu/http"
require "zulu/keeper"
require "zulu/server"
require "zulu/subscription"
require "zulu/subscription_request"
require "zulu/subscription_request_processor"
require "zulu/topic"
require "zulu/topic_distribution"

module Zulu
  DEFAULTS = {
    port: 9292,
    host: "0.0.0.0",
    servers: 0,
    workers: 5,
    database: "redis://127.0.0.1:6379",
    keeper: false,
    interval: 5
  }.freeze
  
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
      on :i, :interval, 'Check time every INTERVAL seconds (default: 5)', argument: true, as: Integer
    end
    opts.each do |option|
      next unless option.value
      value = option.value
      value = value.strip if value.is_a?(String)
      options[option.key.to_sym] = value
    end
  rescue Slop::Error => e
    abort "ERROR: #{e.message}"
  end
  
  def self.run
    run_keeper  if options[:keeper]
    run_workers if options[:workers] > 0
    run_servers if options[:servers] > 0
    sleep
  rescue Interrupt
    stop
  end
  
  def self.stop
    stop_keeper  if options[:keeper]
    stop_servers if options[:servers] > 0
    stop_workers if options[:workers] > 0
    exit
  end
  
  def self.run_keeper
    Keeper.supervise_as :keeper
    Celluloid::Actor[:keeper].async.start
  end
  
  def self.stop_keeper
    Celluloid::Actor[:keeper].terminate if Celluloid::Actor[:worker_supervisor]
  end
  
  def self.run_servers
    Rack::Handler::Reel.run Zulu::Server, port: options[:port],
                                          host: options[:host],
                                          workers: options[:servers]
  end
  
  def self.stop_servers
    Celluloid::Actor[:reel_server].terminate if Celluloid::Actor[:reel_server]
    Celluloid::Actor[:reel_rack_pool].terminate if Celluloid::Actor[:reel_rack_pool]
  end
  
  def self.run_workers
    Celluloid::Actor[:worker_supervisor] = Celluloid::SupervisionGroup.run!
    Celluloid::Actor[:worker_supervisor].pool(SubscriptionRequestProcessor,
                            as: :request_processors,
                            size: options[:workers])
    Celluloid::Actor[:request_processors].async.process
  end
  
  def self.stop_workers
    Celluloid::Actor[:worker_supervisor].terminate if Celluloid::Actor[:worker_supervisor]
  end
  
  def self.redis
    Thread.current[:redis] ||= Redis.new(url: options[:database], driver: :celluloid)
  end
  
end
