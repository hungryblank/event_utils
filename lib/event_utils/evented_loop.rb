module EventUtils

  class DeferredChildFailure < StandardError
  end

  class DeferredLoop

      def self.main_loop
        @main_loop ||= new(:main)
      end


    attr_accessor :success, :failure

    include EM::Deferrable

    def initialize(main=false)
      self.class.main_loop.wait_for(self) unless main
      @success, @failure = 0, 0
      @waiting_for = []
    end

    #takes a list of deferrables to wait for before executing the callback
    def waiting_for(*deferrables, &block)
      deferrables.each { |d| wait_for(d) }.size
      callback  { block.call } if block_given?
      errback { raise DeferredChildFailure, "#{failure} deferred entities failed" }
      self
    end

    #callback used by deferrables the loop is waiting for, it increases failure or
    #success depending by the child outcome
    def child_returned(outcome)
      send(outcome.to_s + '=', send(outcome) + 1)
      terminate if complete?
    end

    #add a deferrable to the list of deferrables to wait for
    def wait_for(deferrable)
      @waiting_for << deferrable
      deferrable.callback { self.child_returned :success }
      deferrable.errback { self.child_returned :failure }
    end

    private

    def complete?
      @waiting_for.size == success + failure
    end

    #sets the deferred status depending by outcomes of children
    #it fails if one or more children failed
    def terminate
      failure == 0 ? self.succeed : self.fail
    end

  end

  #Wraps the clode in the provided block in an EM loop if needed
  #
  #  in_deferred_loop do
  #    your code using deferrables here
  #  end
  #
  def in_deferred_loop(&block)
    drive_reactor = !EM.reactor_running?
    if drive_reactor
      EM.run do
        DeferredLoop.main_loop.callback { EM.stop }
        DeferredLoop.main_loop.errback { EM.stop }
        yield
      end
    else
      yield
    end
  end

  #waits until all the deferrables have the deferred status set and then
  #executes the code in the provided block
  #
  #  in_deferred_loop do
  #    waiting_for deferrable_1, deferrable_2, ..., deferrable_n do
  #      code that needs all the deferrable deferred status set here
  #    end
  #  end
  #
  def waiting_for(*deferrables, &block)
    deferred_loop = DeferredLoop.new
    deferred_loop.waiting_for(*deferrables, &block)
    deferred_loop
  end

end
