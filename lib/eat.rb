require 'uri'
require 'singleton'

module Eat
  def self.config
    ::Eat::Config.instance
  end
  
  class Config
    include ::Singleton
    attr_writer :remote_timeout
    def remote_timeout
      @remote_timeout || 2 #seconds
    end
  end
  
  module ObjectExtensions
    def eat(filesystem_path_or_uri)
      uri = ::URI.parse filesystem_path_or_uri
      case uri.scheme
      when nil
        if ::File.readable? uri.path
          ::IO.read uri.path
        else
          `sudo /bin/cat #{uri.path}`
        end
      when 'http', 'https'
        require 'net/http'
        require 'net/https' if uri.scheme == 'https'
        (defined?(::SystemTimer) ? ::SystemTimer : ::Timeout).timeout(::Eat.config.remote_timeout) do
          http = ::Net::HTTP.new uri.host, uri.port
          if uri.scheme == 'https'
            http.use_ssl = true
            # if you were trying to be real safe, you wouldn't use this library
            http.verify_mode = ::OpenSSL::SSL::VERIFY_NONE
          end
          http.start { |session| session.get uri.request_uri }
        end.body
      end
    end
  end
end

::Object.send :include, ::Eat::ObjectExtensions
