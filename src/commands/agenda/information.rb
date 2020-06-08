module HundredFive
  module Commands
    module Agenda
      class InformationCommand < Command
        DESC = "Obtenir les informations à propos de l'agenda du salon"

        def self.exec(context, _)
          agenda = Models::Agendas.get(context)
          assignments_number = Models::Assignments.from_agenda(agenda[:snowflake]).count
          weekly_number = Models::Assignments.from_agenda(agenda[:snowflake], true).count
          s = 's' if weekly_number > 1
          context.author.pm.send_embed('', Utils.embed(
            title: ":calendar_spiral: Informations à propos de l'agenda #{agenda[:name]}",
            description:
              ":globe_with_meridians: Serveur : #{context.server.name}\n" +
              ":keyboard: Salon : ##{context.channel.name} (catégorie #{context.channel.category.name})\n" +
              ":book: Entrées : #{assignments_number + weekly_number} (dont #{weekly_number} événement#{s} hebdomadaire#{s})"
          ))
        end
      end
    end
  end
end