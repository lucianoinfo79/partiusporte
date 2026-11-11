require "net/http"

module Partilprova
  module AtlasApi
    class NetHttpTransport
      def get(uri:, headers:, open_timeout:, read_timeout:)
        request = Net::HTTP::Get.new(uri)
        headers.each { |key, value| request[key] = value }

        Net::HTTP.start(
          uri.host,
          uri.port,
          use_ssl: uri.scheme == "https",
          open_timeout: open_timeout,
          read_timeout: read_timeout
        ) do |http|
          http.request(request)
        end
      rescue Net::OpenTimeout, Net::ReadTimeout, Timeout::Error => error
        raise TimeoutError.new("Atlas Public API request timed out", cause: error)
      rescue SocketError, SystemCallError, IOError => error
        raise TransportError.new("Atlas Public API is unreachable", cause: error)
      end
    end
  end
end
