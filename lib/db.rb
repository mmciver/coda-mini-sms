# frozen_string_literal: true

module CodaMiniSMS
  module App
    # Handles Heroku DB connections
    module DB
      def self.query(sql)
        connection = PG.connect(ENV['DATABASE_URL'])
        results_to_array(connection.exec(sql))
      rescue PG::Error => e
        e.message
      ensure
        connection&.close
      end

      def self.execute(sql)
        connection = PG.connect(ENV['DATABASE_URL'])
        connection.exec(sql)
      rescue PG::Error => e
        puts e.message
        e.message
      ensure
        connection&.close
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
