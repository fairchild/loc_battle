require 'rubygems'
require 'sinatra'

$LOAD_PATH.unshift File.dirname(__FILE__) + '/vendor/'
SINATRA_ROOT=File.dirname(__FILE__)

configure do
  # Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://loc_battle.db')
end

### Public

get '/' do
  @contenders = Dir.entries('contenders')
  erb :contenders
end

get '/contender/:name' do
  @contender = params[:name]
  @command = "./bin/cloc.pl -no3 --quiet contenders/#{@contender} --report-file=public/results/#{@contender}.txt"
  @stats = `#{@command}` if !File.exist?("public/results/#{@contender}.txt")
  erb :contender
end


