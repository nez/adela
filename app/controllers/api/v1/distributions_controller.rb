module Api
  module V1
    class DistributionsController < Api::V1::ApiController
      def show
        @distribution = Distribution.find(params[:id])
        render json: @distribution
      end
    end
  end
end

