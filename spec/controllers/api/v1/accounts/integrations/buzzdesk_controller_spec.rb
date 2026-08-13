require 'rails_helper'

RSpec.describe 'BuzzDesk Integration API', type: :request do
  let(:account) { create(:account) }
  let(:agent) { create(:user, account: account, role: :agent) }
  let(:hook) { create(:integrations_hook, :buzzdesk, account: account) }
  let(:processor_service) { instance_double(Integrations::Buzzdesk::ProcessorService) }

  before do
    allow(Integrations::Buzzdesk::CredentialsValidator).to receive(:validate)
      .and_return(Integrations::Buzzdesk::CredentialsValidator::Result.new(true, nil))
    hook
    allow(Integrations::Buzzdesk::ProcessorService).to receive(:new).with(account: account).and_return(processor_service)
  end

  describe 'GET /api/v1/accounts/:account_id/integrations/buzzdesk/groups' do
    context 'when groups are retrieved successfully' do
      it 'returns the groups' do
        allow(processor_service).to receive(:groups).and_return(data: [{ id: 1, name: 'Users' }])

        get "/api/v1/accounts/#{account.id}/integrations/buzzdesk/groups", headers: agent.create_new_auth_token, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Users')
      end
    end

    context 'when the API token is invalid' do
      it 'returns the error message' do
        allow(processor_service).to receive(:groups).and_return(error: 'Invalid BuzzDesk API token. Please reconnect your BuzzDesk account.')

        get "/api/v1/accounts/#{account.id}/integrations/buzzdesk/groups", headers: agent.create_new_auth_token, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Invalid BuzzDesk API token')
      end
    end
  end

  describe 'GET /api/v1/accounts/:account_id/integrations/buzzdesk/search_tickets' do
    it 'returns a validation error when q is missing' do
      get "/api/v1/accounts/#{account.id}/integrations/buzzdesk/search_tickets", headers: agent.create_new_auth_token, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include('Specify search string with parameter q')
    end

    it 'returns matching tickets' do
      allow(processor_service).to receive(:search_tickets).with('login').and_return(data: [{ id: '42', number: '10042', title: 'Cannot log in' }])

      get "/api/v1/accounts/#{account.id}/integrations/buzzdesk/search_tickets", params: { q: 'login' }, headers: agent.create_new_auth_token,
                                                                                 as: :json

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Cannot log in')
    end
  end

  describe 'POST /api/v1/accounts/:account_id/integrations/buzzdesk/create_ticket' do
    let(:contact) { create(:contact, account: account, email: 'customer@example.com') }
    let(:conversation) { create(:conversation, account: account, contact: contact) }
    let(:ticket_params) { { conversation_id: conversation.display_id, title: 'Cannot log in', group: 'Users', description: 'Stuck on login' } }

    context 'when the contact has no email address' do
      let(:contact) { create(:contact, account: account, email: nil) }

      it 'returns a validation error without calling BuzzDesk' do
        expect(processor_service).not_to receive(:create_ticket)

        post "/api/v1/accounts/#{account.id}/integrations/buzzdesk/create_ticket", params: ticket_params, headers: agent.create_new_auth_token,
                                                                                   as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('no email address')
      end
    end

    context 'when the ticket is created successfully' do
      let(:created_ticket) { { data: { id: '42', number: '10042', title: 'Cannot log in' } } }

      before { allow(processor_service).to receive(:create_ticket).and_return(created_ticket) }

      it 'persists the link and returns it' do
        post "/api/v1/accounts/#{account.id}/integrations/buzzdesk/create_ticket", params: ticket_params, headers: agent.create_new_auth_token,
                                                                                   as: :json

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('10042')
        expect(conversation.linked_buzzdesk_tickets.count).to eq(1)
        expect(conversation.linked_buzzdesk_tickets.first.ticket_id).to eq('42')
      end

      it 'includes the conversation link in the ticket description' do
        expect(processor_service).to receive(:create_ticket).with(
          hash_including(description: a_string_matching(%r{Conversación de BuzzCRM: .*conversations/#{conversation.display_id}}))
        ).and_return(created_ticket)

        post "/api/v1/accounts/#{account.id}/integrations/buzzdesk/create_ticket", params: ticket_params, headers: agent.create_new_auth_token,
                                                                                   as: :json
      end

      it 'enqueues an activity message' do
        expect do
          post "/api/v1/accounts/#{account.id}/integrations/buzzdesk/create_ticket", params: ticket_params, headers: agent.create_new_auth_token,
                                                                                     as: :json
        end.to have_enqueued_job(Conversations::ActivityMessageJob)
          .with(conversation, hash_including(content: "BuzzDesk ticket #10042 was created by #{agent.name}"))
      end
    end

    context 'when ticket creation fails (e.g. group has no email configured)' do
      it 'returns the error and does not persist a link' do
        allow(processor_service).to receive(:create_ticket).and_return(error: 'Group Sales has no email address configured', error_code: 422)

        expect do
          post "/api/v1/accounts/#{account.id}/integrations/buzzdesk/create_ticket", params: ticket_params, headers: agent.create_new_auth_token,
                                                                                     as: :json
        end.not_to have_enqueued_job(Conversations::ActivityMessageJob)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('no email address configured')
        expect(conversation.linked_buzzdesk_tickets.count).to eq(0)
      end
    end
  end

  describe 'POST /api/v1/accounts/:account_id/integrations/buzzdesk/link_ticket' do
    let(:conversation) { create(:conversation, account: account) }
    let(:fetched_ticket) { { data: { id: '99', number: '10099', title: 'Existing ticket' } } }

    context 'when the ticket exists' do
      before { allow(processor_service).to receive(:ticket).with('99').and_return(fetched_ticket) }

      it 'persists the link and enqueues an activity message' do
        expect do
          post "/api/v1/accounts/#{account.id}/integrations/buzzdesk/link_ticket",
               params: { conversation_id: conversation.display_id, ticket_id: '99' },
               headers: agent.create_new_auth_token, as: :json
        end.to have_enqueued_job(Conversations::ActivityMessageJob)
          .with(conversation, hash_including(content: "BuzzDesk ticket #10099 was linked by #{agent.name}"))

        expect(response).to have_http_status(:ok)
        expect(conversation.linked_buzzdesk_tickets.first.ticket_number).to eq('10099')
      end
    end

    context 'when the ticket does not exist' do
      it 'returns the error message' do
        allow(processor_service).to receive(:ticket).with('99').and_return(
          error: 'Could not reach BuzzDesk at the configured base URL. Please check the URL and try again.', error_code: 404
        )

        post "/api/v1/accounts/#{account.id}/integrations/buzzdesk/link_ticket",
             params: { conversation_id: conversation.display_id, ticket_id: '99' },
             headers: agent.create_new_auth_token, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('Could not reach BuzzDesk')
      end
    end
  end

  describe 'POST /api/v1/accounts/:account_id/integrations/buzzdesk/unlink_ticket' do
    let(:conversation) { create(:conversation, account: account) }
    let!(:linked_ticket) { create(:linked_buzzdesk_ticket, account: account, conversation: conversation, hook: hook, ticket_number: '10042') }

    it 'destroys the link and enqueues an activity message' do
      expect do
        post "/api/v1/accounts/#{account.id}/integrations/buzzdesk/unlink_ticket",
             params: { conversation_id: conversation.display_id, id: linked_ticket.id },
             headers: agent.create_new_auth_token, as: :json
      end.to have_enqueued_job(Conversations::ActivityMessageJob)
        .with(conversation, hash_including(content: "BuzzDesk ticket #10042 was unlinked by #{agent.name}"))

      expect(response).to have_http_status(:ok)
      expect(conversation.linked_buzzdesk_tickets.count).to eq(0)
    end
  end

  describe 'GET /api/v1/accounts/:account_id/integrations/buzzdesk/linked_tickets' do
    let(:conversation) { create(:conversation, account: account) }

    before do
      create(:linked_buzzdesk_ticket, account: account, conversation: conversation, hook: hook, ticket_id: '42', ticket_number: '10042',
                                      title: 'Cannot log in')
    end

    context 'when the live ticket is fetched successfully' do
      it 'returns the linked ticket with its live status' do
        allow(processor_service).to receive(:ticket).with('42').and_return(data: { id: '42', number: '10042', title: 'Cannot log in', state: 'open' })

        get "/api/v1/accounts/#{account.id}/integrations/buzzdesk/linked_tickets",
            params: { conversation_id: conversation.display_id },
            headers: agent.create_new_auth_token, as: :json

        expect(response).to have_http_status(:ok)
        parsed = response.parsed_body.first
        expect(parsed['status_unavailable']).to be false
        expect(parsed['ticket']['state']).to eq('open')
      end
    end

    context 'when the live ticket cannot be fetched' do
      it 'still returns the cached link, flagged as unavailable' do
        allow(processor_service).to receive(:ticket).with('42').and_return(error: 'error message', error_code: 404)

        get "/api/v1/accounts/#{account.id}/integrations/buzzdesk/linked_tickets",
            params: { conversation_id: conversation.display_id },
            headers: agent.create_new_auth_token, as: :json

        expect(response).to have_http_status(:ok)
        parsed = response.parsed_body.first
        expect(parsed['status_unavailable']).to be true
        expect(parsed['number']).to eq('10042')
      end
    end
  end
end
