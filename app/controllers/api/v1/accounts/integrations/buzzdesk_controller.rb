class Api::V1::Accounts::Integrations::BuzzdeskController < Api::V1::Accounts::Integrations::BaseController
  before_action :fetch_conversation, only: [:create_ticket, :link_ticket, :unlink_ticket, :linked_tickets]

  def groups
    result = buzzdesk_processor_service.groups
    render_result(result)
  end

  def search_tickets
    if params[:q].blank?
      render json: { error: 'Specify search string with parameter q' }, status: :unprocessable_entity
      return
    end

    result = buzzdesk_processor_service.search_tickets(params[:q])
    render_result(result)
  end

  def create_ticket
    if customer_email.blank?
      render json: { error: I18n.t('errors.buzzdesk.missing_customer_email') }, status: :unprocessable_entity
      return
    end

    result = buzzdesk_processor_service.create_ticket(create_ticket_params)
    if result[:error]
      render json: { error: result[:error] }, status: :unprocessable_entity
      return
    end

    linked_ticket = persist_linked_ticket(result[:data])
    notify_activity(:ticket_created, linked_ticket)
    render json: linked_ticket, status: :ok
  end

  def link_ticket
    result = buzzdesk_processor_service.ticket(permitted_params[:ticket_id])
    if result[:error]
      render json: { error: result[:error] }, status: :unprocessable_entity
      return
    end

    linked_ticket = persist_linked_ticket(result[:data])
    notify_activity(:ticket_linked, linked_ticket)
    render json: linked_ticket, status: :ok
  end

  def unlink_ticket
    linked_ticket = @conversation.linked_buzzdesk_tickets.find(permitted_params[:id])
    linked_ticket.destroy!
    notify_activity(:ticket_unlinked, linked_ticket)
    head :ok
  end

  def linked_tickets
    tickets = @conversation.linked_buzzdesk_tickets.map { |linked_ticket| linked_ticket_with_live_status(linked_ticket) }
    render json: tickets, status: :ok
  end

  private

  def linked_ticket_with_live_status(linked_ticket)
    result = buzzdesk_processor_service.ticket(linked_ticket.ticket_id)
    {
      id: linked_ticket.id,
      ticket_id: linked_ticket.ticket_id,
      number: linked_ticket.ticket_number,
      title: linked_ticket.title,
      status_unavailable: result[:error].present?,
      ticket: result[:error].present? ? nil : result[:data]
    }
  end

  def persist_linked_ticket(ticket_data)
    @conversation.linked_buzzdesk_tickets.create!(
      account: Current.account,
      hook: buzzdesk_hook,
      ticket_id: ticket_data[:id],
      ticket_number: ticket_data[:number],
      title: ticket_data[:title]
    )
  end

  def notify_activity(action_type, linked_ticket)
    Buzzdesk::ActivityMessageService.new(
      conversation: @conversation,
      action_type: action_type,
      ticket_data: { number: linked_ticket.ticket_number },
      user: Current.user
    ).perform
  end

  def render_result(result)
    if result[:error]
      render json: { error: result[:error] }, status: :unprocessable_entity
    else
      render json: result[:data], status: :ok
    end
  end

  def customer_email
    @conversation.contact.email
  end

  def create_ticket_params
    permitted_params.slice(:title, :group).merge(
      description: conversation_context_description,
      customer_email: customer_email
    )
  end

  def conversation_context_description
    [permitted_params[:description], "Conversación de BuzzCRM: #{conversation_link}"].compact_blank.join("\n\n")
  end

  def conversation_link
    "#{ENV.fetch('FRONTEND_URL', nil)}/app/accounts/#{Current.account.id}/conversations/#{@conversation.display_id}"
  end

  def fetch_conversation
    @conversation = Current.account.conversations.find_by!(display_id: permitted_params[:conversation_id])
  end

  def buzzdesk_hook
    @buzzdesk_hook ||= Current.account.hooks.find_by!(app_id: 'buzzdesk')
  end

  def buzzdesk_processor_service
    Integrations::Buzzdesk::ProcessorService.new(account: Current.account)
  end

  def permitted_params
    params.permit(:conversation_id, :ticket_id, :id, :title, :description, :group)
  end
end
