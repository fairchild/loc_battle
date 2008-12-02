require 'rubygems'
$:.unshift File.dirname(__FILE__) + '/vendor/sinatra/lib'
require 'sinatra'

require 'lib/contender.rb'

$LOAD_PATH.unshift File.dirname(__FILE__) + '/vendor/'
SINATRA_ROOT=File.dirname(__FILE__)

configure do
  # Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://loc_battle.db')
end

### Public

get '/' do
  @contenders = Contender.list
  haml :contenders
end

get '/contender/:name' do
  @contender = params[:name]
  @command = "./bin/cloc.pl -no3 --quiet contenders/#{@contender}"
  erb :contender
end
