# frozen_string_literal: true

module Decidim
  module Devise
    # Custom Devise PasswordsController to avoid namespace problems.
    class PasswordsController < ::Devise::PasswordsController
      include Decidim::DeviseControllers

      helper Decidim::PasswordsHelper

      prepend_before_action :require_no_authentication, except: [:change_password, :apply_password]
      skip_before_action :store_current_location

      before_action :check_sign_in_enabled
      before_action :check_ldap_password_change, only: [:change_password, :apply_password]

      def change_password
        if ldap_user?
          redirect_to after_sign_in_path_for(current_user), alert: t("decidim.auth_ldap.passwords.cannot_change")
          return
        end
        
        self.resource = current_user
        @send_path = apply_password_path

        flash[:secondary] = t("decidim.admin.password_change.notification", days: Decidim.config.admin_password_expiration_days) if flash[:secondary].blank?
        render :edit
      end

      def apply_password
        if ldap_user?
          redirect_to after_sign_in_path_for(current_user), alert: t("decidim.auth_ldap.passwords.cannot_change")
          return
        end
        
        self.resource = current_user
        @send_path = apply_password_path

        @form = Decidim::PasswordForm.from_params(params["user"]).with_context(current_user:)
        Decidim::UpdatePassword.call(@form) do
          on(:ok) do
            flash[:notice] = t("passwords.update.success", scope: "decidim")
            bypass_sign_in(current_user)
            redirect_to after_sign_in_path_for current_user
          end

          on(:invalid) do
            flash.now[:alert] = t("passwords.update.error", scope: "decidim")
            resource.errors.errors.concat(@form.errors.errors)
            render action: "edit"
          end
        end
      end

      private

      def check_sign_in_enabled
        redirect_to new_user_session_path unless current_organization.sign_in_enabled?
      end

      def check_ldap_password_change
        if ldap_user? && request.method == "GET"
          redirect_to after_sign_in_path_for(current_user), alert: t("decidim.auth_ldap.passwords.cannot_change")
        end
      end

      def ldap_user?
        return false unless current_user
        # Check if user was created via LDAP or has LDAP authentication
        current_user.ldap_authenticated? || current_user.extended_data&.dig("ldap_authenticated")
      end

      def resource_params
        super.merge(decidim_organization_id: current_organization.id)
      end
    end
  end
end