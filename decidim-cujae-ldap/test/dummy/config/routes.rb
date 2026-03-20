Rails.application.routes.draw do
  mount Decidim::AuthLdap::Engine => "/decidim-cujae-ldap"
end
