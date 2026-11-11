module PublicPortal
  class SeoController < BaseController
    def robots
      base = helpers.pp_seo_base_url
      lines = ["User-agent: *", base ? "Allow: /" : "Disallow: /"]
      lines << "Sitemap: #{base}/sitemap.xml" if base
      render plain: lines.join("\n") + "\n", content_type: "text/plain"
    end

    def sitemap
      base = helpers.pp_seo_base_url
      return head :not_found unless base

      paths = [root_path, public_events_path, public_calendar_path, public_results_path, public_photos_path]
      @urls = paths.map { |path| "#{base}#{path}" }
      response.headers["Cache-Control"] = "public, max-age=3600"
      render formats: [:xml]
    end
  end
end
