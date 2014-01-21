require "ahn_riemann/generators/config_generator"

require "riemann/client"

module AhnRiemann
  class Plugin < Adhearsion::Plugin

    generators :"riemann_plugin:config" => AhnRiemann::ConfigGenerator

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

        if events_config["actors_count"]
          actors_count {
            service events_config["actors_count"]["service"]
            tag events_config["actors_count"]["tag"]
          }
        end

        if events_config["threads_count"]
          threads_count {
            service events_config["threads_count"]["service"]
            tag events_config["threads_count"]["tag"]
          }
        end

      end

    end

    @@riemann_client = nil
    @@scheduler = nil

    # Actions to perform when the plugin is loaded
    #
    init :ahn_riemann do
      AhnRiemann::EventFactory.init(Adhearsion.config.riemann.to_hash)
      
      @@riemann_client = Riemann::Client.new(:host => Adhearsion.config.riemann.host, :port => Adhearsion.config.riemann.port)
      logger.warn "Ahn-Riemann client connected to #{Adhearsion.config.riemann.host}:#{Adhearsion.config.riemann.port}"
    end

    run :ahn_riemann do
      register_punchblock_connection_events
      register_active_calls_events
    end

    def self.register_punchblock_connection_events
      Adhearsion::Events.register_callback(:punchblock) do |e, logger|
        if (e.is_a? Punchblock::Connection::Connected)
          msg = AhnRiemann::EventFactory.punchblock_connection_msg(:status => "connected")
          @@riemann_client << msg
        end
      end

      Adhearsion::Events.register_callback(:shutdown) do |e, logger|
        msg = AhnRiemann::EventFactory.punchblock_connection_msg(:status => "shutdown")
        @@scheduler.terminate if @@scheduler
        @@riemann_client << msg
      end
    end

    def self.register_active_calls_events
      @@scheduler = AhnRiemann::Scheduler.new
      @@scheduler.every(5) {
        stats = Adhearsion.statistics.dump.call_counts rescue {}
        active_calls_count = stats.delete(:active)

        msg = AhnRiemann::EventFactory.active_calls_msg(
          :active_calls => active_calls_count,
          :description => stats.to_s
        )
        @@riemann_client << msg
      }
      @@scheduler.every(5) {
        msg = AhnRiemann::EventFactory.actors_count_msg(
          :actors_count => Celluloid::Actor.all.size
        )
        @@riemann_client << msg
      }
      @@scheduler.every(5) {
        msg = AhnRiemann::EventFactory.threads_count_msg(
          :threads_count => Thread.list.count
        )
        @@riemann_client << msg
      }
      @@scheduler.async.run
    end


    def self.catching_errors(extra_data={}, &block)
      block.call
    rescue Adhearsion::Call::Hangup
      raise Adhearsion::Call::Hangup
    rescue Exception => e
      # Use any object that responds to to_hash, so it can be a static or a dynamic generated hash
      AhnRiemann::Plugin.deliver_exception(e, extra_data.to_hash)
      raise e
    end

    def self.deliver_exception(e, extra_data)
      body = []
      body << "Exception: #{e.class}"
      body << "Description: #{e.message}"

      extra_data.each_pair do |key, value|
        key = key.to_s.split("_").collect{|w| w.capitalize}.join(" ")
        body << "#{key}: #{value}"
      end
      body << "Backtrace:\n#{e.backtrace.join("\n") rescue "empty"}"

      msg = AhnRiemann::EventFactory.error_msg(:description => body.join("\n\n"))

      @@riemann_client << msg
    end
    
    tasks do
      namespace :riemann do
        desc "Prints the PluginTemplate information"
        task :info do
          # STDOUT.puts "Riemann config: #{host}, #{port}"
        end
      end
    end

  end
end
