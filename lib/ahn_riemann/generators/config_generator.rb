module AhnRiemann
  class ConfigGenerator < Adhearsion::Generators::Generator
    argument :host, :type => :string, :default => "localhost"
    argument :port, :type => :numeric, :default => 5555

    def gen_config
      self.destination_root = Adhearsion.config.platform.root
      #template File.join(File.dirname(__FILE__), "config/templates/config/riemann.yml"), "config/riemann.yml"
      template "config/riemann.yml, "config/riemann.yml"
    end
  end
end
