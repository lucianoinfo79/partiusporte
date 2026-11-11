module Partilprova
  module AtlasApi
    # Lightweight, read-only check against the same public contract used by discovery.
    # Does not reveal internal hostnames, exception messages or upstream payloads.
    class Availability
      Result = Struct.new(:state, :http_status, keyword_init: true) do
        def available? = state == :available
      end

      def initialize(client: Client.new)
        @client = client
      end

      def call
        response = @client.get("events", params: { page: 1, per_page: 1 }, headers: { "Cache-Control" => "no-cache" })
        return Result.new(state: :available, http_status: response.status) if response.data.is_a?(Hash) || response.data.is_a?(Array)

        Result.new(state: :invalid_response, http_status: response.status)
      rescue HttpError => error
        Result.new(state: :unavailable, http_status: error.response.status)
      rescue TimeoutError, TransportError
        Result.new(state: :unavailable, http_status: nil)
      rescue InvalidResponseError
        Result.new(state: :invalid_response, http_status: nil)
      end
    end
  end
end
