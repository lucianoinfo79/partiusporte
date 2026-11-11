require "rails_helper"

RSpec.describe "PP02.10 SEO and discoverability", type: :request do
  around do |example|
    old = ENV["PARTILPROVA_PUBLIC_BASE_URL"]
    ENV["PARTILPROVA_PUBLIC_BASE_URL"] = "https://partilprova.com.br"
    example.run
  ensure
    ENV["PARTILPROVA_PUBLIC_BASE_URL"] = old
  end

  it "renders metadata and canonical on the public home" do
    get "/"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('name="description"', 'property="og:title"')
    expect(response.body).to include('rel="canonical" href="https://partilprova.com.br/"')
  end

  it "noindexes filtered pages without including query parameters in canonical" do
    get "/eventos", params: { q: "corrida" }
    expect(response.body).to include('content="noindex,follow"')
    expect(response.body).to include('rel="canonical" href="https://partilprova.com.br/eventos"')
  end

  it "serves sitemap and robots" do
    get "/sitemap.xml"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("https://partilprova.com.br/eventos")
    get "/robots.txt"
    expect(response.body).to include("Sitemap: https://partilprova.com.br/sitemap.xml")
  end

  it "does not index without an explicitly configured canonical host" do
    ENV.delete("PARTILPROVA_PUBLIC_BASE_URL")
    get "/"
    expect(response.body).to include('content="noindex,follow"')
    expect(response.body).not_to include('rel="canonical"')
    get "/sitemap.xml"
    expect(response).to have_http_status(:not_found)
  end
end
