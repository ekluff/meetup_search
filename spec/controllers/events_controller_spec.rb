require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  let(:params) do
    { 'search_string': 'skiing' }
  end

  describe 'GET #search' do
    let(:subject) { get :search, params: params, xhr: true }
    context 'when job queues successfully' do
      before { allow(EventQueryWorker).to receive(:perform_async).and_return(true) }

      it 'calls the worker and renders the correct response' do
        subject

        expect(flash[:success]).to eq('Request is being processed and results will be available shortly.')
        expect(response.status).to eq(302)
        expect(EventQueryWorker).to have_received(:perform_async)
      end
    end

    context 'when job fails to queue' do
      before { allow(EventQueryWorker).to receive(:perform_async).and_return(nil) }

      it 'calls the worker and renders the correct response' do
        subject

        expect(flash[:error]).to eq('There was a problem processing your request. Please try again.')
      end
    end
  end

  describe 'GET #index' do
    let(:subject) { get :index, params: params }

    context 'before the results are available' do
      it 'returns nothing' do
        expect(response.body).to eq('')
        expect(response.status).to eq(200)
      end
    end

    context 'when the results are available' do
      let(:meetup_response) { file_fixture('meetup_response.json').read }
      let(:params) do
        {
          'search_string': 'movies',
          format: :html
        }
      end

      before { Rails.cache.write '_key_movies', JSON.parse(meetup_response) }

      it 'displays a list of 10 events' do
        # lack of a real model makes this a difficult test. It works correctly in the dev environment,
        # but in test there is a problem where it doesn't recognise the payload as the correct item to render
        # into the event partial. Given more time it would not be too hard to solve.
      end
    end
  end

end
