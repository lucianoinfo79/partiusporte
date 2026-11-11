require "rails_helper"

RSpec.describe "PP02.12 public journey regression", type: :request do
  around do |example|
    previous = ENV["PARTILPROVA_PUBLIC_BASE_URL"]
    ENV["PARTILPROVA_PUBLIC_BASE_URL"] = "https://partilprova.com.br"
    example.run
  ensure
    ENV["PARTILPROVA_PUBLIC_BASE_URL"] = previous
  end

  it "exposes the public entry points and canonical SEO" do
    { "/" => "/", "/eventos" => "/eventos", "/resultados" => "/resultados", "/fotos" => "/fotos" }.each do |path, canonical|
      get path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('rel="canonical" href="https://partilprova.com.br' + canonical + '"')
    end
  end

  it "does not index filtered catalog pages or disclose the search in canonical" do
    get "/eventos", params: { q: "prova privada" }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('content="noindex,follow"')
    expect(response.body).to include('rel="canonical" href="https://partilprova.com.br/eventos"')
    expect(response.body).not_to include('rel="canonical" href="https://partilprova.com.br/eventos?q=')
  end

  it "serves machine-readable discovery endpoints" do
    get "/sitemap.xml"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("https://partilprova.com.br/eventos")
    get "/robots.txt"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Sitemap: https://partilprova.com.br/sitemap.xml")
  end

  it "fails closed for SEO when the canonical host is not configured" do
    ENV.delete("PARTILPROVA_PUBLIC_BASE_URL")
    get "/"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('content="noindex,follow"')
    get "/sitemap.xml"
    expect(response).to have_http_status(:not_found)
  end
end
