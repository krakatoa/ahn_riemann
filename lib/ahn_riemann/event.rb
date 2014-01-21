module AhnRiemann
  class Event
    def initialize(params)
      @environment = params[:environment]
      @host = params[:host]
      @service = params[:service]
      @state = params[:state]
      @tags = [params[:tag], @environment]
      @description = ""
    end
    
    def to_msg
      {
        :host => @host,
        :tags => @tags,
        :service => @service,
        :metric => @metric,
        :state => @state,
        :description => @description
      }
    end
  end

  class ErrorEvent < AhnRiemann::Event
    def initialize(params)
      super(params)
      @metric = 1
      @tags << params[:tag] if params[:tag]
      @description = params[:description]
    end
  end

  class ActiveCallsEvent < AhnRiemann::Event
    def initialize(params)
      super(params)
      @metric = params[:active_calls]
      @description = params[:description]
    end
  end

  class PunchblockConnectionEvent < AhnRiemann::Event
    def initialize(params)
      super(params)
      @state = params[:status]
      @metric = 1
    end
  end

  class ActorsCountEvent < AhnRiemann::Event
    def initialize(params)
      super(params)
      @metric = params[:actors_count]
    end
  end

  class ThreadsCountEvent < AhnRiemann::Event
    def initialize(params)
      super(params)
      @metric = params[:threads_count]
    end
  end
end
