module Api
  module V1
    module Users
      class SessionsController < Devise::SessionsController
        # before_action :configure_sign_in_params, only: [:create]
        include ApplicationMethods
        skip_before_action :verify_authenticity_token


        respond_to :json

        def create
          session.clear
          if params[:user][:email].present? && params[:user][:password].present? 
            user = User.where(:email => params[:user][:email]).first
            if user.nil?
              render_unprocessable_entity("Email is Invalid")
              return
            else
              if user.valid_password? params[:user][:password]
                if user.otp_verified?
                  response.set_header('Access-Control-Expose-Headers', 'Authorization')
                  super
                else
                  user.errors.add(:otp, "Is not Verified")
                  render_unprocessable_entity_response(user)
                end
              else
                user.errors.add(:password, 'Invalid password.')
                render_unprocessable_entity_response(user)
              end
            end
          else
            render_unprocessable_entity("Please provide email and password.")
          end
        end

        private

        def respond_with(resource, _opts = {})
        render_success_response({
          user: single_serializer.new(resource, serializer: Api::V1::UserSerializer)
        })
        end

        def respond_to_on_destroy
          head :no_content
        end

        protected
        def ensure_params_exist
          return unless params[:user].blank?
          render_unprocessable_entity("missing user_login parameter.")
        end

        def invalid_login_attempt
          warden.custom_failure!
          render_unprocessable_entity("Error with your login or password.")
        end

      end
    end
  end
end