module AhnRiemann
  class ConfigGenerator < Adhearsion::Generators::Generator
    argument :environments, :type => :array, :default => ["development"]

    def self.source_root
      File.join(File.dirname(File.expand_path(__FILE__)), "config/templates")
    end

    def server_config
      @base_config = {}
      say("Riemann server base config:", Thor::Shell::Color::GREEN)
      @base_config["host"] = ask("Host ? [defaults to localhost]")
      @base_config["host"] = "localhost" if @base_config["host"].empty?

      @base_config["port"] = ask("Port ? [defaults to 5555]")
      @base_config["port"] = "5555" if @base_config["port"].empty?
      
      @base_config["origin_host"] = ask("Origin host ? [defaults to #{Socket.gethostname}]")
      @base_config["origin_host"] = Socket.gethostname if @base_config["origin_host"].empty?
      
      @config = {}

      @environments.each do |env|
        @config[env] = {}
      
        say("Riemann server '#{env}' config:", Thor::Shell::Color::GREEN)

        host = ask("Host (#{env})? [defaults to #{@base_config["host"]}]")
        @config[env]["host"] = host unless host.empty?

        port = ask("Port (#{env})? [defaults to #{@base_config["port"]}]")
        @config[env]["port"] = port unless port.empty?
      
        origin_host = ask("Origin host ? [defaults to #{@base_config["origin_host"]}]")
        @config[env]["origin_host"] = origin_host unless origin_host.empty?
      end
    end
    
    def ask_events_config
      event_handlers = {
        "error_trace" => {
          "state" => "critical",
          "service" => "ivr-notify"
        },
        "punchblock_connection" => {
          "service" => "ivr-notify",
          "state" => :unused
        },
        "active_calls" => {
          "service" => "ivr-notify",
          "state" => :unused
        }
      }

      @events_config = {}
      event_handlers.each_pair do |event_name, config|
        say("Riemann '#{event_name}' event configuration:", Thor::Shell::Color::GREEN)

        @events_config[event_name] = {}
        
        unless config['service'] == :unused
          input_service = ask("Service name [defaults to '#{config['service']}']:")
          @events_config[event_name]["service"] = input_service.empty? ? config['service'] : input_service
        end

        unless config['state'] == :unused
          input_state = ask("Event state [defaults to '#{config['state']}']:")
          @events_config[event_name]["state"] = input_state.empty? ? config['state'] : input_state
        end

        unless config['tag'] == :unused
          input_tag = ask("Event tag [defaults to '#{event_name}']:")
          @events_config[event_name]["tag"] = input_tag.empty? ? event_name : input_tag
        end
      end
    end

    def gen_config
      self.destination_root = Adhearsion.config.platform.root
      
      template "config/riemann.yml"
    end

  end
end
