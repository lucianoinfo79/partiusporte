require "json"
require "uri"

module Partilprova
  module AtlasApi
    class Client
      DEFAULT_HEADERS = {
        "Accept" => "application/json",
        "User-Agent" => "PartilProva/AtlasPublicApiClient"
      }.freeze

      def initialize(configuration: Configuration.new, transport: NetHttpTransport.new, cache: Rails.cache)
        @configuration = configuration
        @transport = transport
        @cache = cache
      end

      # Only the event discovery endpoints are eligible for shared public caching.
      # Never cache custom-header requests, results, photos, or participant data.
      def get(path, params: {}, headers: {})
        uri = build_uri(path, params)
        cache_key = public_cache_key(path, uri, headers)
        if cache_key
          cached = @cache.read(cache_key)
          if cached.is_a?(Hash) && cached.key?(:data)
            instrument("cache_hit", path)
            return Response.new(status: 200, headers: {}, data: cached[:data], raw_body: "")
          end
        end

        attempts = 0
        begin
          attempts += 1
          started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          raw_response = transport.get(
            uri: uri,
            headers: DEFAULT_HEADERS.merge(stringify_headers(headers)),
            open_timeout: configuration.open_timeout,
            read_timeout: configuration.read_timeout
          )
          response = build_response(raw_response)
          raise HttpError, response unless response.success?
          if cache_key && response.status == 200 && response.data.is_a?(Hash)
            @cache.write(cache_key, { data: response.data }, expires_in: public_cache_ttl)
          end
          instrument("success", path, attempts: attempts, duration_ms: elapsed_ms(started))
          response
        rescue TimeoutError, TransportError, HttpError => error
          retryable = !error.is_a?(HttpError) || [502, 503, 504].include?(error.response.status)
          if retryable && attempts < 2
            instrument("retry", path, attempts: attempts)
            retry
          end
          instrument("failure", path, attempts: attempts, error: error.class.name.split("::").last)
          raise
        rescue InvalidResponseError
          instrument("invalid_response", path, attempts: attempts)
          raise
        end
      end

      private

      attr_reader :configuration, :transport

      def public_cache_key(path, uri, headers)
        return nil unless ENV.fetch("PARTILPROVA_PUBLIC_CACHE_ENABLED", "false") == "true"
        return nil unless path.to_s == "events" && headers.to_h.empty?
        require "digest"
        "partilprova:atlas:public:v1:#{cache_generation}:#{Digest::SHA256.hexdigest(uri.to_s)}"
      end

      # Increment this token on publication changes to invalidate prior discovery entries.
      # Never include secrets or raw user data in cache keys.
      def cache_generation
        value = ENV.fetch("PARTILPROVA_PUBLIC_CACHE_GENERATION", "1")
        value.match?(/\A[a-zA-Z0-9_-]{1,40}\z/) ? value : "1"
      end

      def public_cache_ttl
        [[Integer(ENV.fetch("PARTILPROVA_PUBLIC_CACHE_TTL", "60")), 1].max, 300].min
      rescue ArgumentError, TypeError
        60
      end

      def elapsed_ms(started)
        ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000).round
      end

      def instrument(outcome, path, **payload)
        ActiveSupport::Notifications.instrument("atlas_public_api.partilprova", {
          outcome: outcome, endpoint: path.to_s.split("/").first.to_s
        }.merge(payload))
      end


      def build_uri(path, params)
        uri = configuration.uri_for(path)
        query = normalize_params(params)
        uri.query = URI.encode_www_form(query) if query.any?
        uri
      end

      def normalize_params(params)
        params.each_with_object([]) do |(key, value), pairs|
          next if value.nil?

          Array(value).each { |item| pairs << [key.to_s, item] }
        end
      end

      def stringify_headers(headers)
        headers.to_h.transform_keys(&:to_s).transform_values(&:to_s)
      end

      def build_response(raw_response)
        body = raw_response.body.to_s
        Response.new(
          status: raw_response.code.to_i,
          headers: response_headers(raw_response),
          data: parse_body(body),
          raw_body: body
        )
      end

      def response_headers(raw_response)
        raw_response.each_header.to_h
      end

      def parse_body(body)
        return nil if body.blank?

        JSON.parse(body)
      rescue JSON::ParserError => error
        raise InvalidResponseError, "Atlas Public API returned invalid JSON: #{error.message}"
      end
    end
  end
end
