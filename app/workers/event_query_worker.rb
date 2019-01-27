class EventQueryWorker
  include Sidekiq::Worker

  CITY = 'München'
  COUNTRY = 'DE'
  PAGE = 10
  # Authenticating against the API with a personal key rather than a more complex oauth flow
  # You'll need to write your own key into the encrypted credentials file. See README
  KEY = Rails.application.credentials.meetup[:api_key]

  def perform(query_string)
    return if Rails.cache.read cache_key(query_string)
    query_and_cache query_string
  end

  private

  # this is necessary so that there is a key even if there is no input
  def cache_key(query_string)
    "_key_#{query_string}"
  end

  # This uses the v2 open_events endpoint on the Meetup API. This is the only endpoint
  # of the API that allows searching of events directly by location. To use the V3 events
  # endpoint, it would be necessary to first search groups by location and then retrieve
  # events belonging to those groups. I didn't see any information about an
  # include directive being available to sideload events with groups.
  def query_and_cache(query_string)
    uri = 'https://api.meetup.com/2/open_events'
    params = params(query_string)
    response = Faraday.get uri, params

    if response.success?
      Rails.cache.write cache_key(query_string), JSON.parse(response.body)
    else
      # In a real app we would want to put care into error handling
      # Here the idea is to recognize this is a place that would need error handling
      raise "Network error"
    end
  end

  # removes 'text' if query_string is nil
  def params(query_string)
    { text: query_string, city: CITY, country: COUNTRY, key: KEY }.compact
  end
end
