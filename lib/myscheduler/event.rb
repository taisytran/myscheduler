module Myscheduler
  class Event
    @@all = []

    attr_accessor :id, :begin_time, :end_time

    def initialize(id, begin_time, end_time)
      @id = id
      @begin_time = begin_time
      @end_time = end_time

      @@all << self
    end

    def period?(begin_time, end_time)
      self.begin_time <= begin_time && end_time <= self.end_time
    end

    def overlaps?(event)
      begin_time <= event.end_time && event.begin_time <= end_time
    end

    class << self
      def all
        @@all
      end

      # get all event that are overlaped
      def overlaps
        overlaps = []

        @@all.each_cons(2) do |ev, next_ev|
          next unless ev.overlaps?(next_ev)

          overlaps << [ev, next_ev]
        end

        overlaps.flatten.uniq(&:id)
      end
    end
    # TODO: validate id unique
    # TODO: validate end_time >= begin_time
  end
end
