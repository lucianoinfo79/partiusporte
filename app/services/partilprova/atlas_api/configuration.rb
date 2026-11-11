require "uri"

module Partilprova
  module AtlasApi
    class Configuration
      DEFAULT_OPEN_TIMEOUT = 2
      DEFAULT_READ_TIMEOUT = 5

      attr_reader :base_url, :open_timeout, :read_timeout

      def initialize(
        base_url: ENV.fetch("ATLAS_PUBLIC_API_BASE_URL", "http://localhost:3000/api/public/v1"),
        open_timeout: ENV.fetch("ATLAS_PUBLIC_API_OPEN_TIMEOUT", DEFAULT_OPEN_TIMEOUT),
        read_timeout: ENV.fetch("ATLAS_PUBLIC_API_READ_TIMEOUT", DEFAULT_READ_TIMEOUT)
      )
        @base_url = normalize_base_url(base_url)
        @open_timeout = Integer(open_timeout)
        @read_timeout = Integer(read_timeout)
      end

      def uri_for(path)
        relative = path.to_s.sub(%r{\A/+}, "")
        URI.join("#{base_url}/", relative)
      end

      private

      def normalize_base_url(value)
        uri = URI.parse(value.to_s)
        unless %w[http https].include?(uri.scheme) && uri.host.present?
          raise ArgumentError, "ATLAS_PUBLIC_API_BASE_URL must be an absolute HTTP(S) URL"
        end

        value.to_s.delete_suffix("/")
      rescue URI::InvalidURIError
        raise ArgumentError, "ATLAS_PUBLIC_API_BASE_URL must be an absolute HTTP(S) URL"
      end
    end
  end
end
