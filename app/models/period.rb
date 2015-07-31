#encoding: utf-8
class Period < ActiveRecord::Base  
  belongs_to :user
  has_many :subjects
  has_many :events, through: :subjects
  after_initialize :init_values
  validates_presence_of :start_date, :end_date, :number, :user_id
  validates_numericality_of :number
  validates_date :end_date, after: :start_date
  validates_uniqueness_of :number
  validates_uniqueness_of :is_current, if: :is_current?

  def init_values
    self.mean ||= 0
    self.is_current ||= false
  end

  def is_current?
    self.is_current == true
  end

  def self.get_calendar_hours(period)
    hours = []

    period.events.each do |event|
      hours << event.formatted_start_time << event.formatted_end_time
    end

    hours.sort!
    hours = ["06:00", "24:00"] if hours == []
    hours = [hours.first, hours.last]

    return hours
  end

  def self.get_events(period)
    events = []

    period.events.each do |event|
      event.fullcalendar_dates.each do |date|
        events << date
      end
    end
  
    return events
  end

  def self.check_current_period(period)
    if Date.today.between?(period.start_date, period.end_date)
      period.is_current = true
    end

    return period
  end
end
