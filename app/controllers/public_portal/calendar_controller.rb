module PublicPortal
  class CalendarController < BaseController
    def show
      @calendar = Partilprova::PublicPortal::EventCalendar.new.call(
        month: params[:month], date: params[:date], modality: params[:modality],
        city: params[:city], status: params[:status]
      )
    end
  end
end
