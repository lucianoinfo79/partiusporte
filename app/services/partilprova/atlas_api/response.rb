module Partilprova
  module AtlasApi
    class Response
      attr_reader :status, :headers, :data, :raw_body

      def initialize(status:, headers:, data:, raw_body:)
        @status = Integer(status)
        @headers = headers.transform_keys { |key| key.to_s.downcase }.freeze
        @data = data
        @raw_body = raw_body.to_s
      end

      def success?
        (200..299).cover?(status)
      end

      def request_id
        headers["x-request-id"]
      end
    end
  end
end
