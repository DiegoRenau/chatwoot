class Integrations::Buzzdesk::ProcessorService
  pattr_initialize [:account!]

  def groups
    response = buzzdesk_client.groups
    return response if response[:error]

    { data: response[:data].select { |group| group['active'] }.map { |group| group.slice('id', 'name') } }
  end

  def create_ticket(params)
    response = buzzdesk_client.create_ticket(params)
    return response if response[:error]

    { data: normalize_ticket(response[:data]) }
  end

  def ticket(id)
    response = buzzdesk_client.ticket(id)
    return response if response[:error]

    { data: normalize_ticket(response[:data]) }
  end

  def search_tickets(query)
    response = buzzdesk_client.search_tickets(query)
    return response if response[:error]

    tickets = response[:data].is_a?(Array) ? response[:data] : []
    { data: tickets.map { |ticket| normalize_ticket(ticket) } }
  end

  private

  def normalize_ticket(ticket)
    {
      id: ticket['id'].to_s,
      number: ticket['number'],
      title: ticket['title'],
      state: ticket['state'] || ticket['state_id'],
      priority: ticket['priority'] || ticket['priority_id'],
      group: ticket['group'] || ticket['group_id'],
      owner: ticket['owner'],
      url: "#{buzzdesk_hook.settings['base_url'].chomp('/')}/#ticket/zoom/#{ticket['id']}"
    }
  end

  def buzzdesk_hook
    @buzzdesk_hook ||= account.hooks.find_by!(app_id: 'buzzdesk')
  end

  def buzzdesk_client
    @buzzdesk_client ||= Buzzdesk.new(buzzdesk_hook.settings['base_url'], buzzdesk_hook.settings['api_token'])
  end
end
