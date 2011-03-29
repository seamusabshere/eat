require 'helper'

require 'tempfile'
class Tempfile
  class TriedToUseMe < RuntimeError; end
  def initialize(*args)
    raise TriedToUseMe
  end
end

class TestEat < Test::Unit::TestCase
  def setup
    ::Eat.config.remote_timeout = 10
  end
  
  def test_filesystem
    assert eat(__FILE__).include?('class TestEat < Test::Unit::TestCase')
  end
  
  def test_filesystem_uri
    assert eat("file://#{File.expand_path(__FILE__)}").include?('class TestEat < Test::Unit::TestCase')
  end
  
  def test_http
    assert eat('http://brighterplanet.com/robots.txt').include?('User-agent')
  end
  
  def test_https
    assert eat('https://brighterplanet.com/robots.txt').include?('User-agent')
  end
  
  def test_sudo_filesystem
    f = File.open('test_sudo_filesystem.txt', 'w')
    f.write "hello world"
    f.close
    `sudo chown root #{f.path}`
    `sudo chmod go-rwx #{f.path}`
    assert !File.readable?(f.path)
    assert eat(f.path).include?('hello world')
  ensure
    `sudo rm -f #{f.path}`
  end
  
  def test_openuri_uses_tempfile
    assert_raises(Tempfile::TriedToUseMe) do
      require 'open-uri'
      open 'http://do1ircpq72156.cloudfront.net/0.2.47/javascripts/prototype.rails-3.0.3.js'
    end
  end
  
  def test_eat_doesnt_use_tempfile
    assert_nothing_raised do
      eat 'http://do1ircpq72156.cloudfront.net/0.2.47/javascripts/prototype.rails-3.0.3.js'
    end
  end
end
