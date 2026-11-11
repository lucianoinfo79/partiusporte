# frozen_string_literal: true
require 'rails_helper'
RSpec.describe 'PP-INTEGRATION.10.6 Orders registration handoff', type: :request do
  let(:event_data) do
    { name:'Homologação Orders', city:'Palmas', state:'TO', date:'2026-12-01', description:'Teste integrado',
      distances:[], routes:[], schedule:[], kit:'', organizer:'', venue:'', modality:'Corrida',
      registration_status:'open', registration_provider:'atlas',
      registration_target:'/events/event-test/editions/edition-test/register',
      image_url:nil,registration_url:nil,regulation_url:nil,results_url:nil,photos_url:nil }
  end
  before do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('PARTILPROVA_REGISTRATION_ALLOWED_HOSTS', '').and_return('atlas.example')
    allow(ENV).to receive(:fetch).with('PARTILPROVA_ATLAS_PUBLIC_ORIGIN', '').and_return('https://atlas.example')
    result=Partilprova::PublicPortal::EventDetail::Result.new(event:event_data,state: :available)
    allow_any_instance_of(Partilprova::PublicPortal::EventDetail).to receive(:call).and_return(result)
  end
  it 'renders the trusted Atlas registration route without provider credentials' do
    get '/eventos/homologacao-orders'
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('href="https://atlas.example/events/event-test/editions/edition-test/register"')
    expect(response.body).to include('Inscreva-se agora')
    expect(response.body).not_to include('api.mercadopago.com', 'APP_USR-', 'Bearer ')
  end
  it 'keeps an unavailable registration closed' do
    event_data[:registration_status]='unavailable'
    get '/eventos/homologacao-orders'
    expect(response.body).not_to include('Inscreva-se agora')
  end
  it 'does not substitute an arbitrary external path for the Atlas-issued route' do
    event_data[:registration_target]='https://evil.example/pay'
    get '/eventos/homologacao-orders'
    expect(response.body).not_to include('Inscreva-se agora','href="https://evil.example/pay"')
  end
end
