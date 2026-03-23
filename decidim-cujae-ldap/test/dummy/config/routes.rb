Rails.application.routes.draw do
  mount Decidim::Cujae::Ldap::Engine => "/decidim-cujae-ldap"
end
