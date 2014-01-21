module AhnRiemann
  class EventFactory
    @@event_factory = nil
    
    def initialize(origin_host, environment)
      @origin_host = origin_host
      @environment = environment

      @error_params = {}
      @active_calls_params = {}
      @punchblock_connection_params = {}
      @actors_count_params = {}
      @threads_count_params = {}
    end

    def error_params=(params)
      @error_params[:service] = params[:service]
      @error_params[:state] = params[:state]
      @error_params[:tag] = params[:tag]
    end

    def active_calls_params=(params)
      @active_calls_params[:service] = params[:service]
      @active_calls_params[:tag] = params[:tag]
    end

    def punchblock_connection_params=(params)
      @punchblock_connection_params[:service] = params[:service]
      @punchblock_connection_params[:tag] = params[:tag]
    end

    def actors_count_params=(params)
      @actors_count_params[:service] = params[:service]
      @actors_count_params[:tag] = params[:tag]
    end

    def threads_count_params=(params)
      @threads_count_params[:service] = params[:service]
      @threads_count_params[:tag] = params[:tag]
    end

    def basic_params
      {
        :host => @origin_host,
        :environment => @environment
      }
    end

    def merge_basic_params!(params={})
      params.merge!(basic_params)
    end

    def merge_error_params!(params={})
      params.merge!(@error_params)
    end

    def merge_active_calls_params!(params={})
      params.merge!(@active_calls_params)
    end

    def merge_punchblock_connection_params!(params={})
      params.merge!(@punchblock_connection_params)
    end

    def merge_actors_count_params!(params={})
      params.merge!(@actors_count_params)
    end

    def merge_threads_count_params!(params={})
      params.merge!(@threads_count_params)
    end

    def error_event(params)
      merge_basic_params!(params)
      merge_error_params!(params)
      ErrorEvent.new(params)
    end

    def active_calls_event(params)
      merge_basic_params!(params)
      merge_active_calls_params!(params)
      ActiveCallsEvent.new(params)
    end

    def punchblock_connection_event(params)
      merge_basic_params!(params)
      merge_punchblock_connection_params!(params)
      PunchblockConnectionEvent.new(params)
    end

    def actors_count_event(params)
      merge_basic_params!(params)
      merge_actors_count_params!(params)
      ActorsCountEvent.new(params)
    end

    def threads_count_event(params)
      merge_basic_params!(params)
      merge_threads_count_params!(params)
      ThreadsCountEvent.new(params)
    end
    
    def self.init(config)
      # TODO Remove this! this should not initialize a hash with all the config,
      # it should simply read from the Adhearsion.config.riemann object all the params!
      @@event_factory = EventFactory.new(config[:host], config[:environment])
      @@event_factory.error_params = config[:error_params]
      @@event_factory.active_calls_params = config[:active_calls_params]
      @@event_factory.punchblock_connection_params = config[:punchblock_connection_params]
      @@event_factory.actors_count_params = config[:actors_count_params]
      @@event_factory.threads_count_params = config[:threads_count_params]
    end
    
    def self.error_msg(params)
      @@event_factory.error_event(params).to_msg
    end

    def self.active_calls_msg(params)
      @@event_factory.active_calls_event(params).to_msg
    end

    def self.punchblock_connection_msg(params)
      @@event_factory.punchblock_connection_event(params).to_msg
    end

    def self.actors_count_msg(params)
      @@event_factory.actors_count_event(params).to_msg
    end

    def self.threads_count_msg(params)
      @@event_factory.threads_count_event(params).to_msg
    end
    
  end
end
