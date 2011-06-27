# -*- encoding: utf-8 -*-
require 'helper'

require 'tempfile'
class Tempfile
  class TriedToUseMe < RuntimeError; end
  def initialize(*args)
    raise TriedToUseMe
  end
end

class TestEat < Test::Unit::TestCase
  def test_filesystem
    assert eat(__FILE__).include?('class TestEat < Test::Unit::TestCase')
  end
  
  def test_filesystem_uri
    assert eat("file://#{File.expand_path(__FILE__)}").include?('class TestEat < Test::Unit::TestCase')
  end
  
  def test_uri
    assert eat(::URI.parse('http://brighterplanet.com/robots.txt'), :timeout => 10).include?('User-agent')
  end
  
  def test_http
    assert eat('http://brighterplanet.com/robots.txt', :timeout => 10).include?('User-agent')
  end
  
  def test_https
    assert eat('https://brighterplanet.com/robots.txt', :timeout => 10).include?('User-agent')
  end
  
  def test_openuri_uses_tempfile
    assert_raises(Tempfile::TriedToUseMe) do
      require 'open-uri'
      open 'http://do1ircpq72156.cloudfront.net/0.2.47/javascripts/prototype.rails-3.0.3.js'
    end
  end
  
  def test_eat_doesnt_use_tempfile
    assert_nothing_raised do
      eat 'http://do1ircpq72156.cloudfront.net/0.2.47/javascripts/prototype.rails-3.0.3.js', :timeout => 10
    end
  end

  def test_limit_on_local_files
    assert_equal '# -', eat(__FILE__, :limit => 3)
    assert_equal '# -*-', eat(__FILE__, :limit => 5)
  end
    
  def test_limit_on_remote_files
    assert_equal 'Use', eat(::URI.parse('http://brighterplanet.com/robots.txt'), :timeout => 10, :limit => 3)
    assert_equal 'User-', eat(::URI.parse('http://brighterplanet.com/robots.txt'), :timeout => 10, :limit => 5)
  end
end
