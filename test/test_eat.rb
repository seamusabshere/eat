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
  
  def test_ssl
    assert_nothing_raised do
      eat 'https://brighterplanet.com'
    end    
  end
  
  def test_openssl_verify_on_by_default
    assert_raises(OpenSSL::SSL::SSLError) do
      eat 'https://foo.bar.brighterplanet.com'
    end
  end
  
  def test_disable_openssl_verify
    assert_nothing_raised do
      eat 'https://foo.bar.brighterplanet.com', :openssl_verify_mode => 'none'
    end
  end
  
  def test_reads_compressed
    assert eat('http://www.sears.com/shc/s/p_10153_12605_07692286000P?prdNo=8&blockNo=8&blockType=G8').include?('New Balance')
  end
  
  def test_chunks_work_out
    assert eat('http://www.thinkgeek.com/interests/giftsforhim/60b6/').include?('DOCTYPE HTML PUBLIC')
  end
  
  def test_satisfies_sites_that_require_user_agent
    assert eat('http://www.bestbuy.com').include?('images.bestbuy.com')
  end
  
  def test_more_chunks
    assert eat('http://www.ebay.com/itm/ws/eBayISAPI.dll?ViewItem&item=260910713854?_trksid=p5197.m1256&_trkparms=clkid%3D4726644202417880745').include?('<title>')
  end
  
  def test_ignores_anchor
    assert eat('http://www.orbitgum.com/#/home').include?('Orbit')
  end
  
  def test_relative_redirect_handling
    assert eat("http://www.crutchfield.com/p_054D3100/Nikon-D3100-Kit.html").include?('Product Information')
  end

  def test_returns_text_of_error_messages
    assert eat('http://brighterplanet.com/oidjfasoidfsailudfj').include?('Not Found')
  end
end
