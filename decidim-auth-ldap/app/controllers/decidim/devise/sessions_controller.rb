# frozen_string_literal: true

module Decidim
  module Devise
    # Custom Devise SessionsController with LDAP authentication
    class SessionsController < ::Devise::SessionsController
      include Decidim::DeviseControllers
      include Decidim::DeviseAuthenticationMethods

      before_action :check_sign_in_enabled, only: :create
      before_action :check_ldap_enabled, only: :create

      def create
        #check if LDAP is enabled and user exists in LDAP
        if ldap_enabled? && params[:user][:email].present?
          ldap_user = Decidim::AuthLdap::LdapAuthenticator.authenticate(
            params[:user][:email],
            params[:user][:password]
          )

          if ldap_user
            #user authenticated via LDAP
            user = find_or_create_ldap_user(ldap_user)
            
            if user&.valid_password?(params[:user][:password])
              # Sign in the user
              sign_in(:user, user)
              respond_with user, location: after_sign_in_path_for(user)
              return
            end
          end
        end

        # Fall back to normal devise authentication
        super do |user|
          if user.admin?
            validator = PasswordValidator.new({ attributes: :password })
            user.update!(password_updated_at: nil) unless validator.validate_each(user, :password, sign_in_params[:password])
          end

          store_onboarding_cookie_data!(user)
        end
      end

      def destroy
        current_user.invalidate_all_sessions! if current_user
        if params[:translation_suffix].present?
          super { set_flash_message! :notice, params[:translation_suffix], { scope: "decidim.devise.sessions" } }
        else
          super
        end
      end

      def after_sign_out_path_for(user)
        request.referer || super
      end

      private

      def check_sign_in_enabled
        redirect_to new_user_session_path unless current_organization.sign_in_enabled?
      end

      def check_ldap_enabled
        return if Decidim::AuthLdap.ldap_enabled?
        
        # If LDAP is not enabled, continue with normal flow je
        true
      end

      def ldap_enabled?
        Decidim::AuthLdap.ldap_enabled?
      end

      def find_or_create_ldap_user(ldap_user_data)
        user = User.find_by(email: ldap_user_data[:email], organization: current_organization)
        
        unless user
          user = User.new(
            email: ldap_user_data[:email],
            name: ldap_user_data[:name],
            nickname: UserBaseEntity.nicknamize(ldap_user_data[:name], current_organization.id),
            password: params[:user][:password],
            password_updated_at: Time.current,
            organization: current_organization,
            tos_agreement: true,
            accepted_tos_version: current_organization.tos_version,
            locale: I18n.locale
          )
          
          user.admin = true if ldap_user_data[:groups]&.include?(Decidim::AuthLdap.admin_group)
          user.roles = ldap_user_data[:roles] if ldap_user_data[:roles]
          
          user.save!
        end
        
        user
      end
    end
  end
end

module Decidim::AuthLdap::OverrideSessionsController
  def self.included(base)
    base.class_eval do
      alias_method :original_create, :create
      alias_method :create, :ldap_create
    end
  end

  def ldap_create
    # the logic here
    if Decidim::AuthLdap.ldap_enabled? && params[:user][:email].present?
      ldap_user = Decidim::AuthLdap::LdapAuthenticator.authenticate(
        params[:user][:email],
        params[:user][:password]
      )

      if ldap_user
        user = find_or_create_ldap_user(ldap_user)
        
        if user&.valid_password?(params[:user][:password])
          sign_in(:user, user)
          respond_with user, location: after_sign_in_path_for(user)
          return
        end
      end
    end
    
    original_create
  end

  private

  def find_or_create_ldap_user(ldap_user_data)
    user = Decidim::User.find_by(email: ldap_user_data[:email], organization: current_organization)
    
    unless user
      user = Decidim::User.new(
        email: ldap_user_data[:email],
        name: ldap_user_data[:name],
        nickname: Decidim::UserBaseEntity.nicknamize(ldap_user_data[:name], current_organization.id),
        password: params[:user][:password],
        password_updated_at: Time.current,
        organization: current_organization,
        tos_agreement: true,
        accepted_tos_version: current_organization.tos_version,
        locale: I18n.locale
      )
      
      # assign the roles based
      assign_roles_from_ldap(user, ldap_user_data[:groups])
      
      user.save!
    end
    
    user
  end

  def assign_roles_from_ldap(user, groups)
    return unless groups
    
    if groups.include?(Decidim::AuthLdap.admin_group)
      user.admin = true
    elsif groups.include?(Decidim::AuthLdap.moderator_group)
      user.roles = ['moderator']
    end
  end
end