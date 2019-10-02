# frozen_string_literal: true

module CodaMiniSMS
  module App
    # each sms
    class SMS
      attr_reader :body, :from, :to, :params
      def initialize(params)
        @params = params
        @from = params.fetch(:From)
        @to = params.fetch(:To)
        @body = params.fetch(:Body, '<<No Body>>')
      end

      def validated?
        body =~ /coda/i || Status.of_number(from) != 'unknown'
      end
    end
  end
end
