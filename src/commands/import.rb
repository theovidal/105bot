require 'httparty'
require_relative 'command'

module HundredFive
  module Commands
    class Import < Command
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
        content.send(':incoming_envelope: Consultez vos messages privés pour compléter la procédure.')
        waiter = Classes::Waiter.new(context.author.pm, ':airplane_arriving: Importation des devoirs depuis Pronote', "Envoyez dans ce salon vos identifiants sous la forme : NomDUtilisateur**,**MotDePasse.\n**Aucune donnée n'est sauvegardée, néanmoins merci de supprimer votre message après le traitement par le bot.**")

        event = context.bot.add_await!(Discordrb::Events::MessageEvent, {
          from: context.author.id,
          in: context.author.pm.id,
          timeout: 120
        })
        if event.nil?
          waiter.error('Le délai imparti a expiré.', 'Veuillez relancer votre demande avec la commande `105:import`.')
          return
        end

        credentials = event.content.split(',')
        p credentials

        waiter.edit_subtext("L'exécution de cette commande peut être plus ou moins longue, selon le nombre de devoirs à importer.")

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
          when 404 then raise Classes::ExecutionError.new(waiter, "l'adresse URL vers le crawler est inconnue. Veuillez la vérifier dans la configuration du robot.")
          else nil
          end
        rescue SocketError
          raise Classes::ExecutionError.new(waiter, "la connexion avec le crawler n'a pu s'effectuer. Vérifier son adresse dans la configuration du robot.")
        end

        imported = 0
        time_limit = Time.now - 24 * 60 * 60

        assignments = JSON.parse(response.body)['homeworks']
        assignments.each do |assignment|
          content = assignment['content'].gsub('<br>', '')
          timestamp = assignment['until'] / 1000
          next if timestamp < time_limit.to_i
          next unless Models::Assignments.where(text: content).first.nil? || args[:acceptDuplicates]

          Models::Assignments.create do |model|
            model.date = Time.at(timestamp)
            model.subject = assignment['subject']
            model.type = 'homework'
            model.text = content
          end
          imported += 1
        end

        subtext = imported < 1 ? nil : "Rafraichissez l'agenda pour les voir apparaître."
        waiter.finish("Importation de #{imported} devoirs effectuée.", subtext)
      end
    end
  end
end
