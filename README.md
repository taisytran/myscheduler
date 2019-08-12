# Myscheduler

## Problem

Implement a Calendar class which supports two operations:

1. Schedule events
2. Find time windows which are overbooked and find the associated conflicted events.

## Instructions

Please implement `schedule` and `find_conflicted_time_windows`. The return value of `find_conflicted_time_windows` should be a list of `ConflictedTimeWindow` objects ordered by their `start_time` from earliest to latest. Please be aware that each `ConflictedTimeWindow` should contain ALL the conflicted events within the associated time period.

For example,

```ruby
calendar = Calendar.new
calendar.schedule(Event.new(4,
    Time.parse('2019-01-02 10:00'),
    Time.parse('2019-01-02 11:00')))
calendar.schedule(Event.new(5,
    Time.parse('2019-01-02 09:30'),
    Time.parse('2019-01-02 11:30')))
calendar.schedule(Event.new(6,
    Time.parse('2019-01-02 08:30'),
    Time.parse('2019-01-02 12:30')))

puts calendar.find_conflicted_time_windows
# should print
# {2019-01-02 09:30:00 -0800 - 2019-01-02 10:00:00 -0800: [6, 5]}
# {2019-01-02 10:00:00 -0800 - 2019-01-02 11:00:00 -0800: [6, 5, 4]}
# {2019-01-02 11:00:00 -0800 - 2019-01-02 11:30:00 -0800: [6, 5]}
```

## Installation

 $ bundle install
 
 $ chmod +x bin/run

## Usage
 Run example

 $ bin/run
 
 Run test cases
 
 $ bundle exec rspec

## Result

[![video](result.gif)](result.gif)