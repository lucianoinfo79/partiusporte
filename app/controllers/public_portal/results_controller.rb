module PublicPortal
  class ResultsController < BaseController
    def index
      @lookup = true
    end

    def show
      @results = Partilprova::PublicPortal::RaceResults.new.call(
        event_identifier: params[:id], q: params[:q],
        category: params[:category], page: params[:page]
      )
      render status: :not_found if @results.not_found?
    end
  end
end
