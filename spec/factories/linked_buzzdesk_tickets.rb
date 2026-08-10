FactoryBot.define do
  factory :linked_buzzdesk_ticket do
    account
    conversation
    hook factory: %i[integrations_hook buzzdesk]
    sequence(:ticket_id, &:to_s)
    sequence(:ticket_number) { |n| "100#{n}" }
    title { 'Sample ticket' }
  end
end
