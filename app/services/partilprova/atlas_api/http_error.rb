module Partilprova
  module AtlasApi
    class HttpError < Error
      attr_reader :response

      def initialize(response)
        @response = response
        super("Atlas Public API returned HTTP #{response.status}")
      end
    end
  end
end
