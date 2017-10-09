require 'spec_helper'

describe Api::V1::DistributionsController do
  describe 'GET /api/v1/distributions/:id' do
    before do
      get :show, id: distribution.id, format: :json
    end

    context 'with an existing distribution' do
      let(:distribution) { create(:distribution) }

      it 'responds with HTPP Ok' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'without an existing distribution' do
      let(:distribution) { OpenStruct.new(id: 0) }

      it 'responds with HTPP Not Found' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
