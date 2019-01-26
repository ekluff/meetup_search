class EventsController < ApplicationController
  def search
    query = EventQueryWorker.perform_async(event_params)

    if query
      flash[:success] = 'Request is being processed and results will be available shortly.'
      # using redirect instead of render so the user can refresh the page after searching without resubmitting the form
      redirect_to action: 'index', text_query: event_params[:text_query]
    else
      flash[:error] = 'There was a problem processing your request. Please try again.'
      head :internal_server_error
    end
  end

  def index
    if @events = Rails.cache.read(event_params[:text_query])
      render @events
    else
      head :ok
    end
  end

  private

  def event_params
    params.permit(:text_query)
  end
end
