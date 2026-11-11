module PublicPortal
  class EventsController < BaseController
    def show
      @detail = Partilprova::PublicPortal::EventDetail.new.call(identifier: params[:id])
      render status: :not_found if @detail.not_found?
      @registration_handoff = Partilprova::PublicPortal::RegistrationHandoff.new.call(event: @detail.event) if @detail.available?
    end

    def index
      @catalog = Partilprova::PublicPortal::EventCatalog.new.call(
        query: params[:q], modality: params[:modality], state: params[:state],
        city: params[:city], status: params[:status], order: params[:order],
        page: params[:page], from: params[:from], to: params[:to]
      )
    end
  end
end
