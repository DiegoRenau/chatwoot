class Buzzdesk::ActivityMessageService
  attr_reader :conversation, :action_type, :ticket_data, :user

  def initialize(conversation:, action_type:, user:, ticket_data: {})
    @conversation = conversation
    @action_type = action_type
    @ticket_data = ticket_data
    @user = user
  end

  def perform
    return unless conversation && ticket_data[:number] && user

    content = generate_activity_content
    return unless content

    ::Conversations::ActivityMessageJob.perform_later(conversation, activity_message_params(content))
  end

  private

  def generate_activity_content
    case action_type.to_sym
    when :ticket_created
      I18n.t('conversations.activity.buzzdesk.ticket_created', user_name: user.name, ticket_number: ticket_data[:number])
    when :ticket_linked
      I18n.t('conversations.activity.buzzdesk.ticket_linked', user_name: user.name, ticket_number: ticket_data[:number])
    when :ticket_unlinked
      I18n.t('conversations.activity.buzzdesk.ticket_unlinked', user_name: user.name, ticket_number: ticket_data[:number])
    end
  end

  def activity_message_params(content)
    {
      account_id: conversation.account_id,
      inbox_id: conversation.inbox_id,
      message_type: :activity,
      content: content
    }
  end
end
