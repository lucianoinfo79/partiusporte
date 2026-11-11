require "uri"
require "ipaddr"

module Partilprova
  module PublicPortal
    class RegistrationHandoff
      Result = Data.define(:url, :state) do
        def available? = state == :available
      end

      # No host is implicitly trusted. Configure the registration providers explicitly.
      def initialize(allowed_hosts: ENV.fetch("PARTILPROVA_REGISTRATION_ALLOWED_HOSTS", ""), atlas_public_origin: ENV.fetch("PARTILPROVA_ATLAS_PUBLIC_ORIGIN", ""))
        @allowed_hosts = allowed_hosts.split(",").map { |host| host.strip.downcase }.reject(&:blank?).freeze
        @atlas_public_origin = atlas_public_origin
      end

      def call(event:)
        provider = event[:registration_provider].to_s.downcase
        status = event[:registration_status].to_s.downcase

        # A definitive Atlas status must take precedence over a missing provider.
        return Result.new(url: nil, state: :unavailable) if provider == "unavailable" || status == "unavailable"
        return Result.new(url: nil, state: :sold_out) if %w[sold_out full].include?(status)
        return Result.new(url: nil, state: :cancelled) if %w[cancelled canceled].include?(status)
        return Result.new(url: nil, state: :closed) if closed?(status)
        return Result.new(url: nil, state: :not_open) if %w[upcoming not_open pending scheduled].include?(status)
        return Result.new(url: nil, state: :unknown) unless open?(status)

        url = destination(event)
        return Result.new(url: nil, state: :missing) if url.blank?
        uri = URI.parse(url)
        return Result.new(url: nil, state: :untrusted) unless trusted?(uri, atlas: provider == "atlas")
        Result.new(url: uri.to_s, state: :available)
      rescue URI::InvalidURIError
        Result.new(url: nil, state: :untrusted)
      end

      private

      # Only the Atlas-issued registration route can be resolved against the public origin.
      # Never resolve arbitrary relative paths or use the internal Docker API hostname.
      def destination(event)
        if event[:registration_provider].to_s == "external"
          return event[:registration_target].presence.to_s if event[:registration_target].present?
          return event[:registration_url].to_s
        end
        return event[:registration_url].to_s unless event[:registration_provider].to_s == "atlas"

        target = event[:registration_target].to_s
        return "" unless target.match?(%r{\A/events/[a-zA-Z0-9_-]+/editions/[a-zA-Z0-9_-]+/register\z})

        origin = URI.parse(@atlas_public_origin.to_s)
        return "" unless trusted?(origin, atlas: true) && origin.path.to_s.in?(["", "/"]) && origin.query.nil? && origin.fragment.nil?

        URI.join(origin.to_s.end_with?("/") ? origin.to_s : "#{origin}/", target.delete_prefix("/")).to_s
      rescue URI::InvalidURIError
        ""
      end

      def open?(status)
        %w[open opened active available].include?(status.to_s.downcase)
      end

      def closed?(status)
        %w[closed suspended ended finished].include?(status.to_s.downcase)
      end

      def trusted?(uri, atlas: false)
        # A browser-facing local Atlas origin is permitted only for Atlas-managed
        # registration and only in the Rails development environment.
        # Never allow HTTP localhost for third-party/external URLs or production.
        if atlas && Rails.env.development? && uri.is_a?(URI::HTTP) &&
           !uri.is_a?(URI::HTTPS) && uri.host == "localhost" && uri.port == 3000 &&
           uri.userinfo.nil? && uri.query.nil? && uri.fragment.nil? &&
           (uri.path.to_s.in?(["", "/"]) || uri.path.to_s.match?(%r{\A/events/[a-zA-Z0-9_-]+/editions/[a-zA-Z0-9_-]+/register\z}))
          return true
        end

        return false unless uri.is_a?(URI::HTTPS) && uri.host.present?
        return false unless uri.userinfo.nil? && uri.port == 443
        return false if uri.host.match?(/[^a-zA-Z0-9.\-]/)
        return false if uri.host.end_with?(".")
        return false if uri.host == "localhost" || uri.host.end_with?(".localhost")
        return false if ip_literal?(uri.host)
        @allowed_hosts.include?(uri.host.downcase)
      end

      def ip_literal?(host)
        IPAddr.new(host)
        true
      rescue IPAddr::InvalidAddressError
        false
      end
    end
  end
end
