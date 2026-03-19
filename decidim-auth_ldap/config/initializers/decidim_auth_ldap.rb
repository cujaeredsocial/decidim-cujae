# frozen_string_literal: true

Decidim::AuthLdap.configure do |config|
  config.ldap_enabled = ENV["LDAP_ENABLED"] == "true"
  
  config.host = ENV["LDAP_HOST"] || "localhost"
  config.port = ENV["LDAP_PORT"]&.to_i || 389
  config.encryption = ENV["LDAP_ENCRYPTION"] == "true"
  
  config.base_dn = ENV["LDAP_BASE_DN"] || "dc=example,dc=com"
  config.groups_base_dn = ENV["LDAP_GROUPS_BASE_DN"] || config.base_dn
  
  config.uid = ENV["LDAP_UID"] || "uid"
  config.email_attribute = ENV["LDAP_EMAIL_ATTRIBUTE"] || "mail"
  config.name_attribute = ENV["LDAP_NAME_ATTRIBUTE"] || "cn"
  
  config.user_attributes = [config.email_attribute, config.name_attribute, "dn"]
  
  config.ldap_groups = ENV["LDAP_GROUPS"]&.split(",") || []
  config.admin_group = ENV["LDAP_ADMIN_GROUP"] || "cn=admin,ou=groups,dc=example,dc=com"
  config.moderator_group = ENV["LDAP_MODERATOR_GROUP"] || "cn=moderators,ou=groups,dc=example,dc=com"
  
  config.disable_registration = ENV["LDAP_DISABLE_REGISTRATION"] == "true"
  
  config.role_mapping = {
    "rector" => "admin",
    "vicerrector" => "admin",
    "decano" => "moderator",
    "secretario_general" => "secretary"
  }
end