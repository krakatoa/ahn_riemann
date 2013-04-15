require "riemann/client"

module AhnRiemann
  class Plugin < Adhearsion::Plugin
    # Actions to perform when the plugin is loaded
    #
    init :ahn_riemann do
      logger.warn "Ahn-Riemann has been loaded"

      Events.register_callback(:exception) do |e, logger|
        logger.warn "" 
      end
    end

    # Basic configuration for the plugin
    #
    config :ahn_riemann do
      greeting "Hello", :desc => "What to use to greet users"
    end

    # Defining a Rake task is easy
    # The following can be invoked with:
    #   rake plugin_demo:info
    #
    tasks do
      namespace :ahn_riemann do
        desc "Prints the PluginTemplate information"
        task :info do
          STDOUT.puts "Ahn-Riemann plugin v. #{VERSION}"
        end
      end
    end

  end
end
