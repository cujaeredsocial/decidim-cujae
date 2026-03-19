# frozen_string_literal: true

module Decidim
  module Devise
    class RegistrationsController < ::Devise::RegistrationsController
      include FormFactory
      include Decidim::DeviseControllers
      include NeedsTosAccepted

      helper Decidim::PasswordsHelper

      before_action :check_sign_up_enabled
      before_action :configure_permitted_parameters
      before_action :check_ldap_registration, only: [:new, :create]

      invisible_captcha

      def new
        if ldap_registration_disabled?
          redirect_to new_user_session_path, alert: t("decidim.auth_ldap.registrations.disabled")
          return
        end
        
        @form = form(RegistrationForm).from_params(
          user: { sign_up_as: "user" }
        )
      end

      def create
        if ldap_registration_disabled?
          redirect_to new_user_session_path, alert: t("decidim.auth_ldap.registrations.disabled")
          return
        end
        
        @form = form(RegistrationForm).from_params(params[:user].merge(current_locale:))

        CreateRegistration.call(@form) do
          on(:ok) do |user|
            if user.active_for_authentication?
              set_flash_message! :notice, :signed_up
              sign_up(:user, user)
              respond_with user, location: after_sign_up_path_for(user)
            else
              set_flash_message! :notice, :"signed_up_but_#{user.inactive_message}"
              expire_data_after_sign_in!
              respond_with user, location: after_inactive_sign_up_path_for(user)
            end
          end

          on(:invalid) do
            flash.now[:alert] = t("error", scope: "decidim.devise.registrations.create")
            render :new
          end
        end
      end

      protected

      def check_sign_up_enabled
        redirect_to new_user_session_path unless current_organization.sign_up_enabled?
      end

      def check_ldap_registration
        if ldap_enabled? && ldap_registration_disabled?
          redirect_to new_user_session_path, alert: t("decidim.auth_ldap.registrations.disabled")
        end
      end

      def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :tos_agreement])
      end

      def build_resource(hash = nil)
        super
        resource.organization = current_organization
      end

      def devise_mapping
        ::Devise.mappings[:user]
      end

      private

      def ldap_enabled?
        Decidim::AuthLdap.ldap_enabled?
      end

      def ldap_registration_disabled?
        Decidim::AuthLdap.disable_registration?
      end
    end
  end
end