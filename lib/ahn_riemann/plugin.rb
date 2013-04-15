require "ahn_riemann/generators/config_generator"

require "riemann/client"

module AhnRiemann
  class Plugin < Adhearsion::Plugin
    # Actions to perform when the plugin is loaded
    #
    init :ahn_riemann do
      rc = Riemann::Client.new(:host => "10.0.0.8", :port => 5555)
      logger.warn "Ahn-Riemann client connected"

      Adhearsion::Events.register_callback(:exception) do |e, logger|
        # logger.error "Sending message: " e.methods.sort

        body = []
        body << "Exception: #{e.class}"
        body << "Description: #{e.message}"
        body << "Backtrace:\n#{e.backtrace.join("\n")}"

        msg = {
          :service => "ivr-engine",
          :state => "critical",
          :description => body.join("\n\n"),
          :tags => ["call"],
          :metric => 1
        }

        rc << msg
      end
    end

    # Basic configuration for the plugin
    #
    config :riemann do
      # greeting "Hello", :desc => "What to use to greet users"
      file_config = YAML::load_file(File.join(Adhearsion.config.platform.root, "config/riemann.yml"))[Adhearsion.config.platform.environment.to_s] rescue {}
      
      host file_config["host"] || "localhost"
      port file_config["port"] || "5555"
    end

    tasks do
      namespace :riemann do
        desc "Prints the PluginTemplate information"
        task :gen_config do
          STDIN.flush

          STDOUT.puts "Riemann server host (defaults to localhost): "
          host = STDIN.gets.strip
          host = host.empty? ? "localhost" : host

          STDOUT.puts "Riemann server port (defaults to 5555): "
          port = STDIN.gets.strip
          port = port.empty? ? "5555" : port

          # STDOUT.puts "Riemann config: #{host}, #{port}"


          
        end
      end
    end

    generators :"riemann_plugin:config" => AhnRiemann::ConfigGenerator

  end
end
