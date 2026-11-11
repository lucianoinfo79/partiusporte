# frozen_string_literal: true
# PP04.3 — HTTP gallery contract probe; no database writes.
require "net/http"
require "uri"
require "json"
require "openssl"

class PP043GalleryProbe
  def initialize
    @slug = ARGV.fetch(0, "evento-oportunidade-teste")
    @atlas = ENV.fetch("PP043_ATLAS_ORIGIN", "http://host.docker.internal:3000").sub(%r{/+$}, "")
    @portal = ENV.fetch("PP043_PORTAL_ORIGIN", "http://localhost:3000").sub(%r{/+$}, "")
    @checks = []
  end

  def check(name, state, detail)
    @checks << { check: name, state: state, detail: detail.to_s[0, 350] }
  end

  def get(url)
    uri = URI.parse(url)
    raise ArgumentError, "Only HTTP(S) supported" unless %w[http https].include?(uri.scheme)
    req = Net::HTTP::Get.new(uri)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 6, read_timeout: 30) do |http|
      http.request(req)
    end
  end

  def run
    endpoint = "#{@atlas}/api/public/v1/eventos/#{URI.encode_www_form_component(@slug)}/photos"
    response = get(endpoint)
    check("atlas_gallery_http", response.code == "200" ? "PASS" : "FAIL", "HTTP #{response.code}")
    return finish unless response.code == "200"

    payload = JSON.parse(response.body)
    data = payload.fetch("data", {})
    photos = data.fetch("photos", [])
    meta = payload.fetch("meta", {})
    check("atlas_gallery_envelope", data.is_a?(Hash) && photos.is_a?(Array) && data["published"] == true ? "PASS" : "FAIL", "published=#{data['published'].inspect} photos=#{photos.size} total=#{meta['total'].inspect}")
    check("gallery_has_photo", photos.any? ? "PASS" : "PENDING", "returned=#{photos.size}")
    check("gallery_no_store", response["cache-control"].to_s.include?("no-store") ? "PASS" : "FAIL", response["cache-control"].inspect)
    return finish if photos.empty?

    photo = photos.first
    preview_url = photo["preview_url"].to_s
    preview = URI.parse(preview_url)
    check("preview_https_browser", preview.is_a?(URI::HTTPS) ? "PASS" : "PENDING", "scheme=#{preview.scheme.inspect}; PartilProva rejects non-HTTPS preview URLs")
    check("preview_no_private_identifiers", (photo.keys & %w[photo_id edition_id registration_id original_url original_filename sha256]).empty? ? "PASS" : "FAIL", "public_photo_fields=#{photo.keys.sort.join(',')}")
    valid_preview_host = preview.host == URI.parse(@atlas).host
    check("preview_host", valid_preview_host ? "PASS" : "FAIL", "preview_host=#{preview.host.inspect} atlas_host=#{URI.parse(@atlas).host.inspect}")
    return finish unless valid_preview_host

    protected = get(preview_url)
    mime = protected["content-type"].to_s
    image_signature = protected.body.start_with?("\xFF\xD8".b) || protected.body.start_with?("\x89PNG".b) || protected.body.start_with?("RIFF".b)
    check("signed_preview_delivery", protected.code == "200" && mime.start_with?("image/") && image_signature ? "PASS" : "FAIL", "HTTP #{protected.code} content-type=#{mime} bytes=#{protected.body.bytesize} signature=#{image_signature}")
    check("preview_private_no_store", protected["cache-control"].to_s.include?("no-store") ? "PASS" : "FAIL", protected["cache-control"].inspect)

    unsigned = preview.dup
    unsigned.query = URI.decode_www_form(unsigned.query.to_s).reject { |k, _| k == "token" }.then { |params| URI.encode_www_form(params) }
    unsigned_response = get(unsigned.to_s)
    check("unsigned_preview_denied", unsigned_response.code == "404" ? "PASS" : "FAIL", "HTTP #{unsigned_response.code}")

    token_pairs = URI.decode_www_form(preview.query.to_s)
    if token_pairs.any? { |key, _| key == "token" }
      tampered = preview.dup
      tampered.query = URI.encode_www_form(token_pairs.map { |k, v| [k, k == "token" ? "tampered-pp043" : v] })
      tampered_response = get(tampered.to_s)
      check("tampered_preview_denied", tampered_response.code == "404" ? "PASS" : "FAIL", "HTTP #{tampered_response.code}")
    else
      check("token_present", "FAIL", "preview_url has no token")
    end

    portal_url = "#{@portal}/eventos/#{URI.encode_www_form_component(@slug)}/photos"
    begin
      portal_response = get(portal_url)
      check("portal_gallery_http", portal_response.code == "200" ? "PASS" : "FAIL", "HTTP #{portal_response.code} URL=#{portal_url}")
      if portal_response.code == "200"
        body = portal_response.body
        check("portal_image_markup", body.include?("Prévia protegida de foto da prova") ? "PASS" : "PENDING", "img alt present=#{body.include?('Prévia protegida de foto da prova')}")
        check("portal_empty_state", body.include?("Nenhuma foto publicada para esta prova.") ? "PENDING" : "PASS", "empty_gallery_message=#{body.include?('Nenhuma foto publicada para esta prova.')}")
      end
    rescue StandardError => e
      check("portal_gallery_http", "PENDING", "#{e.class}: #{e.message}")
    end
    finish
  rescue StandardError => e
    check("probe_execution", "FAIL", "#{e.class}: #{e.message}")
    finish
  end

  def finish
    counts = @checks.group_by { |c| c[:state] }.transform_values(&:size)
    puts JSON.pretty_generate(construction: "PP04.3", slug: @slug, atlas_origin: @atlas, portal_origin: @portal, checks: @checks, summary: counts, note: "Read-only HTTP probe; visual inspection and expiry timing require separate verification.")
    exit(counts.fetch("FAIL", 0).positive? ? 1 : (counts.fetch("PENDING", 0).positive? ? 2 : 0))
  end
end

PP043GalleryProbe.new.run
