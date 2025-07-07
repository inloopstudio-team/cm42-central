class HealthController < ApplicationController
  skip_before_action :authenticate_user!, if: :user_signed_in?
  
  def show
    render json: { status: 'ok', timestamp: Time.current }, status: :ok
  end
end