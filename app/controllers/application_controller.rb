class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :nickname ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :nickname ])
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || dashboard_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end

  helper_method :current_household

  def current_household
    return nil unless current_user
    @current_household ||= current_user.households.order(:id).first
  end

  private

  def render_not_found
    respond_to do |format|
      format.html { render file: Rails.root.join("public/404.html"), status: :not_found, layout: false }
      format.json { render json: { error: "not_found" }, status: :not_found }
    end
  end
end
