# frozen_string_literal: true

module CodaMiniSMS
  module App
    # Handles number status
    module Status
      def self.clear
        return false if current_broadcasts.empty?

        current_broadcasts.each do |row|
          start_time = Time.parse(row['reference'])
          next unless (Time.new - start_time) > 900

          sql = [
            'UPDATE phone_numbers SET status = ',
            "'active' WHERE phone_number = '#{row['phone_number']}'"
          ].join(' ')
          DB.execute(sql)
        end
      end

      def self.current_broadcasts
        sql = "SELECT * FROM phone_numbers WHERE status = 'broadcast'"
        DB.query(sql)
      end

      def self.active_numbers(redact = false)
        sql = [
          'SELECT * FROM phone_numbers',
          "WHERE status IN ('active', 'broadcast')"
        ].join(' ')
        DB.query(sql).map do |row|
          redact ? last_4(row['phone_number']) : row['phone_number']
        end
      end

      def self.inactive_numbers(redact = false)
        sql = "SELECT * FROM phone_numbers WHERE status IN ('inactive')"
        DB.query(sql).map do |row|
          redact ? last_4(row['phone_number']) : row['phone_number']
        end
      end

      def self.last_4(number)
        number[-4..-1]
      end

      def self.of_number(number)
        sql = "SELECT * FROM phone_numbers WHERE phone_number = '#{number}'"
        result = DB.query(sql)
        return 'unknown' if result.empty?

        result.first['status']
      end
    end
  end
end
