module CodaMiniSMS
  module App
    module DB
      def self.query(sql)
        begin
          connection = PG.connect(ENV['DATABASE_URL'])
          results = results_to_array(
            connection.exec(sql)
          )
        rescue PG::Error => e
          return e.message
        ensure
          connection.close if connection
        end
      end

      def self.execute(sql)
        begin
          connection = PG.connect(ENV['DATABASE_URL'])
          puts "Executing: #{sql}"
          connection.exec(sql)
        rescue PG::Error => e
          puts e.message
          return e.message
        ensure
          connection.close if connection
        end
      end

      def self.results_to_array(result)
        ary = []
        result.each { |row| ary << row_to_hash(row) }
        ary
      end

      def self.row_to_hash(row)
        hash = {}
        row.each { |key, value| hash[key] = value }
        hash
      end
    end
  end
end
