#!/usr/bin/env ruby

require 'test/unit'
require './clock'

class TestClock < Test::Unit::TestCase

  def create_clock
    Clock.new
  end
  
  def test_initially_not_fixed
    clock = create_clock
    assert_equal(false, clock.time_fixed?)
  end

  def test_time_can_be_fixed
    clock = create_clock
    clock.with_fixed_time do
      assert_equal(true, clock.time_fixed?)
    end
    assert_equal(false, clock.time_fixed?)
  end

  def test_unfixed_time_after_nested_fixed_time
    clock = create_clock
    clock.with_fixed_time do
      assert_equal(true, clock.time_fixed?)
      clock.with_fixed_time do
        assert_equal(true, clock.time_fixed?)
      end
      assert_equal(true, clock.time_fixed?)
    end
    assert_equal(false, clock.time_fixed?)
  end

  def test_initially_running
    clock = create_clock
    assert_equal(false, clock.paused?)
  end

  def test_can_pause
    clock = create_clock
    clock.pause
    assert_equal(true, clock.paused?)
  end

  def test_can_not_pause_when_paused
    clock = create_clock
    clock.pause
    assert_raise(ClockPausedError) { clock.pause }
  end

  def test_can_resume
    clock = create_clock
    clock.pause
    clock.resume
    assert_equal(false, clock.paused?)
  end

  def test_can_resume_with_system_time
    clock = create_clock
    clock.pause
    clock.resume_with_system_time
    assert_equal(false, clock.paused?)
  end

  def test_can_not_resume_when_running
    clock = create_clock
    assert_raise(ClockNotPausedError) { clock.resume }
    assert_raise(ClockNotPausedError) { clock.resume_with_system_time }
  end

  def test_can_travel_to_future
    clock = create_clock
    clock.pause
    paused_time = clock.now
    clock.travel(60)
    assert_equal(paused_time + 60, clock.now)
  end
	
  def test_can_travel_to_the_past
    clock = create_clock
    clock.pause
    paused_time = clock.now
    clock.travel(-60)
    assert_equal(paused_time - 60, clock.now)
  end

  def test_can_travel_to_the_past
    clock = create_clock
    clock.pause
    paused_time = clock.now
    clock.travel(-60)
    assert_equal(paused_time - 60, clock.now)
  end

  def test_can_travel_to_absolute_time
    clock = create_clock
    clock.pause
    paused_time = clock.now
    clock.travel_to(paused_time + 60)
    assert_equal(paused_time + 60, clock.now)
  end

  def test_can_not_travel_when_running
    clock = create_clock
    assert_raise(ClockNotPausedError) { clock.travel(100) }
    assert_raise(ClockNotPausedError) { clock.travel(-100) }
    assert_raise(ClockNotPausedError) { clock.travel_to(Time.now) }
  end

end
