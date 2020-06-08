require 'httparty'

module HundredFive
  module Commands
    module Agenda
      class ImportCommand < Command
        DESC = 'Importer les devoirs de Pronote'
        CATEGORY = 'agenda'
        USAGE = 'import'
        ARGS = {
          acceptDuplicates: {
            description: "Accepter les devoirs déjà inclus dans la base de données (si vous n'êtes pas sûrs, laissez la valeur par défaut)",
            type: Integer,
            boolean: true,
            default: 0
          }
        }

        def self.exec(context, args)
          agenda = Models::Agendas.get(context)
          public_waiter = Classes::Waiter.new(context, false)

          public_waiter.action_needed
          context.author.pm.send_embed('', Utils.embed(
            title: ":airplane_arriving: Procédure d'importation des devoirs depuis Pronote pour l'agenda #{agenda[:name]}",
            description: "Envoyez dans ce salon vos identifiants sous la forme : NomDUtilisateur**,**MotDePasse.\n**Aucune donnée n'est sauvegardée, néanmoins merci de supprimer votre message après le traitement par le bot.**",
            color: CONFIG['messages']['wait_color']
          ))

          event = context.bot.add_await!(Discordrb::Events::MessageEvent, {
            from: context.author.id,
            in: context.author.pm.id,
            timeout: 120
          })
          if event.nil?
            waiter.error('Le délai imparti a expiré.', "Veuillez relancer votre demande avec la commande `#{CONFIG['bot']['prefix']}import`.")
            return
          end

          credentials = event.content.split(',')

          private_waiter = Classes::Waiter.new(event)

          begin
            body = JSON.generate({
              type: 'fetch',
              username: credentials[0],
              password: credentials[1],
              url: CONFIG['pronote']['url'],
              cas: 'none',
              typecon: 'eleve.html'
            })
            response = HTTParty.post(
              CONFIG['pronote']['api'],
              body: body
            )
            case response.code.to_i
            when 404 then raise Classes::ExecutionError.new(private_waiter, "l'adresse de l'API est inconnue. Veuillez la vérifier dans la configuration du robot.")
            else nil
            end
          rescue SocketError
            raise Classes::ExecutionError.new(private_waiter, "la connexion avec l'API n'a pu s'effectuer. Vérifier son adresse dans la configuration du robot.")
          end

          time_limit = Time.now - 24 * 60 * 60

          assignments = JSON.parse(response.body)['homeworks']
          assignments.each do |assignment|
            content = assignment['content'].gsub('<br>', '')
            timestamp = assignment['until'] / 1000
            next if timestamp < time_limit.to_i
            next unless Models::Assignments.where(agenda: agenda[:snowflake], text: content).first.nil? || args[:acceptDuplicates]

            Models::Assignments.create do |model|
              model.agenda = agenda[:snowflake]
              model.type = 'work'
              model.subject = assignment['subject']
              model.text = content
              model.date = Time.at(timestamp)
            end
          end

          public_waiter.finish
          private_waiter.finish
        end
      end
    end
  end
end
