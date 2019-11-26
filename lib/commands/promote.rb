# frozen_string_literal: true

module CodaMiniSMS
  module App
    module Commands
      module Promote

        def self.description
          [
            'Promote <phone_number>',
            'Promotes a member phone number to an admin role. All other admins will be notified of this change.',
            'The phone number must be in the correct format with + and the country code',
            'Example: "Promote +15551234567" will promote the US number (555) 123-4567',
          ].join("\n")
        end

        def self.execute(sms)
          changed = []
          sms.body_numbers.each do |number|
            next unless number.exists?
            next unless number.role == 'Member'

            number.role = 'Admin'
            changed << number.to_s
          end
          send_complete(sms)
          send_promoted_alert(sms, changed)
        end

        def self.send_complete(sms)
          App::Sender.send(
            sms.body_numbers.map { |number| "#{number.string} is a #{number.role}" }.join("\n"),
            sms.from.to_s
          )
        end

        def self.send_promoted_alert(sms, changed)
          sms.from.group[:admins].each do |admin|
            App::Sender.send(
              "The following phone numbers have been granted administrative roles: #{changed.join(', ')}",
              admin[:phone_number]
            )
          end
        end

        FORMAT = 'Promote +15551234567'.freeze
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
