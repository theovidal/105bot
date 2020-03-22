module Coronagenda
  module Models
    class Assignments < Sequel::Model
      def self.prettify(assignment)
        date = Time.at(assignment[:date])
        subject = $subjects[assignment[:subject]]
        emoji = ":#{subject['emoji']}:"
        due = assignment.type == 'homework' ? "(rendu avant #{date.hour}h)" : "(à #{date.hour}h)"
        output = "• #{emoji} #{subject['name']} : #{assignment[:text]} #{due}\n"
        output << "#{assignment[:link]}\n" if assignment[:link] != ''
      end
    end

    class Messages < Sequel::Model
      def self.prettify(message)
        date = Time.at(message[:date])
        days = date.day.digits
        output = "**――――――――――――――――――――**\n"
        output << "**:calendar_spiral: #{DAYS[date.wday]} #{EMOJI_DAYS[days[1]]}#{EMOJI_DAYS[days[0]]} #{MONTHS[date.month]}**\n\n"
      end
    end
  end
end