module AhnRiemann
  class ConfigGenerator < Adhearsion::Generators::Generator
    argument :environments, :type => :array, :default => ["development"]

    def self.source_root
      File.join(File.dirname(File.expand_path(__FILE__)), "config/templates")
    end

    def load_config
      @config = {}
      @environments.each do |env|
        @config[env] = {}
        @config[env]["host"] = ask("Riemann server host (#{env})? [defaults to localhost]")
        @config[env]["host"] = "localhost" if @config[env]["host"].empty?

        @config[env]["port"] = ask("Riemann server port (#{env})? [defaults to 5555]")
        @config[env]["port"] = "5555" if @config[env]["port"].empty?
      end
    end

    def gen_config
      self.destination_root = Adhearsion.config.platform.root
      
      template "config/riemann.yml"
    end

  end
end
