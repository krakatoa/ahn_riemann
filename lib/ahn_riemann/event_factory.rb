module AhnRiemann
  class EventFactory
    @@event_factory = nil
    
    def initialize(origin_host, environment)
      @origin_host = origin_host
      @environment = environment
    end

    def params_for(service_name)
      service_config = @@adhearsion_config[service_name]
      
      service = service_config[:service] rescue nil
      state = service_config[:state] rescue nil
      tag = service_config[:tag] rescue nil
      return { :service => service, :state => state, :tag => tag }
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

    def error_event(params)
      merge_basic_params!(params)
      params.merge!(params_for(:error_trace))
      ErrorEvent.new(params)
    end

    def active_calls_event(params)
      merge_basic_params!(params)
      params.merge!(params_for(:active_calls))
      ActiveCallsEvent.new(params)
    end

    def punchblock_connection_event(params)
      merge_basic_params!(params)
      params.merge!(params_for(:punchblock_connection))
      PunchblockConnectionEvent.new(params)
    end

    def actors_count_event(params)
      merge_basic_params!(params)
      params.merge!(params_for(:actors_count))
      ActorsCountEvent.new(params)
    end

    def threads_count_event(params)
      merge_basic_params!(params)
      params.merge!(params_for(:threads_count))
      ThreadsCountEvent.new(params)
    end
    
    def self.init(config)
      host = Adhearsion.config.riemann.origin_host
      environment = Adhearsion.config.platform.environment.to_s
      @@event_factory = EventFactory.new(host, environment)
      @@adhearsion_config = config
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
