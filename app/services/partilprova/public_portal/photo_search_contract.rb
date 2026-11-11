module Partilprova
  module PublicPortal
    # PP05.1: public input boundary. Does not assume an Atlas search endpoint.
    # A bib number is an event-scoped identifier, never a participant identity.
    class PhotoSearchContract
      MAX_BIB_LENGTH = 12
      DEFAULT_PAGE = 1
      MAX_PAGE = 1_000
      PER_PAGE = 24

      Query = Data.define(:event_identifier, :bib_number, :page, :per_page) do
        def filtered? = !bib_number.nil?
        def public_params
          { page: page, per_page: per_page }.tap { |params| params[:bib_number] = bib_number if filtered? }
        end
      end

      class InvalidQuery < ArgumentError; end

      def self.build(event_identifier:, bib_number: nil, page: nil)
        event = event_identifier.to_s
        raise InvalidQuery, "invalid event identifier" unless event.match?(/\A[a-zA-Z0-9][a-zA-Z0-9_-]{0,127}\z/)

        bib = normalize_bib(bib_number)
        current_page = Integer(page.nil? || page.to_s.empty? ? DEFAULT_PAGE.to_s : page.to_s, 10)
        raise InvalidQuery, "invalid page" unless current_page.between?(1, MAX_PAGE)

        Query.new(event_identifier: event, bib_number: bib, page: current_page, per_page: PER_PAGE)
      rescue ArgumentError, TypeError
        raise InvalidQuery, "invalid public photo search query"
      end

      def self.normalize_bib(value)
        return nil if value.nil?
        raise InvalidQuery, "invalid bib number" unless value.is_a?(String) || value.is_a?(Integer)
        bib = value.to_s.strip
        return nil if bib.empty?
        raise InvalidQuery, "invalid bib number" unless bib.length <= MAX_BIB_LENGTH && bib.match?(/\A[0-9]+\z/)
        bib # preserve leading zeros; bib numbers are strings, not integers
      end
      private_class_method :normalize_bib
    end
  end
end
