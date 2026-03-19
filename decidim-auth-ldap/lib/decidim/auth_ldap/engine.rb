# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module AuthLdap
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::AuthLdap

      routes do
        # Add any additional routes if needed
      end

      initializer "decidim_auth_ldap.override_controllers" do
        config.to_prepare do
          # Override Devise controllers
          Decidim::Devise::SessionsController.include(Decidim::AuthLdap::OverrideSessionsController)
          Decidim::Devise::RegistrationsController.include(Decidim::AuthLdap::OverrideRegistrationsController)
          Decidim::Devise::PasswordsController.include(Decidim::AuthLdap::OverridePasswordsController)
        end
      end

      initializer "decidim_auth_ldap.configure_warden" do
        config.to_prepare do
          Warden::Strategies.add(:ldap_authenticatable, Decidim::AuthLdap::LdapStrategy)
        end
      end
    end
  end
end