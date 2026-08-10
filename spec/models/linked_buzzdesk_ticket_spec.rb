require 'rails_helper'

RSpec.describe LinkedBuzzdeskTicket do
  before do
    allow(Integrations::Buzzdesk::CredentialsValidator).to receive(:validate)
      .and_return(Integrations::Buzzdesk::CredentialsValidator::Result.new(true, nil))
  end

  describe 'associations' do
    it { is_expected.to belong_to(:account) }
    it { is_expected.to belong_to(:conversation) }
    it { is_expected.to belong_to(:hook).class_name('Integrations::Hook') }
  end

  describe 'validations' do
    subject { build(:linked_buzzdesk_ticket) }

    it { is_expected.to validate_presence_of(:ticket_id) }
    it { is_expected.to validate_presence_of(:ticket_number) }
    it { is_expected.to validate_presence_of(:title) }

    it 'does not allow the same ticket to be linked twice to the same conversation' do
      existing = create(:linked_buzzdesk_ticket)
      duplicate = build(:linked_buzzdesk_ticket, conversation: existing.conversation, ticket_id: existing.ticket_id)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:ticket_id]).to be_present
    end

    it 'allows the same ticket to be linked to different conversations' do
      existing = create(:linked_buzzdesk_ticket)
      other = build(:linked_buzzdesk_ticket, account: existing.account, ticket_id: existing.ticket_id)

      expect(other).to be_valid
    end
  end
end
