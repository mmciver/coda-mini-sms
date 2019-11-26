# frozen_string_literal: true

module CodaMiniSMS
  module App
    module Commands
      # Handles recall of recent group messages
      module Recent
        def self.description
          [
            'Recent',
            'Sends you the last 7 days of group messages'
          ].join("\n")
        end

        def self.execute(sms)
          id = sms.from.group[:id]
          qry = "SELECT * FROM messages WHERE group_id = #{id}"
          msg = App::DB.query(qry).map do |row|
            "Sent by #{row['from'][-4..-1]} on #{row['date']}"
          end
          App::Sender.send(
            msg.join("\n\n"),
            sms.from.to_s
          )
        end

        FORMAT = 'Recent'
        def self.valid_format?(_sms)
          true
        end

        def self.admin_only?
          true
        end
      end
    end
  end
end
