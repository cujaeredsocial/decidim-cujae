# frozen_string_literal: true

module Decidim
  module Cujae
    module Ldap
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::Cujae::Ldap

        initializer "decidim_cujae_ldap.ignore_overrides" do
          Rails.autoloaders.main.ignore(
            Rails.root.join("decidim-cujae-ldap/app/overrides")
          )
        end
        
        initializer "decidim_cujae_ldap.override_models" do
          Rails.application.config.to_prepare do
            Dir.glob(Rails.root.join("decidim-cujae-ldap/app/overrides/**/*.rb")).each do |file|
              require_dependency file
            end
          end
        end
      end
    end
  end
end