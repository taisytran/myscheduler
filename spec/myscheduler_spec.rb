RSpec.describe Myscheduler do
  class Calendar
    def initialize
      @scheduled_events = []
    end

    def schedule(*args)
      events = []
      timelapse = []
      # TODO: raise error if args not event object

      events << args
      events.flatten!
      
      # format to timelapse
      timelapse = events.map(&:begin_time) + events.map(&:end_time)
      timelapse.sort!

      @scheduled_events = [] # refresh if schedule method used many times
      timelapse.each_cons(2) do |begin_time, next_time|
        # get all events in the period (begin_time to next_time)
        ev_period = proc { |ev| ev.period?(begin_time, next_time) }
        ev_ids = events.sort_by(&:begin_time).select(&ev_period).map(&:id)
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

    def overlaps?(ev)
      begin_time <= ev.end_time && ev.begin_time <= end_time
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

        overlaps.flatten.uniq { |ev| ev.id }
      end
    end

    # TODO: validate id unique
    # TODO: validate end_time >= begin_time
  end

  describe 'Event' do
    context 'mass assignment' do
      it do
        ev = Event.new(1, Time.now, Time.now + 86400)
        expect(ev.id).to eq 1
        expect(Event.all.count).to eq 1
      end
    end
  end

  describe 'Calendar' do
    let(:cal) { Calendar.new }
    let(:event_4) { Event.new(4, Time.parse('2019-01-02 10:00'), Time.parse('2019-01-02 11:00')) }
    let(:event_5) { Event.new(5, Time.parse('2019-01-02 09:30'), Time.parse('2019-01-02 11:30')) }
    let(:event_6) { Event.new(6, Time.parse('2019-01-02 08:30'), Time.parse('2019-01-02 12:30')) }

    describe '#find_conflicted_time_windows' do
      context 'when input is same the example' do
        it do
          cal.schedule event_4, event_5, event_6
          
          result = [{:"2019-01-02 09:30:00 +0700 - 2019-01-02 10:00:00 +0700"=>[6, 5]},
          {:"2019-01-02 10:00:00 +0700 - 2019-01-02 11:00:00 +0700"=>[6, 5, 4]},
          {:"2019-01-02 11:00:00 +0700 - 2019-01-02 11:30:00 +0700"=>[6, 5]}]
          
          expect(cal.find_conflicted_time_windows).to eq result
        end
      end
      
      context 'when input contains a event without overlap' do
        let(:event_7) { Event.new(7, Time.parse('2019-01-02 06:00'), Time.parse('2019-01-02 7:00')) }
        it 'event 7 should not be conflicted' do
          cal.schedule event_4, event_5, event_6, event_7
          
          result = [{:"2019-01-02 09:30:00 +0700 - 2019-01-02 10:00:00 +0700"=>[6, 5]},
          {:"2019-01-02 10:00:00 +0700 - 2019-01-02 11:00:00 +0700"=>[6, 5, 4]},
          {:"2019-01-02 11:00:00 +0700 - 2019-01-02 11:30:00 +0700"=>[6, 5]}]
          
          expect(cal.find_conflicted_time_windows).to eq result
        end
      end

      context 'when input contains more a overlaped event' do
        let(:event_7) { Event.new(7, Time.parse('2019-01-02 06:00'), Time.parse('2019-01-02 9:00')) }
        it 'the timelapse 8:30 to 9:00 should be contained 2 events 7 and 6' do
          cal.schedule event_4, event_5, event_6, event_7
          
          result = [{:"2019-01-02 08:30:00 +0700 - 2019-01-02 09:00:00 +0700"=>[7, 6]},
                    {:"2019-01-02 09:30:00 +0700 - 2019-01-02 10:00:00 +0700"=>[6, 5]},
                    {:"2019-01-02 10:00:00 +0700 - 2019-01-02 11:00:00 +0700"=>[6, 5, 4]},
                    {:"2019-01-02 11:00:00 +0700 - 2019-01-02 11:30:00 +0700"=>[6, 5]}]
          expect(cal.find_conflicted_time_windows).to eq result
        end
      end
    end
  end
end
