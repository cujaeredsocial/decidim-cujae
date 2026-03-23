# frozen_string_literal: true

Decidim::User.class_eval do
  class << self
    alias_method :original_find_for_authentication, :find_for_authentication

    def find_for_authentication(warden_conditions)
      organization = warden_conditions.dig(:env, "decidim.current_organization")
      login = warden_conditions[:email].to_s.downcase
      password = warden_conditions[:password]

      ldap_entry = LdapService.authenticate(login, password)

      if ldap_entry
        mapper = LdapUserMapper.new(ldap_entry)

        email = mapper.email
        return nil unless email.present?

        user = find_or_initialize_by(
          email: email,
          decidim_organization_id: organization.id
        )

        if user.new_record?
          user.assign_attributes(
            name: mapper.name,
            nickname: mapper.nickname,
            password: Devise.friendly_token[0, 20],
            organization: organization,
            tos_agreement: true,
            accepted_tos_version: organization.tos_version,
            managed: true
          )

          user.save!
        else
          user.update(
            name: mapper.name,
            nickname: mapper.nickname
          )
        end

        Decidim::Identity.find_or_create_by!(
          decidim_user_id: user.id,
          provider: "ldap",
          uid: ldap_entry.dn,
          decidim_organization_id: organization.id
        )

        return user
      end

      original_find_for_authentication(warden_conditions)
    end
  end
end