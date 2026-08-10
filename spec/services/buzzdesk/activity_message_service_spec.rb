require 'rails_helper'

RSpec.describe Buzzdesk::ActivityMessageService, type: :service do
  let(:account) { create(:account) }
  let(:inbox) { create(:inbox, account: account) }
  let(:conversation) { create(:conversation, account: account, inbox: inbox) }
  let(:user) { create(:user, account: account) }

  describe '#perform' do
    context 'when action_type is ticket_created' do
      let(:service) do
        described_class.new(
          conversation: conversation,
          action_type: :ticket_created,
          ticket_data: { number: '10042' },
          user: user
        )
      end

      it 'enqueues an activity message job' do
        expect do
          service.perform
        end.to have_enqueued_job(Conversations::ActivityMessageJob)
          .with(conversation, {
                  account_id: conversation.account_id,
                  inbox_id: conversation.inbox_id,
                  message_type: :activity,
                  content: "BuzzDesk ticket #10042 was created by #{user.name}"
                })
      end

      it 'does not enqueue job when ticket data lacks a number' do
        service = described_class.new(
          conversation: conversation,
          action_type: :ticket_created,
          ticket_data: { title: 'Some ticket' },
          user: user
        )

        expect do
          service.perform
        end.not_to have_enqueued_job(Conversations::ActivityMessageJob)
      end

      it 'does not enqueue job when conversation is nil' do
        service = described_class.new(
          conversation: nil,
          action_type: :ticket_created,
          ticket_data: { number: '10042' },
          user: user
        )

        expect do
          service.perform
        end.not_to have_enqueued_job(Conversations::ActivityMessageJob)
      end

      it 'does not enqueue job when user is nil' do
        service = described_class.new(
          conversation: conversation,
          action_type: :ticket_created,
          ticket_data: { number: '10042' },
          user: nil
        )

        expect do
          service.perform
        end.not_to have_enqueued_job(Conversations::ActivityMessageJob)
      end
    end

    context 'when action_type is ticket_linked' do
      it 'enqueues an activity message job' do
        service = described_class.new(
          conversation: conversation,
          action_type: :ticket_linked,
          ticket_data: { number: '10099' },
          user: user
        )

        expect do
          service.perform
        end.to have_enqueued_job(Conversations::ActivityMessageJob)
          .with(conversation, {
                  account_id: conversation.account_id,
                  inbox_id: conversation.inbox_id,
                  message_type: :activity,
                  content: "BuzzDesk ticket #10099 was linked by #{user.name}"
                })
      end
    end

    context 'when action_type is ticket_unlinked' do
      it 'enqueues an activity message job' do
        service = described_class.new(
          conversation: conversation,
          action_type: :ticket_unlinked,
          ticket_data: { number: '10011' },
          user: user
        )

        expect do
          service.perform
        end.to have_enqueued_job(Conversations::ActivityMessageJob)
          .with(conversation, {
                  account_id: conversation.account_id,
                  inbox_id: conversation.inbox_id,
                  message_type: :activity,
                  content: "BuzzDesk ticket #10011 was unlinked by #{user.name}"
                })
      end
    end

    context 'when action_type is unknown' do
      it 'does not enqueue job for unknown action types' do
        service = described_class.new(
          conversation: conversation,
          action_type: :unknown_action,
          ticket_data: { number: '10011' },
          user: user
        )

        expect do
          service.perform
        end.not_to have_enqueued_job(Conversations::ActivityMessageJob)
      end
    end
  end
end
