module Integrations::Buzzdesk::CredentialsValidator
  Result = Data.define(:success?, :error)

  def self.valid?(base_url, api_token)
    validate(base_url, api_token).success?
  end

  def self.validate(base_url, api_token)
    return failure(:missing_credentials) if base_url.blank? || api_token.blank?

    response = Buzzdesk.new(base_url, api_token).me
    return success if response[:data].present?

    failure_for_error_code(response[:error_code])
  rescue ArgumentError
    failure(:missing_credentials)
  rescue StandardError => e
    Rails.logger.warn("[buzzdesk-credentials-validator] #{e.class}: #{e.message}")
    failure(:verification_failed)
  end

  def self.failure_for_error_code(error_code)
    case error_code
    when 401
      failure(:invalid_token)
    when 404
      failure(:invalid_base_url)
    else
      failure(:verification_failed)
    end
  end
  private_class_method :failure_for_error_code

  def self.success
    Result.new(true, nil)
  end
  private_class_method :success

  def self.failure(error)
    Result.new(false, error)
  end
  private_class_method :failure
end
