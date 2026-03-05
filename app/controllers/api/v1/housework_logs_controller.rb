# frozen_string_literal: true

module Api
  module V1
    class HouseworkLogsController < BaseController
      def index
        logs = current_user.housework_logs
                           .order(performed_on: :desc, created_at: :desc)

        logs = logs.where(category: params[:category]) if params[:category].present?
        logs = logs.where(performed_on: params[:from]..) if params[:from].present?
        logs = logs.where(performed_on: ..params[:to]) if params[:to].present?

        logs = logs.limit(params.fetch(:limit, 20).to_i.clamp(1, 100))
                   .offset(params.fetch(:offset, 0).to_i)

        render json: logs.map { |log| serialize_log(log) }
      end

      def show
        log = current_user.housework_logs.find(params[:id])
        render json: serialize_log(log)
      end

      def create
        log = current_user.housework_logs.build(log_params)
        log.household = current_household

        if log.save
          render json: serialize_log(log), status: :created
        else
          render json: { errors: log.errors.full_messages }, status: :unprocessable_content
        end
      end

      private

      def log_params
        params.require(:housework_log).permit(:title, :category, :performed_on, :minutes, :memo)
      end

      def serialize_log(log)
        {
          id: log.id,
          title: log.title,
          category: log.category,
          performed_on: log.performed_on,
          minutes: log.minutes,
          memo: log.memo,
          thanks_count: log.thanks_count,
          created_at: log.created_at
        }
      end
    end
  end
end
