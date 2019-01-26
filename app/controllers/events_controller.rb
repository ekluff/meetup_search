class EventsController < ApplicationController
  def index
    # this won't work for an empty query
    if @events = Rails.cache.read(event_params[:query_string])
      render @events
    else
      head :ok
    end
  end

  def search
    query = EventQueryWorker.perform_async(event_params)

    if query
      flash[:success] = 'Request is being processed and results will be available shortly.'
      # using redirect instead of render so the user can refresh the page after searching without resubmitting the form
      redirect_to action: 'index', query_string: event_params[:query_string]
    else
      flash[:error] = 'There was a problem processing your request. Please try again.'
      head :internal_server_error
    end
  end

  private

  def event_params
    params.permit(:query_string)
  end
end
