# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

Gem::Specification.new do |s|
  s.name = "decidim-auth-ldap"
  s.version = "0.1.0"
  s.authors = ["Rodny Estrada"]
  s.summary = "LDAP authentication for Consejo Universitario CUJAE"
  
  s.files = Dir["{app,config,lib}/**/*"]
  
  s.add_dependency "decidim-core", "~> 0.30.5"
  s.add_dependency "net-ldap", "~> 0.16"
end