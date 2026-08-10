# == Schema Information
#
# Table name: linked_buzzdesk_tickets
#
#  id              :bigint           not null, primary key
#  ticket_number   :string           not null
#  title           :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  account_id      :bigint           not null
#  conversation_id :bigint           not null
#  hook_id         :bigint           not null
#  ticket_id       :string           not null
#
# Indexes
#
#  idx_linked_buzzdesk_tickets_on_conversation_and_ticket  (conversation_id,ticket_id) UNIQUE
#  index_linked_buzzdesk_tickets_on_account_id             (account_id)
#  index_linked_buzzdesk_tickets_on_conversation_id        (conversation_id)
#  index_linked_buzzdesk_tickets_on_hook_id                (hook_id)
#
# Foreign Keys
#
#  fk_rails_...  (hook_id => integrations_hooks.id)
#
class LinkedBuzzdeskTicket < ApplicationRecord
  belongs_to :account
  belongs_to :conversation
  belongs_to :hook, class_name: 'Integrations::Hook'

  validates :ticket_id, presence: true
  validates :ticket_number, presence: true
  validates :title, presence: true
  validates :ticket_id, uniqueness: { scope: :conversation_id }
end
