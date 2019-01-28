require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  let(:params) do
    { 'search_string': 'skiing' }
  end

  describe 'POST #search' do
    let(:subject) { post :search, params: params }
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

    before { subject }

    context 'before the results are available' do
      it 'returns nothing' do
        expect(response.body).to eq('')
        expect(response.status).to eq(200)
      end
    end

    context 'when the results are available' do
      it 'displays a list of 10 events' do
        # coming back to this when I know what the payload looks like
      end
    end
  end

end
