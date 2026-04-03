module Decidim
  module AuthLdap
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
