require "ahn_riemann/generators/config_generator"

require "riemann/client"

module AhnRiemann
  class Plugin < Adhearsion::Plugin
    
    # Actions to perform when the plugin is loaded
    #
    init :ahn_riemann do
      rc = Riemann::Client.new(:host => Adhearsion.config.riemann.host, :port => Adhearsion.config.riemann.port)
      logger.warn "Ahn-Riemann client connected to #{Adhearsion.config.riemann.host}:#{Adhearsion.config.riemann.port}"

      Adhearsion::Events.register_callback(:exception) do |e, logger|
        # logger.error "Sending message: " e.methods.sort

        body = []
        body << "Exception: #{e.class}"
        body << "Description: #{e.message}"
        body << "Backtrace:\n#{e.backtrace.join("\n")}"

        msg = {
          :service => Adhearsion.config.riemann.error_trace.service,
          :state => Adhearsion.config.riemann.error_trace.state,
          :description => body.join("\n\n"),
          :tags => [Adhearsion.config.riemann.error_trace.tag, Adhearsion.config.platform.environment.to_s],
          :metric => 1,
          :host => Adhearsion.config.riemann.origin_host
        }

        rc << msg
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

  end
end
