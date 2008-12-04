$:.unshift File.dirname(__FILE__) + '/../vendor/sinatra/lib'

require 'rubygems'
require 'sinatra'
require 'sinatra/test/unit'
require File.dirname(__FILE__) + '/../loc_battle.rb'

class LocBattleTest < Test::Unit::TestCase

  def test_cloc
    assert contender = Contender.create(:name=>'sinatra')
    assert_not_nil contender.name
  end

  def test_my_default
    # require "rubygems"; require "ruby-debug"; debugger 
    get_it '/'
    assert_equal 'My Default Page!', @response.body
  end

  def test_with_agent
    get_it '/', :agent => 'Songbird'
    assert_equal "You're in Songbird!", @response.body
  end


end