module Partilprova
  module AtlasApi
    class TransportError < Error
      attr_reader :cause

      def initialize(message = "Atlas Public API transport failure", cause: nil)
        @cause = cause
        super(message)
      end
    end
  end
end
