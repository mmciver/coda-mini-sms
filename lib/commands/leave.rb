# frozen_string_literal: true

module CodaMiniSMS
  module App
    module Commands
      module Leave

        def self.description
          [
            '',
            ''
          ].join("\n")
        end

        def self.execute(sms)
        end

        FORMAT = 'Leave'.freeze
        def self.valid_format?(sms)
          true
        end

        def self.admin_only?
          false
        end

      end
    end
  end
end
