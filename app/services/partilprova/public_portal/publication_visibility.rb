module Partilprova
  module PublicPortal
    # Defense-in-depth for explicit publication decisions returned by Atlas.
    # The authoritative visibility filter MUST be implemented on Atlas.
    module PublicationVisibility
      PRIVATE_STATES = %w[draft unpublished private hidden suspended archived].freeze
      module_function

      def visible?(record)
        return false unless record.is_a?(Hash)
        return false if record["published"] == false || record["publicly_visible"] == false
        return false if record["publication_status"].to_s.downcase.in?(PRIVATE_STATES)
        true
      end
    end
  end
end
