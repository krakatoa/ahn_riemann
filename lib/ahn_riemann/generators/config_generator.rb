module AhnRiemann
  class ConfigGenerator < Adhearsion::Generators::Generator
    argument :host, :type => :string, :default => "localhost"
    argument :port, :type => :numeric, :default => 5555

    def gen_config
      self.destination_root = Adhearsion.config.platform.root
      AhnRiemann::ConfigGenerator.source_root File.join(File.dirname(File.expand_path(__FILE__)), "config/templates")
      
      template "config/riemann.yml"
    end
  end
end
