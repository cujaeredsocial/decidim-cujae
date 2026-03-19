# frozen_string_literal: true

require "decidim/auth_ldap/engine"
require "decidim/auth_ldap/version"

module Decidim
  module AuthLdap
    autoload :LdapAuthenticator, "decidim/auth_ldap/ldap_authenticator"
    autoload :LdapStrategy, "decidim/auth_ldap/ldap_strategy"

    mattr_accessor :ldap_enabled
    mattr_accessor :host
    mattr_accessor :port
    mattr_accessor :encryption
    mattr_accessor :base_dn
    mattr_accessor :groups_base_dn
    mattr_accessor :uid
    mattr_accessor :email_attribute
    mattr_accessor :name_attribute
    mattr_accessor :user_attributes
    mattr_accessor :ldap_groups
    mattr_accessor :admin_group
    mattr_accessor :moderator_group
    mattr_accessor :disable_registration
    mattr_accessor :role_mapping

    def self.configure
      yield self
    end

    def self.config
      {
        ldap_enabled: ldap_enabled,
        host: host,
        port: port,
        encryption: encryption,
        base_dn: base_dn,
        groups_base_dn: groups_base_dn,
        uid: uid,
        email_attribute: email_attribute,
        name_attribute: name_attribute,
        user_attributes: user_attributes,
        ldap_groups: ldap_groups,
        admin_group: admin_group,
        moderator_group: moderator_group,
        disable_registration: disable_registration,
        role_mapping: role_mapping
      }
    end
  end
end