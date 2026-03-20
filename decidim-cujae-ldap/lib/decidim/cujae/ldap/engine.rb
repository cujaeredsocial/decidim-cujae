# frozen_string_literal: true

module Decidim
  module Cujae
    module Ldap
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::Cujae::Ldap

        initializer "decidim_cujae_ldap.override_models" do
          ActiveSupport.on_load(:active_record) do
            require_relative "../../app/overrides/user_override"
          end
        end
      end
    end
  end
end