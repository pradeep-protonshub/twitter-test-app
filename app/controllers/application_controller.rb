class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  respond_to :json,:html

  # before_action :underscore_params!̣
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user

  include ActionController::HttpAuthentication::Token::ControllerMethods
  include ActionView::Rendering
	
	private

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :username
  end

  def authenticate_user
    if request.headers['Authorization'].present?
      authenticate_or_request_with_http_token do |token|
        begin
          jwt_payload = JWT.decode(token, Rails.application.credentials.secret_key_base).first

          @current_user_id = jwt_payload['id']
        rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
          render json: { message: 'JWT Token Expired' }, status: 401
        end
      end
    end
  end

  def authenticate_user!(options = {})
    head :unauthorized unless signed_in?
  end

  def current_user
    @current_user ||= super || User.where(id: @current_user_id).first
  end

  def signed_in?
    @current_user_id.present?
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end
end
