#!/usr/bin/env ruby

class ClockNotPausedError < StandardError
  def initialize
    super("Clock not paused")
  end
end

class ClockPausedError < StandardError
  def initialize
    super("Clock paused")
  end
end

class Clock

  def initialize
    @offset = nil
    @paused_at = nil
    @fixed_time = nil
  end

  def now
    if not(@fixed_time.nil?)
      @fixed_time
    elsif not(@offset.nil?)
      Time.now + @offset
    else
      Time.now
    end
  end

  def with_fixed_time(&block)
    if time_fixed?
      block.call
    else
      @fixed_time = self.now
      begin
        block.call
      ensure
        if not(paused?)
          @fixed_time = nil
        end
      end
    end
  end

  def paused?
    return not(@paused_at.nil?)
  end

  def time_fixed?
    return not(@fixed_time.nil?)
  end

  def pause
    if paused?
      raise ClockPausedError.new
    end
    @paused_at = self.now
    @fixed_time = @paused_at
    @offset = nil
  end

  def resume
    must_be_paused
    @offset = @paused_at - Time.now
    @paused_at = nil
    @fixed_time = nil
  end

  def resume_with_system_time
    must_be_paused
    @offset = nil
    @paused_at = nil
    @fixed_time = nil 
 end

  def travel_to(new_current_time)
    must_be_paused
    @paused_at = new_current_time
    @fixed_time = @paused_at
  end

  def travel(seconds_change)
    must_be_paused
    @paused_at += seconds_change
    @fixed_time = @paused_at
  end

  private

  def must_be_paused
    if not(is_paused?)
      raise ClockNotPausedError.new
    end
  end
end
