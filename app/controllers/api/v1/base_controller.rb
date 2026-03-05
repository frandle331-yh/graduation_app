# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_token!

      private

      def authenticate_token!
        token = request.headers["Authorization"]&.remove("Bearer ")
        @current_user = User.active.find_by(api_token: token) if token.present?

        render json: { error: "unauthorized" }, status: :unauthorized unless @current_user
      end

      attr_reader :current_user

      def current_household
        @current_household ||= current_user.households.order(:id).first
      end
    end
  end
end
