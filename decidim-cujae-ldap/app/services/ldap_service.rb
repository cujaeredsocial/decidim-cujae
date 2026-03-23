# frozen_string_literal: true

require "net/ldap"

class LdapService
  def self.authenticate(login, password)
    return nil if ENV["LDAP_ENABLED"] != true

    ldap = Net::LDAP.new(
      host: ENV["LDAP_HOST"],
      port: ENV.fetch("LDAP_PORT", 389),
      auth: {
        method: :simple,
        username: login,
        password: password
      }
    )

    unless ldap.bind
      Rails.logger.warn("[LDAP] Bind fallido para #{login}")
      return nil
    end

    filter = Net::LDAP::Filter.eq("mail", login) |
             Net::LDAP::Filter.eq("uid", login)

    ldap.search(
      base: ENV.fetch("LDAP_BASE"),
      filter: filter
    )&.first

  rescue StandardError => e
    if ldap_host.present?
      Rails.logger.error("[LDAP] ERROR CRÍTICO: #{e.class} - #{e.message}")
      raise e
    else
      Rails.logger.warn("[LDAP] LDAP no configurado, fallback a Devise")
      nil
    end
  end
end