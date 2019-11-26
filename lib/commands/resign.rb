# frozen_string_literal: true

module CodaMiniSMS
  module App
    module Commands
      # Handles self resignation from administrator role
      module Resign
        def self.description
          [
            'Resign',
            'Demotes yourself from an admin role to a member role.',
            'All other admins will be notified of this change.'
          ].join("\n")
        end

        def self.execute(sms)
          sms.from.role = 'Member'
          send_complete(sms)
          send_demoted_alert(sms)
        end

        def self.send_complete(sms)
          App::Sender.send(
            'Your number is now a standard member number',
            sms.from.to_s
          )
        end

        def self.send_demoted_alert(sms)
          sms.from.group[:admins].each do |admin|
            App::Sender.send(
              "#{sms.from} has voluntarily left an administrator role",
              admin[:phone_number]
            )
          end
        end

        FORMAT = 'Resign'
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
