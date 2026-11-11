# Metadata only: never log query parameters, full URLs, tokens or response bodies.
ActiveSupport::Notifications.subscribe("atlas_public_api.partilprova") do |_name, _start, _finish, _id, payload|
  Rails.logger.info({
    component: "atlas_public_api",
    outcome: payload[:outcome],
    endpoint: payload[:endpoint],
    attempts: payload[:attempts],
    duration_ms: payload[:duration_ms],
    error: payload[:error]
  }.compact.to_json)
end
