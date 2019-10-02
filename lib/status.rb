module CodaMiniSMS
  module App
    module Status
      def self.clear
        numbers = current_broadcasts
        return false if numbers.empty?

        numbers.each do |row|
          start_time = Time.parse(row['reference'])
          if (Time.new - start_time) > 900
            sql = "UPDATE messages SET status = 'active' WHERE phone_number = '#{row['phone_number']}'"
            DB.execute(sql)
          end
        end
      end

      def self.current_broadcasts
        sql = "SELECT * FROM phone_numbers WHERE status = 'broadcast'"
        DB.query(sql)
      end

      def self.active_numbers(redact = false)
        sql = "SELECT * FROM phone_numbers WHERE status IN ('active', 'broadcast')"
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
