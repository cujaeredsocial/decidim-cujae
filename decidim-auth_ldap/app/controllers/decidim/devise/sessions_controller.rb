# frozen_string_literal: true

module Decidim
  module Devise
    class SessionsController < ::Devise::SessionsController
      include Decidim::DeviseControllers

      before_action :check_sign_in_enabled, only: :create

      def create
        if Decidim::AuthLdap.ldap_enabled?
          ldap_auth_flow and return
        end

        super
      end

      private

      def ldap_auth_flow
        email = params.dig(:user, :email)
        password = params.dig(:user, :password)

        return super unless email.present? && password.present?

        ldap_user = Decidim::AuthLdap::LdapAuthenticator.authenticate(email, password)

        return super unless ldap_user

        user = find_or_create_ldap_user(ldap_user)

        sign_in(:user, user)
        redirect_to after_sign_in_path_for(user)
      end

      def find_or_create_ldap_user(data)
        user = Decidim::User.find_by(
          email: data[:email],
          organization: current_organization
        )

        return user if user

        user = Decidim::User.new(
          email: data[:email],
          name: data[:name],
          nickname: Decidim::UserBaseEntity.nicknamize(data[:name], current_organization.id),
          password: Devise.friendly_token[0, 20],
          organization: current_organization,
          tos_agreement: true,
          accepted_tos_version: current_organization.tos_version,
          locale: I18n.locale
        )

        assign_roles_from_ldap(user, data[:groups])

        user.save!
        user
      end

      def assign_roles_from_ldap(user, groups)
        return unless groups

        if groups.include?(Decidim::AuthLdap.admin_group)
          user.admin = true
        elsif groups.include?(Decidim::AuthLdap.moderator_group)
          user.roles = ["moderator"]
        end
      end

      def check_sign_in_enabled
        redirect_to new_user_session_path unless current_organization.sign_in_enabled?
      end
    end
  end
end