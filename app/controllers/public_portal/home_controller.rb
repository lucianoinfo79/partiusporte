module PublicPortal
  class HomeController < BaseController
    def show
      @discovery = Partilprova::PublicPortal::HomeDiscovery.new.call(
        query: params[:q], modality: params[:modality]
      )
    end
  end
end
