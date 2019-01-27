require 'rails_helper'

RSpec.describe EventQueryWorker, type: :worker do
  let(:worker) { EventQueryWorker.new }
  let(:query_string) { 'skiing' }
  let(:subject) { worker.perform query_string }
  let(:meetup_response) { file_fixture('meetup_response.json').read }

  let!(:stub) { stub_request(:get, /https:\/\/api\.meetup\.com\/2\/open_events/)
    .with(query: hash_including({ text: query_string }))
    .to_return(status: 200, body: meetup_response) }
  let!(:stub2) { stub_request(:get, /https:\/\/api\.meetup\.com\/2\/open_events/)
    .with(query: hash_excluding({ text: query_string }))
    .to_return(status: 200, body: meetup_response) }

  before do
    Rails.cache.clear
    subject
  end

  it 'calls the Meetup API and caches the results' do
    expect(stub).to have_been_requested
    expect(Rails.cache.read "_key_#{query_string}").to match(JSON.parse(meetup_response))
  end

  context 'when reusing a prior query' do
    # It's tempting to use timecop to test the five minute window, but we shouldn't
    # do that because we set Redis to expire the cache and we don't want to test the framework
    it 'it does not call the API if value is already cached' do
      subject
      expect(stub).to have_been_requested.once
    end
  end

  context 'when query_string is nil' do
    let(:query_string) { nil }

    it 'works' do
      expect(stub2).to have_been_requested
    end
  end
end
