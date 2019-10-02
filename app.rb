require 'sinatra'
require 'twilio-ruby'
require 'pg'
require 'time'
require_relative 'lib/db'
require_relative 'lib/sms'
require_relative 'lib/sender'
require_relative 'lib/receiver'
require_relative 'lib/status'

module CodaMiniSMS

  module App

  autoload :DB, 'lib/db'
  autoload :SMS, 'lib/sms'
  autoload :Sender, 'lib/sender'
  autoload :Receiver, 'lib/receiver'
  autoload :Status, 'lib/status'

  end
end

get '/' do
  'CoDA Mini group in Bellingham WA. Text "CoDA" to 360-228-2089 for information'
end

get '/ping' do
  CodaMiniSMS::App::Status.clear
  'Ping Successful'
end

get '/incoming-text' do
  CodaMiniSMS::App::Receiver.receive(params)
end
