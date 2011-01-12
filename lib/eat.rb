require 'uri'

module Eat
  def eat(filesystem_path_or_uri, remote_timeout = 5)
    uri = ::URI.parse filesystem_path_or_uri
    case uri.scheme
    when nil
      if ::File.readable? uri.path
        ::IO.read uri.path
      else
        `sudo cat #{uri.path}`
      end
    when 'http', 'https'
      require 'net/http'
      require 'net/https' if uri.scheme == 'https'
      (defined?(::SystemTimer) ? ::SystemTimer : ::Timeout).timeout(remote_timeout) do
        http = ::Net::HTTP.new uri.host, uri.port
        if uri.scheme == 'https'
          http.use_ssl = true
          # if you were trying to be real safe, you wouldn't use this library
          http.verify_mode = ::OpenSSL::SSL::VERIFY_NONE
        end
        http.request ::Net::HTTP::Get.new(uri.request_uri)
      end.body
    end
  end
end

::Object.send :include, ::Eat
