class EventsController < ApplicationController
  # a known problem with this design is that if the user tries to request the index
  # action with a query string that has not previously been sent through the search
  # action, the index page will keep polling and the event query worker will never trigger
  def index
    # in a more complex app the generation of this cache key could be put into some sort of helper or decorator
    # possible refactor: only cache the results part of the API response
    cached_response = Rails.cache.read("_key_#{event_params[:search_string]}") || {}
    # This filtering should probably go in the worker
    # The 'take' is only necessary because Meetup's API takes page values as a suggestion
    # and may return more than the number you specify
    @events = cached_response["results"].try(:take, 10)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def search
    query = EventQueryWorker.perform_async(event_params[:search_string])

    if query
      flash[:success] = 'Request is being processed and results will be available shortly.'
      redirect_to action: 'index', search_string: event_params[:search_string]
    else
      flash[:error] = 'There was a problem processing your request. Please try again.'
    end
  end

  private

  def event_params
    params.permit(:search_string)
  end
end
