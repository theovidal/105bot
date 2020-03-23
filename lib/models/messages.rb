module Coronagenda
  module Models
    class Messages < Sequel::Model
      def self.prettify(message)
        date = Time.at(message[:date])
        days = date.day.digits
        output = "**――――――――――――――――――――**\n"
        output << "**:calendar_spiral: #{DAYS[date.wday]} #{EMOJI_DAYS[days[1]]}#{EMOJI_DAYS[days[0]]} #{MONTHS[date.month]}**\n\n"
      end

      def self.refresh(context, message)
        content = Models::Messages.prettify(message)

        assignments = Models::Assignments.from_day(message[:date])
        homework = ''
        events = ''

        assignments.each do |assignment|
          if assignment[:type] == 'homework'
            homework << Models::Assignments.prettify(assignment)
          else
            events << Models::Assignments.prettify(assignment)
          end
        end

        events = "Aucun événement n'est prévu ce jour\n" if events == ''
        homework = "Aucun devoir n'est à faire pour ce jour" if homework == ''

        content << "__:incoming_envelope: Événements :__\n#{events}\n"
        content << "__:clipboard: Devoirs :__\n#{homework}"

        context.bot.channel($config['server']['output_channel']).message(message[:discord_id]).edit(content)
      end

      def self.from_day(day)
        if day.is_a? Array
          day = Time.new(2020, day[1], day[0], 0)
        end
        Models::Messages.where(date: day.to_i + TZ_OFFSET).first
      end
    end
  end
end
