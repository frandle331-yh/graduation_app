class PagesController < ApplicationController
  skip_before_action :authenticate_user!, raise: false

  def terms; end

  def privacy_policy; end
end
