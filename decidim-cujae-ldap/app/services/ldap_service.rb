# frozen_string_literal: true

require "net/ldap"

class LdapService
  def self.authenticate(login, password)
    ldap = Net::LDAP.new(
      host: ENV.fetch("LDAP_HOST"),
      port: ENV.fetch("LDAP_PORT", 389),
      auth: {
        method: :simple,
        username: login,
        password: password
      }
    )

    return unless ldap.bind

    filter = Net::LDAP::Filter.eq("mail", login) |
             Net::LDAP::Filter.eq("uid", login)

    ldap.search(
      base: ENV.fetch("LDAP_BASE"),
      filter: filter
    )&.first
  end
end