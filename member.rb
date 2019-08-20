require 'data_mapper'

class Member
  include DataMapper::Resource

  property :id, Serial
  property :phone_number, String
end
