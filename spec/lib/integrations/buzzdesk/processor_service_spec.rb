require 'rails_helper'

describe Integrations::Buzzdesk::ProcessorService do
  let(:account) { create(:account) }
  let(:buzzdesk_client) { instance_double(Buzzdesk) }

  before do
    allow(Integrations::Buzzdesk::CredentialsValidator).to receive(:validate)
      .and_return(Integrations::Buzzdesk::CredentialsValidator::Result.new(true, nil))
    create(:integrations_hook, :buzzdesk, account: account)
    allow(Buzzdesk).to receive(:new).and_return(buzzdesk_client)
  end

  describe '#groups' do
    it 'returns only active groups' do
      allow(buzzdesk_client).to receive(:groups).and_return(
        data: [{ 'id' => 1, 'name' => 'Users', 'active' => true }, { 'id' => 2, 'name' => 'Archived', 'active' => false }]
      )

      expect(described_class.new(account: account).groups).to eq(data: [{ 'id' => 1, 'name' => 'Users' }])
    end

    it 'passes through errors' do
      allow(buzzdesk_client).to receive(:groups).and_return(error: 'error message', error_code: 401)

      expect(described_class.new(account: account).groups).to eq(error: 'error message', error_code: 401)
    end
  end

  describe '#create_ticket' do
    let(:params) { { title: 'Cannot log in', group: 'Users', customer_email: 'customer@example.com' } }

    it 'normalizes the created ticket' do
      allow(buzzdesk_client).to receive(:create_ticket).with(params).and_return(
        data: { 'id' => 42, 'number' => '10042', 'title' => 'Cannot log in', 'state' => 'open', 'priority' => '2 normal', 'group' => 'Users',
                'owner' => 'Agent' }
      )

      expect(described_class.new(account: account).create_ticket(params)).to eq(
        data: { id: '42', number: '10042', title: 'Cannot log in', state: 'open', priority: '2 normal', group: 'Users', owner: 'Agent',
                url: 'https://support.example.com/#ticket/zoom/42' }
      )
    end

    it 'passes through errors' do
      allow(buzzdesk_client).to receive(:create_ticket).with(params).and_return(error: 'error message', error_code: 422)

      expect(described_class.new(account: account).create_ticket(params)).to eq(error: 'error message', error_code: 422)
    end
  end

  describe '#ticket' do
    it 'normalizes the ticket' do
      allow(buzzdesk_client).to receive(:ticket).with('42').and_return(data: { 'id' => 42, 'number' => '10042', 'title' => 'Cannot log in' })

      expect(described_class.new(account: account).ticket('42')).to eq(
        data: { id: '42', number: '10042', title: 'Cannot log in', state: nil, priority: nil, group: nil, owner: nil,
                url: 'https://support.example.com/#ticket/zoom/42' }
      )
    end

    it 'passes through errors' do
      allow(buzzdesk_client).to receive(:ticket).with('42').and_return(error: 'error message', error_code: 404)

      expect(described_class.new(account: account).ticket('42')).to eq(error: 'error message', error_code: 404)
    end
  end

  describe '#search_tickets' do
    it 'normalizes each matching ticket' do
      allow(buzzdesk_client).to receive(:search_tickets).with('login').and_return(
        data: [{ 'id' => 42, 'number' => '10042', 'title' => 'Cannot log in' }]
      )

      response = described_class.new(account: account).search_tickets('login')
      expect(response[:data].first).to include(id: '42', number: '10042', title: 'Cannot log in')
    end

    it 'passes through errors' do
      allow(buzzdesk_client).to receive(:search_tickets).with('login').and_return(error: 'error message', error_code: 401)

      expect(described_class.new(account: account).search_tickets('login')).to eq(error: 'error message', error_code: 401)
    end
  end
end
