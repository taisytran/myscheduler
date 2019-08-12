module Myscheduler
  class Calendar
    def initialize
      @scheduled_events = []
      @events = []
    end

    def schedule(*args)
      timelapse = []
      # TODO: raise error if args not event object

      @events << args
      @events.flatten!

      # format to timelapse
      timelapse = @events.map(&:begin_time) + @events.map(&:end_time)
      timelapse.sort!

      @scheduled_events = []
      timelapse.each_cons(2) do |begin_time, next_time|
        # get all events in the period (begin_time to next_time)
        ev_period = proc { |ev| ev.period?(begin_time, next_time) }
        ev_ids = @events.sort_by(&:begin_time).select(&ev_period).map(&:id)
        next if ev_ids.empty? # next if no any event in this period

        @scheduled_events << { "#{begin_time} - #{next_time}": ev_ids }
      end

      @scheduled_events
    end

    def find_conflicted_time_windows
      return unless @scheduled_events

      # filter the overlaped event and not conflicted event in the period from scheduler
      ev_overlaped_ids = Event.overlaps.map(&:id)
      with_conflict = proc do |scheduler|
        ev_ids = scheduler.values.flatten
        ev_ids.all? { |id| ev_overlaped_ids.include?(id) } && !ev_ids.one?
      end

      @scheduled_events.select(&with_conflict)
    end
  end
end
