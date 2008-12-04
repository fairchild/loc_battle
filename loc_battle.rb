require 'rubygems'
$:.unshift File.dirname(__FILE__) + '/vendor/sinatra/lib'
require 'sinatra'
require 'sequel'
require 'json'

configure do
  CONTENDERS_DIR = Sinatra.options.root + '/public/results/'
  DB = Sequel.connect('sqlite://locbattle.db')
  puts "I just started up in #{Sinatra.options.env}\n#{CONTENDERS_DIR}\n\n"
end

load File.dirname(__FILE__)+'/lib/contender.rb'

get '/' do
  dirs = (Dir.entries('contenders')) - ['.','..','.gitignore']
  @contenders = dirs.collect do |dirname| 
    contender = Contender.find_or_create(:name=>dirname)
    contender.cloc if !contender.cloced?
    contender
  end
  haml :contenders
end

get '/contender/:name' do
  @contender = Contender[ :name=>params[:name] ]
  @command = "./bin/cloc.pl -no3 --quiet contenders/#{@contender}"
  @contender.cloc
  @contender.save
  erb :contender
end
