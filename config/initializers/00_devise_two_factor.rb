# Load devise-two-factor before other initializers
# This ensures TwoFactorAuthenticatable is available when User model loads

begin
  require 'devise-two-factor'
  
  # Ensure the module is properly loaded
  unless defined?(Devise::Models::TwoFactorAuthenticatable)
    Rails.logger.warn "TwoFactorAuthenticatable module not found after requiring devise-two-factor"
  end
  
rescue LoadError => e
  Rails.logger.error "Failed to load devise-two-factor: #{e.message}"
  
  # Create a dummy module to prevent errors during development
  module Devise
    module Models
      module TwoFactorAuthenticatable
        extend ActiveSupport::Concern
        
        def self.required_fields(klass)
          []
        end
      end
    end
  end
  
  Rails.logger.info "Created dummy TwoFactorAuthenticatable module"
end
