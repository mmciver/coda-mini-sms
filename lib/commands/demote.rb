# frozen_string_literal: true

module CodaMiniSMS
  module App
    module Commands
      # Handle demoting admins to members
      module Demote
        def self.description
          [
            'Demote <phone_number>',
            'Demotes an admin phone number to a member number. All other admins will be notified of this change.',
            'The phone number must be in the correct format with + and the country code',
            'Example: "Demote +15551234567" will demote the US number (555) 123-4567',
          ].join("\n")
        end

        def self.execute(sms)
          changed = []
          sms.body_numbers.each do |number|
            next unless number.exists?
            next unless number.role == 'Admin'

            number.role = 'Member'
            changed << number.to_s
          end
          send_complete(sms)
          send_demoted_alert(sms, changed)
        end

        def self.send_complete(sms)
          App::Sender.send(
            sms.body_numbers.map { |number| "#{number.string} is a #{number.role}" }.join("\n"),
            sms.from.to_s
          )
        end

        def self.send_demoted_alert(sms, changed)
          sms.from.group[:admins].each do |admin|
            App::Sender.send(
              "The following phone numbers have been removed from administrative roles: #{changed.join(', ')}",
              admin[:phone_number]
            )
          end
        end

        FORMAT = 'Demote +15551234567'.freeze
        def self.valid_format?(sms)
          sms.body_numbers.any?
        end

        def self.admin_only?
          true
        end
      end
    end
  end
end
