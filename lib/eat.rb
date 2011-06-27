require 'uri'
require 'singleton'

# http://weblog.jamisbuck.org/2007/2/7/infinity
unless defined?(::Infinity)
  ::Infinity = 1.0/0
end

module Eat
  module ObjectExtensions
    # <tt>url</tt> can be filesystem or http/https
    #
    # Options:
    # * <tt>:timeout</tt> in seconds
    # * <tt>:limit</tt> is characters (bytes in Ruby 1.8)
    #
    # Example:
    #    eat('http://brighterplanet.com')                 #=> '...'
    #    eat('http://brighterplanet.com', :timeout => 10) #=> '...'
    #    eat('http://brighterplanet.com', :limit => 1)    #=> '.'
    def eat(url, options = {})
      timeout = options[:timeout] || options['timeout'] || 2
      limit = options[:limit] || options['limit'] || ::Infinity
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
        require 'net/http'
        require 'net/https' if uri.scheme == 'https'
        (defined?(::SystemTimer) ? ::SystemTimer : ::Timeout).timeout(timeout) do
          http = ::Net::HTTP.new uri.host, uri.port
          if uri.scheme == 'https'
            http.use_ssl = true
            # if you were trying to be real safe, you wouldn't use this library
            http.verify_mode = ::OpenSSL::SSL::VERIFY_NONE
          end
          http.start do |session|
            catch :stop do
              session.get(uri.request_uri, 'Accept-Encoding' => '') do |chunk|
                throw :stop if read_so_far > limit
                read_so_far += chunk.length
                body << chunk
              end
              session.finish
            end
          end
        end

      end

      limit == ::Infinity ? body.join : body.join[0...limit]
    end
  end
end

::Object.send(:include, ::Eat::ObjectExtensions) unless ::Object.method_defined?(:eat)
