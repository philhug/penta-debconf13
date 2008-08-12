module FeedbackHelper
  def format_conference_day( day, name = nil )
    if day.instance_of?( Conference_day::Row )
      date = day.conference_day
      name = day.name
    else
      date = day
    end
    if name
      "#{name} (#{date})"
    else
      index = 0
      @days.each_with_index do | d, i |
        if d.conference_day == date
          index = i + 1
          break
        end
      end
      "#{local(:day)} #{index} (#{date})"
    end
  end
end
