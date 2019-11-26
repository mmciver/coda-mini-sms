# frozen_string_literal: true

module CodaMiniSMS
  module App
    # each sms
    class SMS
      attr_reader :body, :from, :to, :params, :body_numbers

      def initialize(params)
        @params = params
        @from = App::Number.new(params.fetch(:From), params.fetch(:To))
        @to = params.fetch(:To)
        @body = params.fetch(:Body, '<<No Body>>')
        @body_numbers = contained_numbers(@body)
      end

      def validated?
        return true if @from.exists?
        return false unless @body.downcase == @from.group[:password].downcase

        @from.add
      end

      def contained_numbers(text)
        text.scan(/\+\d{10,}/).map do |number|
          App::Number.new(number, @to)
        end
      end
    end
  end
end
