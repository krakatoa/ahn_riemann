require "celluloid"
require "timers"

module AhnRiemann
  class Scheduler
    include Celluloid

    def initialize
      @timers = Timers.new
    end

    def every(seconds, &block)
      @timers.every(seconds, &block)
    end

    def pause
      @timers.pause
    end

    def continue
      @timers.continue
    end

    def run
      loop { @timers.wait }
    end
  end
end
