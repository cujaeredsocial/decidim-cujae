require_relative "lib/decidim/cujae/ldap/version"

Gem::Specification.new do |spec|
  spec.name        = "decidim-cujae-ldap"
  spec.version     = Decidim::Cujae::Ldap::VERSION
  spec.authors     = [ "Rodny Estrada" ]
  spec.email       = [ "rrodnyestrada1@gmail.com" ]
  #spec.homepage    = "TODO"
  spec.summary     = "LDAP authentication for Decidim Cujae"
  spec.description = "LDAP authentication for Decidim Cujae"

  #spec.metadata["homepage_uri"] = spec.homepage
  #spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  #spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.2.2.2"
  spec.add_dependency "decidim-core"
  spec.add_dependency "net-ldap"
end
