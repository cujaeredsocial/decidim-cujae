# frozen_string_literal: true

class LdapUserMapper
  DEFAULT_MAP = {
    email: ["mail", "email", "userPrincipalName"],
    name: ["cn", "displayName"],
    nickname: ["uid", "sAMAccountName"]
  }.freeze

  def initialize(entry, map: DEFAULT_MAP)
    @entry = entry
    @map = map
  end

  def email
    extract(:email)
  end

  def name
    extract(:name) || email
  end

  def nickname
    extract(:nickname) || email&.split("@")&.first
  end

  private

  def extract(field)
    keys = @map[field] || []

    keys.each do |key|
      value = @entry[key]&.first
      return value if value.present?
    end

    nil
  end
end