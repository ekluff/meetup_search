class EventQueryWorker
  include Sidekiq::Worker

  CITY = 'München'
  COUNTRY = 'DE'
  PAGE = 10
  # Authenticating against the API with a personal key rather than a more complex oauth flow
  # You'll need to write your own key into the encrypted credentials file. See README
  KEY = Rails.application.credentials.meetup[:api_key]

  def perform(search_string)
    return if Rails.cache.read cache_key(search_string)
    query_and_cache search_string
  end

  private

  # this is necessary so that there is a key even if there is no input
  # unlikely but possible
  # validation on the form input would make this unnecessary
  def cache_key(search_string)
    "_key_#{search_string}"
  end

  # This uses the v2 open_events endpoint on the Meetup API. This is the only endpoint
  # of the API that allows searching of events directly by location. To use the V3 events
  # endpoint, it would be necessary to first search groups by location and then retrieve
  # events belonging to those groups. I didn't see any information about an
  # include directive being available to sideload events with groups.
  #
  # A known issue here is that the instructions for this challenge mention viewing past events.
  # The docs say it is possible to view both upcoming and past events with the
  # value 'status=past,upcoming', however, this is incorrect. The endpoint appears to
  # require only one value or the other, despite what the docs say.
  #
  # One simple improvement would be to use a fields directive to only load the
  # five fields we are using.
  def query_and_cache(search_string)
    uri = 'https://api.meetup.com/2/open_events'
    params = params(search_string)
    response = Faraday.get uri, params

    if response.success?
      Rails.cache.write cache_key(search_string), JSON.parse(response.body)
    else
      # In a real app we would want to put care into error handling
      # Here the idea is to recognize this is a place that would need error handling
      # because of the dependency on an external service over the open internet
      raise "Network error"
    end
  end

  # removes 'text' if search_string is nil
  def params(search_string)
    { text: search_string, city: CITY, country: COUNTRY, key: KEY }.compact
  end
end
