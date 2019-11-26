# frozen_string_literal: true

module CodaMiniSMS
  module App
    module Commands
      module Password

        def self.description
          [
            '',
            ''
          ].join("\n")
        end

        def self.execute(sms)
        end

        FORMAT = 'Password <word> (no spaces or special characters)'.freeze
        def self.valid_format?(sms)
          sms.body =~ /^password [a-z0-9]+$/i
        end

        def self.admin_only?
          true
        end

      end
    end
  end
end
