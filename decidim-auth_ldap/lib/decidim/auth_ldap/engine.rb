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

      initializer "decidim_auth_ldap.configure_warden" do
        config.to_prepare do
          Warden::Strategies.add(:ldap_authenticatable, Decidim::AuthLdap::LdapStrategy)
        end
      end

      initializer "decidim_auth_ldap.add_view_paths" do |app|
        app.config.paths["app/views"].unshift(
          Decidim::AuthLdap::Engine.root.join("app/views").to_s
        )
      end
    end
  end
end