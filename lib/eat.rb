require 'uri'
require 'httpclient'

require 'eat/version'

# http://weblog.jamisbuck.org/2007/2/7/infinity
unless defined?(::Infinity)
  ::Infinity = 1.0/0
end

module Eat
  # httpclient 2.2.3 inserts the platform info for you, albeit with problems
  # AGENT_NAME = "Mozilla/5.0 (#{::RUBY_PLATFORM}) Ruby/#{::RUBY_VERSION} HTTPClient/#{::HTTPClient::VERSION} eat/#{::Eat::VERSION}"
  AGENT_NAME = "eat/#{::Eat::VERSION}"

  module ObjectExtensions
    # <tt>url</tt> can be filesystem or http/https
    #
    # Options:
    # * <tt>:timeout</tt> in seconds
    # * <tt>:limit</tt> is characters (bytes in Ruby 1.8)
    # * <tt>:openssl_verify_mode</tt> set to 'none' if you don't want to verify SSL certificates
    #
    # Example:
    #    eat('http://brighterplanet.com')                 #=> '...'
    #    eat('http://brighterplanet.com', :timeout => 10) #=> '...'
    #    eat('http://brighterplanet.com', :limit => 1)    #=> '.'
    def eat(url, options = {})
      limit = options.fetch(:limit, ::Infinity)
      
      uri = ::URI.parse url.to_s

      body = []
      read_so_far = 0

      case uri.scheme

      when 'file', nil
        chunk_size = limit < 1_048_576 ? limit : 1_048_576
        ::File.open(uri.path, 'r') do |f|
          while chunk = f.read(chunk_size)
            break if read_so_far > limit
            read_so_far += chunk_size
            body << chunk
          end
        end

      when 'http', 'https'
        timeout = options.fetch(:timeout, 2)
        openssl_verify_mode = options.fetch(:openssl_verify_mode, ::OpenSSL::SSL::VERIFY_PEER)
        if openssl_verify_mode == 'none'
          openssl_verify_mode = ::OpenSSL::SSL::VERIFY_NONE
        end
        http = ::HTTPClient.new
        http.agent_name = AGENT_NAME
        http.redirect_uri_callback = ::Proc.new { |uri, res| ::URI.parse(res.header['location'][0]) }
        http.transparent_gzip_decompression = true
        http.receive_timeout = timeout
        if uri.scheme == 'https'
          http.ssl_config.verify_mode = openssl_verify_mode
        end
        if limit == ::Infinity
          body << http.get_content(uri.to_s)
        else
          catch :stop do
            http.get_content(uri.to_s) do |chunk|
              body << chunk
              read_so_far += chunk.length
              throw :stop if read_so_far > limit
            end
          end
        end
      end

      limit == ::Infinity ? body.join : body.join[0...limit]
    end
  end
end

::Object.send(:include, ::Eat::ObjectExtensions) unless ::Object.method_defined?(:eat)
