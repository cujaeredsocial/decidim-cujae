# frozen_string_literal: true

require "net/ldap"

module Decidim
  module AuthLdap
    # Service to handle LDAP authentication
    class LdapAuthenticator
      attr_reader :connection, :config

      def self.authenticate(email, password)
        new.authenticate(email, password)
      end

      def initialize
        @config = Decidim::AuthLdap.config
        @connection = Net::LDAP.new(
          host: @config[:host],
          port: @config[:port],
          encryption: @config[:encryption] ? { method: :simple_tls } : nil
        )
      end

      def authenticate(email, password)
        return false unless email.present? && password.present?
        
        user_dn = find_user_dn(email)
        return false unless user_dn
        
        connection.auth(user_dn, password)
        
        if connection.bind
          # Authentication successful
          user_data = fetch_user_data(user_dn)
          user_data[:groups] = fetch_user_groups(user_dn) if config[:ldap_groups].present?
          user_data
        else
          false
        end
      end

      private

      def find_user_dn(email)
        connection.search(
          base: config[:base_dn],
          filter: Net::LDAP::Filter.eq(config[:uid], email),
          attributes: ["dn"]
        )&.first&.dn
      end

      def fetch_user_data(dn)
        result = connection.search(
          base: dn,
          scope: Net::LDAP::SearchScope_BaseObject,
          attributes: config[:user_attributes]
        )&.first

        return {} unless result

        {
          email: result[config[:email_attribute]]&.first&.to_s,
          name: result[config[:name_attribute]]&.first&.to_s,
          dn: dn,
          raw_data: result
        }
      end

      def fetch_user_groups(dn)
        groups = []
        
        connection.search(
          base: config[:groups_base_dn] || config[:base_dn],
          filter: Net::LDAP::Filter.eq("member", dn),
          attributes: ["cn"]
        ) do |entry|
          groups << entry[:cn]&.first&.to_s
        end
        
        groups.compact
      end
    end
  end
end