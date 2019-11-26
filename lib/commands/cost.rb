# frozen_string_literal: true

module CodaMiniSMS
  module App
    module Commands
      module Cost

        def self.description
          [
            '',
            ''
          ].join("\n")
        end

        def self.execute(sms)
        end

        FORMAT = 'Cost'.freeze
        def self.valid_format?(sms)
          true
        end

        def self.admin_only?
          true
        end

      end
    end
  end
end
