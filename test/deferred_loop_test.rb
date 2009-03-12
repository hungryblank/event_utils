require 'test_helper'

include EventUtils

class DeferredLoopTest < Test::Unit::TestCase

  should "add callback end errback to deferrables it's waiting for" do
    deferrable = Mocha::Mock.new
    deferrable.expects(:callback)
    deferrable.expects(:errback)
    deferred_loop = DeferredLoop.new
    deferred_loop.wait_for deferrable
  end

  should "evaluate completion on child returned" do
    deferred_loop = DeferredLoop.new
    deferred_loop.expects(:complete?)
    deferred_loop.child_returned(:success)
  end

  should "complete when number of success + failures equal waiting for" do
    deferred_loop = DeferredLoop.new
    deferred_loop.instance_variable_set('@waiting_for', [1, 2, 3])
    deferred_loop.success = 2
    assert !deferred_loop.send(:complete?)
    deferred_loop.failure = 1
    assert deferred_loop.send(:complete?)
  end

  should "increase success and failure on child_returned" do
    deferred_loop = DeferredLoop.new
    success, failure = deferred_loop.success, deferred_loop.failure
    deferred_loop.child_returned(:success)
    assert_equal success + 1, deferred_loop.success
    assert_equal failure, deferred_loop.failure
    deferred_loop.child_returned(:failure)
    assert_equal failure + 1, deferred_loop.failure
  end

  should "fail if there are failures" do
    deferred_loop = DeferredLoop.new
    deferred_loop.instance_variable_set('@waiting_for', [1])
    deferred_loop.child_returned(:failure)
    deferred_loop.expects(:fail)
    deferred_loop.send(:terminate)
  end

  should "succeed if there aren't failures" do
    deferred_loop = DeferredLoop.new
    deferred_loop.instance_variable_set('@waiting_for', [1])
    deferred_loop.child_returned(:success)
    deferred_loop.expects(:succeed)
    deferred_loop.send(:terminate)
  end

  should "add callback to main loop when EM reactor is not running" do
    EM.expects(:run)
    main_loop = Mocha::Mock.new
    DeferredLoop.stubs(:main_loop).returns(main_loop)
    main_loop.expects(:callback)
    in_deferred_loop {}
  end

  should "wait for all the deferrables passed to waiting for" do
    EM.stubs(:reactor_running?).returns(true)
    ev_loop = DeferredLoop.new
    a = 1
    b = 2
    ev_loop.expects(:wait_for).with(a)
    ev_loop.expects(:wait_for).with(b)
    ev_loop.waiting_for a, b
  end

  should "instantiate a new loop on class waiting_for" do
    a = b = nil
    l = lambda { 'bla' }
    deferred_loop = Mocha::Mock.new
    DeferredLoop.expects(:new).returns(deferred_loop)
    deferred_loop.expects(:waiting_for).with(a, b, l)
    EventUtils.waiting_for(a, b, l)
  end

end
