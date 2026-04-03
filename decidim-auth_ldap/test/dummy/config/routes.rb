Rails.application.routes.draw do
  mount Decidim::AuthLdap::Engine => "/decidim-auth_ldap"
end
