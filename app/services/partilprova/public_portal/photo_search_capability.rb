module Partilprova
  module PublicPortal
    # Enable only after Atlas has implemented and qualified server-side bib filtering.
    class PhotoSearchCapability
      Status = Data.define(:available, :reason) do
        def available? = available
      end

      def self.current
        enabled = ENV.fetch("PARTILPROVA_ATLAS_PHOTO_BIB_SEARCH", "false") == "true"
        Status.new(available: enabled, reason: enabled ? :atlas_contract_enabled : :atlas_contract_pending)
      end
    end
  end
end
