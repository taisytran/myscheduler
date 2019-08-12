RSpec.describe Myscheduler::Event do
  # begin time = now; end time = tomorrow
  let(:event_1) { Myscheduler::Event.new(1, Time.now, Time.now + 86_400) }
  # begin time = 2 days ago; end time = 2 next days
  let(:event_2) { Myscheduler::Event.new(2, Time.now - 172_800, Time.now + 172_800) }

  context '#all' do
    before do
      # init events
      event_1
      event_2
    end
    it do
      expect(Myscheduler::Event.all.size).to eq 2
      expect(Myscheduler::Event.all.include?(event_1)).to eq true
      expect(Myscheduler::Event.all.include?(event_2)).to eq true
    end
  end

  context '#overlaps' do
    before do
      # init events
      event_1
      event_2
    end
    it 'event 1 and event 2 should be overlaped' do
      expect(Myscheduler::Event.overlaps.include?(event_1)).to eq true
      expect(Myscheduler::Event.overlaps.include?(event_2)).to eq true
    end
  end

  context '#period?' do
    it 'begin time is current and end time is tommorow that should be in event 2' do
      expect(event_2.period?(Time.now, Time.now + 86_400)).to eq true
    end
  end

  context '#overlaps?' do
    it 'event 1 and event 2 should be overlaped' do
      expect(event_1.overlaps?(event_2)).to eq true
    end
  end
end
