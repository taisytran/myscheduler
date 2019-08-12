RSpec.describe Myscheduler::Calendar do
  let(:cal) { Myscheduler::Calendar.new }
  let(:event_4) { Myscheduler::Event.new(4, Time.parse('2019-01-02 10:00'), Time.parse('2019-01-02 11:00')) }
  let(:event_5) { Myscheduler::Event.new(5, Time.parse('2019-01-02 09:30'), Time.parse('2019-01-02 11:30')) }
  let(:event_6) { Myscheduler::Event.new(6, Time.parse('2019-01-02 08:30'), Time.parse('2019-01-02 12:30')) }

  context '#schedule' do
    it do
      scheduler_events = cal.schedule event_4, event_5, event_6

      expected_result = [{ "2019-01-02 08:30:00 +0700 - 2019-01-02 09:30:00 +0700": [6] },
                         { "2019-01-02 09:30:00 +0700 - 2019-01-02 10:00:00 +0700": [6, 5] },
                         { "2019-01-02 10:00:00 +0700 - 2019-01-02 11:00:00 +0700": [6, 5, 4] },
                         { "2019-01-02 11:00:00 +0700 - 2019-01-02 11:30:00 +0700": [6, 5] },
                         { "2019-01-02 11:30:00 +0700 - 2019-01-02 12:30:00 +0700": [6] }]
      expect(scheduler_events).to eq expected_result
    end
  end

  context '#find_conflicted_time_windows' do
    context 'all events are conflicted' do
      let(:event_7) { Myscheduler::Event.new(7, Time.parse('2019-01-02 06:00'), Time.parse('2019-01-02 9:00')) }
      it do
        cal.schedule event_4, event_5, event_6, event_7

        expected_result = [{ "2019-01-02 08:30:00 +0700 - 2019-01-02 09:00:00 +0700": [7, 6] },
                           { "2019-01-02 09:30:00 +0700 - 2019-01-02 10:00:00 +0700": [6, 5] },
                           { "2019-01-02 10:00:00 +0700 - 2019-01-02 11:00:00 +0700": [6, 5, 4] },
                           { "2019-01-02 11:00:00 +0700 - 2019-01-02 11:30:00 +0700": [6, 5] }]
        expect(cal.find_conflicted_time_windows).to eq expected_result
      end
    end

    context 'one event that is not conflicted' do
      let(:event_7) { Myscheduler::Event.new(7, Time.parse('2019-01-02 06:00'), Time.parse('2019-01-02 7:00')) }
      it do
        cal.schedule event_4, event_5, event_6, event_7

        expected_result = [{ "2019-01-02 09:30:00 +0700 - 2019-01-02 10:00:00 +0700": [6, 5] },
                           { "2019-01-02 10:00:00 +0700 - 2019-01-02 11:00:00 +0700": [6, 5, 4] },
                           { "2019-01-02 11:00:00 +0700 - 2019-01-02 11:30:00 +0700": [6, 5] }]

        expect(cal.find_conflicted_time_windows).to eq expected_result
      end
    end
  end
end
