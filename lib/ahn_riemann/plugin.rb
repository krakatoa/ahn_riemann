require "ahn_riemann/generators/config_generator"

require "riemann/client"

module AhnRiemann
  class Plugin < Adhearsion::Plugin

    @@riemann_client = nil
    @@scheduler = nil

    # Actions to perform when the plugin is loaded
    #
    init :ahn_riemann do
      AhnRiemann::EventFactory.init(event_factory_config)
      
      @@scheduler = AhnRiemann::Scheduler.new
      @@scheduler.every(5) {
        stats = Adhearsion.statistics.as_json.select {|key| ["calls_offered", "calls_rejected", "calls_routed", "calls_dialed"].include?(key)}.dup
        ahn_stats = {
          :offered => stats["calls_offered"],
          :routed => stats["calls_routed"],
          :rejected => stats["calls_rejected"],
          :dialed => stats["calls_dialed"]
        }

        msg = AhnRiemann::EventFactory.active_calls_msg(
          :active_calls => Adhearsion.active_calls.count,
          :description => ahn_stats.to_s
        )
        @@riemann_client << msg
      }
      @@scheduler.async.run

      @@riemann_client = Riemann::Client.new(:host => Adhearsion.config.riemann.host, :port => Adhearsion.config.riemann.port)
      logger.warn "Ahn-Riemann client connected to #{Adhearsion.config.riemann.host}:#{Adhearsion.config.riemann.port}"

      Adhearsion::Events.register_callback(:shutdown) do |e, logger|
        msg = AhnRiemann::EventFactory.punchblock_connection_msg(:status => "shutdown")
        @@scheduler.terminate
        @@riemann_client << msg
      end

      Adhearsion::Events.register_callback(:punchblock) do |e, logger|
        msg = AhnRiemann::EventFactory.punchblock_connection_msg(:status => "connected")
        @@riemann_client << msg
      end
    end

    # Basic configuration for the plugin
    #
    config :riemann do

      riemann_config = YAML::load_file(File.join(Dir.getwd, "config/riemann.yml")) rescue {}
      server_config = riemann_config[Adhearsion.config.platform.environment.to_s] rescue nil

      if not server_config
        $stdout.puts "Ahn-Riemann config file is missing. Please create one by running 'bundle exec ahn generate riemann_plugin:config'"
      else

        host server_config["host"]
        port server_config["port"]
        origin_host server_config["origin_host"]

        events_config = riemann_config["events"]
        error_trace {
          service events_config["error_trace"]["service"]
          state events_config["error_trace"]["state"]
          tag events_config["error_trace"]["tag"]
        }

        punchblock_connection {
          service events_config["punchblock_connection"]["service"]
          tag events_config["punchblock_connection"]["tag"]
        }

        if events_config["active_calls"]
          active_calls {
            service events_config["active_calls"]["service"]
            tag events_config["active_calls"]["tag"]
          }
        end

      end

    end

    tasks do
      namespace :riemann do
        desc "Prints the PluginTemplate information"
        task :info do
          # STDOUT.puts "Riemann config: #{host}, #{port}"
        end
      end
    end

    generators :"riemann_plugin:config" => AhnRiemann::ConfigGenerator

    def self.event_factory_config
      {
        :host => Adhearsion.config.riemann.origin_host,
        :environment => Adhearsion.config.platform.environment.to_s,
        :error_params => {
          :service => Adhearsion.config.riemann.error_trace.service,
          :state => Adhearsion.config.riemann.error_trace.state,
          :tag => Adhearsion.config.riemann.error_trace.tag
        },
        :active_calls_params => {
          :service => Adhearsion.config.riemann.active_calls.service,
          :tag => Adhearsion.config.riemann.active_calls.tag
        },
        :punchblock_connection_params => {
          :service => Adhearsion.config.riemann.punchblock_connection.service,
          :tag => Adhearsion.config.riemann.punchblock_connection.tag
        }
      }
    end

    def self.catching_errors(extra_data={}, &block)
      block.call
    rescue Adhearsion::Call::Hangup
      raise Adhearsion::Call::Hangup
    rescue Exception => e
      # Use any object that responds to to_hash, so it can be a static or a dynamic generated hash
      AhnRiemann::Plugin.deliver_exception(e, extra_data.to_hash)
    end

    def self.deliver_exception(e, extra_data)
      body = []
      body << "Exception: #{e.class}"
      body << "Description: #{e.message}"

      extra_data.each_pair do |key, value|
        key = key.to_s.split("_").collect{|w| w.capitalize}.join(" ")
        body << "#{key}: #{value}"
      end
      body << "Backtrace:\n#{e.backtrace.join("\n")}"

      msg = AhnRiemann::EventFactory.error_msg(:description => body.join("\n\n"))

      @@riemann_client << msg
    end

  end
end
