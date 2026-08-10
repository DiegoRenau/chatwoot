require 'rails_helper'

describe Buzzdesk do
  let(:base_url) { 'https://support.example.com' }
  let(:api_token) { 'valid_api_token' }
  let(:client) { described_class.new(base_url, api_token) }
  let(:request_headers) { { 'Authorization' => "Token token=#{api_token}", 'Content-Type' => 'application/json' } }
  let(:json_response_headers) { { 'Content-Type' => 'application/json' } }

  it 'raises an exception if the base URL is absent' do
    expect { described_class.new(nil, api_token) }.to raise_error(ArgumentError, 'Missing base URL')
  end

  it 'raises an exception if the API token is absent' do
    expect { described_class.new(base_url, nil) }.to raise_error(ArgumentError, 'Missing API token')
  end

  describe '#me' do
    it 'returns the current user on success' do
      stub_request(:get, "#{base_url}/api/v1/users/me")
        .with(headers: request_headers)
        .to_return(status: 200, body: { id: 1, email: 'agent@example.com' }.to_json, headers: json_response_headers)

      expect(client.me).to eq(data: { 'id' => 1, 'email' => 'agent@example.com' })
    end

    it 'returns an explicit error for an invalid token' do
      stub_request(:get, "#{base_url}/api/v1/users/me").to_return(status: 401, body: { error: 'authentication failed' }.to_json)

      response = client.me
      expect(response[:error_code]).to eq(401)
      expect(response[:error]).to eq(I18n.t('errors.buzzdesk.invalid_token'))
    end

    it 'returns an explicit error for a bad base URL' do
      stub_request(:get, "#{base_url}/api/v1/users/me").to_return(status: 404)

      response = client.me
      expect(response[:error_code]).to eq(404)
      expect(response[:error]).to eq(I18n.t('errors.buzzdesk.invalid_base_url'))
    end

    it 'returns the same explicit error when the base URL does not resolve at all' do
      stub_request(:get, "#{base_url}/api/v1/users/me").to_raise(SocketError)

      response = client.me
      expect(response[:error_code]).to eq(404)
      expect(response[:error]).to eq(I18n.t('errors.buzzdesk.invalid_base_url'))
    end

    it 'returns the same explicit error when the connection times out' do
      stub_request(:get, "#{base_url}/api/v1/users/me").to_timeout

      response = client.me
      expect(response[:error_code]).to eq(404)
    end
  end

  describe '#groups' do
    it 'returns the list of groups' do
      stub_request(:get, "#{base_url}/api/v1/groups")
        .to_return(status: 200, body: [{ id: 1, name: 'Users', active: true }].to_json, headers: json_response_headers)

      expect(client.groups).to eq(data: [{ 'id' => 1, 'name' => 'Users', 'active' => true }])
    end
  end

  describe '#create_ticket' do
    let(:params) do
      { title: 'Cannot log in', group: 'Users', customer_email: 'customer@example.com', description: 'They are stuck on the login page.' }
    end

    it 'raises an exception when the title is missing' do
      expect { client.create_ticket(params.except(:title)) }.to raise_error(ArgumentError, 'Missing title')
    end

    it 'raises an exception when the group is missing' do
      expect { client.create_ticket(params.except(:group)) }.to raise_error(ArgumentError, 'Missing group')
    end

    it 'raises an exception when the customer email is missing' do
      expect { client.create_ticket(params.except(:customer_email)) }.to raise_error(ArgumentError, 'Missing customer email')
    end

    it 'creates the ticket with a guessed customer and a note article' do
      stub = stub_request(:post, "#{base_url}/api/v1/tickets")
             .with(
               headers: request_headers,
               body: {
                 title: 'Cannot log in',
                 group: 'Users',
                 customer_id: 'guess:customer@example.com',
                 article: { body: 'They are stuck on the login page.', type: 'note', internal: false }
               }.to_json
             )
             .to_return(status: 200, body: { id: 42, number: '10042', title: 'Cannot log in' }.to_json, headers: json_response_headers)

      response = client.create_ticket(params)
      expect(stub).to have_been_requested
      expect(response).to eq(data: { 'id' => 42, 'number' => '10042', 'title' => 'Cannot log in' })
    end

    it 'surfaces the real Zammad validation error for a 422 (e.g. group without an email address)' do
      stub_request(:post, "#{base_url}/api/v1/tickets")
        .to_return(status: 422,
                   body: { error: 'Group Sales has no email address configured', error_human: 'Group Sales has no email address configured' }.to_json,
                   headers: json_response_headers)

      response = client.create_ticket(params)
      expect(response).to eq(error: 'Group Sales has no email address configured', error_code: 422)
    end
  end

  describe '#ticket' do
    it 'raises an exception when the id is missing' do
      expect { client.ticket(nil) }.to raise_error(ArgumentError, 'Missing ticket id')
    end

    it 'fetches the ticket with expanded fields' do
      stub_request(:get, "#{base_url}/api/v1/tickets/42")
        .with(query: { expand: 'true' })
        .to_return(status: 200, body: { id: 42, number: '10042', title: 'Cannot log in', state: 'open' }.to_json, headers: json_response_headers)

      response = client.ticket(42)
      expect(response).to eq(data: { 'id' => 42, 'number' => '10042', 'title' => 'Cannot log in', 'state' => 'open' })
    end
  end

  describe '#search_tickets' do
    it 'raises an exception when the query is missing' do
      expect { client.search_tickets(nil) }.to raise_error(ArgumentError, 'Missing search query')
    end

    it 'searches tickets with expanded fields' do
      stub_request(:get, "#{base_url}/api/v1/tickets/search")
        .with(query: { query: 'login', expand: 'true' })
        .to_return(status: 200, body: [{ id: 42, number: '10042', title: 'Cannot log in' }].to_json, headers: json_response_headers)

      response = client.search_tickets('login')
      expect(response).to eq(data: [{ 'id' => 42, 'number' => '10042', 'title' => 'Cannot log in' }])
    end
  end
end
