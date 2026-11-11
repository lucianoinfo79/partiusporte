# PP02.1 architecture guardrails.
#
# PartilProva is a separate public product. It must never connect directly to
# the Atlas database. Atlas integration is exclusively through the versioned
# public HTTPS API configured by ATLAS_PUBLIC_API_BASE_URL.
#
# Do not add Atlas database credentials, cross-database models, or direct
# ActiveRecord connections to Atlas in this application.
