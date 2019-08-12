RSpec.describe Myscheduler do
  let(:cal) { Myscheduler::Calendar.new }
  let(:event_4) { Myscheduler::Event.new(4, Time.parse('2019-01-02 10:00'), Time.parse('2019-01-02 11:00')) }
  let(:event_5) { Myscheduler::Event.new(5, Time.parse('2019-01-02 09:30'), Time.parse('2019-01-02 11:30')) }
  let(:event_6) { Myscheduler::Event.new(6, Time.parse('2019-01-02 08:30'), Time.parse('2019-01-02 12:30')) }
  let(:expected_result) do
    [{ "2019-01-02 09:30:00 +0700 - 2019-01-02 10:00:00 +0700": [6, 5] },
     { "2019-01-02 10:00:00 +0700 - 2019-01-02 11:00:00 +0700": [6, 5, 4] },
     { "2019-01-02 11:00:00 +0700 - 2019-01-02 11:30:00 +0700": [6, 5] }]
  end

  describe 'Output the example' do
    context 'when events are conflicted' do
      it do
        cal.schedule event_4, event_5, event_6
        expect(cal.find_conflicted_time_windows).to eq expected_result
      end
    end
  end
end
