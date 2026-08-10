require 'rails_helper'

RSpec.describe Integrations::Buzzdesk::CredentialsValidator do
  let(:base_url) { 'https://support.example.com' }
  let(:api_token) { 'valid_api_token' }
  let(:me_url) { "#{base_url}/api/v1/users/me" }

  it 'accepts a valid base URL and API token' do
    stub_request(:get, me_url).to_return(status: 200, body: { id: 1 }.to_json)

    expect(described_class.valid?(base_url, api_token)).to be true
    expect(described_class.validate(base_url, api_token).success?).to be true
  end

  it 'rejects an invalid API token' do
    stub_request(:get, me_url).to_return(status: 401)

    expect(described_class.valid?(base_url, api_token)).to be false
    expect(described_class.validate(base_url, api_token).error).to eq(:invalid_token)
  end

  it 'rejects a base URL that does not resolve to a BuzzDesk instance' do
    stub_request(:get, me_url).to_return(status: 404)

    expect(described_class.validate(base_url, api_token).error).to eq(:invalid_base_url)
  end

  it 'rejects blank credentials without making a network call' do
    expect(described_class.valid?(nil, api_token)).to be false
    expect(described_class.valid?(base_url, nil)).to be false
    expect(described_class.validate(nil, api_token).error).to eq(:missing_credentials)
  end

  it 'rejects transient failures instead of saving unverified credentials' do
    stub_request(:get, me_url).to_return(status: 500)

    expect(described_class.validate(base_url, api_token).error).to eq(:verification_failed)
  end

  it 'rejects an unreachable host as an invalid base URL instead of raising' do
    stub_request(:get, me_url).to_raise(SocketError)

    expect(described_class.validate(base_url, api_token).error).to eq(:invalid_base_url)
  end

  it 'rejects an unexpected error instead of raising' do
    stub_request(:get, me_url).to_raise(StandardError)

    expect(described_class.validate(base_url, api_token).error).to eq(:verification_failed)
  end
end
