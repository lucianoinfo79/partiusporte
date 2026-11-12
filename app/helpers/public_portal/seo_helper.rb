require "uri"
require "json"

module PublicPortal
  module SeoHelper
    DEFAULT_DESCRIPTION = "Encontre eventos esportivos, inscrições, resultados e fotos no partiusporte.".freeze

    def pp_seo_title
      title = content_for(:title).to_s.strip
      title.present? ? title : "partiusporte — Encontre seu próximo evento esportivo"
    end

    def pp_seo_description
      text = content_for(:seo_description).to_s.strip
      (text.presence || DEFAULT_DESCRIPTION).gsub(/\s+/, " ").first(160)
    end

    def pp_seo_base_url
      value = ENV.fetch("PARTILPROVA_PUBLIC_BASE_URL", "").to_s.strip
      uri = URI.parse(value)
      return unless uri.is_a?(URI::HTTPS) && uri.host.present? &&
                    uri.userinfo.nil? && uri.query.nil? && uri.fragment.nil? &&
                    uri.path.to_s.in?(["", "/"])
      "https://#{uri.host.downcase}#{uri.port == 443 ? '' : ":#{uri.port}"}"
    rescue URI::InvalidURIError
      nil
    end

    def pp_seo_canonical
      base = pp_seo_base_url
      return unless base
      path = request.path
      return unless path.start_with?("/") && !path.start_with?("//")
      base + path
    end

    def pp_seo_noindex?
      content_for(:seo_noindex).to_s == "true" ||
        request.query_string.present? ||
        pp_seo_base_url.nil?
    end

    def pp_seo_image
      candidate = content_for(:seo_image).to_s
      uri = URI.parse(candidate)
      return unless uri.is_a?(URI::HTTPS) && uri.host.present? && uri.userinfo.nil?
      uri.to_s
    rescue URI::InvalidURIError
      nil
    end

    def pp_seo_json_ld
      content_for(:seo_json_ld)
    end
  end
end
