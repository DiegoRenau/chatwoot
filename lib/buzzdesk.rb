class Buzzdesk
  # A typo'd or unreachable base_url never gets far enough to return an HTTP response
  # (no server to send a 404 back) -- it fails at the socket/DNS/TLS layer instead.
  CONNECTION_ERRORS = [SocketError, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Net::OpenTimeout, Net::ReadTimeout, OpenSSL::SSL::SSLError].freeze

  def initialize(base_url, api_token)
    raise ArgumentError, 'Missing base URL' if base_url.blank?
    raise ArgumentError, 'Missing API token' if api_token.blank?

    @base_url = base_url.chomp('/')
    @api_token = api_token
  end

  def me
    get('/api/v1/users/me')
  end

  def groups
    get('/api/v1/groups')
  end

  def create_ticket(params)
    raise ArgumentError, 'Missing title' if params[:title].blank?
    raise ArgumentError, 'Missing group' if params[:group].blank?
    raise ArgumentError, 'Missing customer email' if params[:customer_email].blank?

    post('/api/v1/tickets', build_ticket_payload(params))
  end

  def ticket(id)
    raise ArgumentError, 'Missing ticket id' if id.blank?

    # expand: true resolves state/priority/group/owner to their display names instead
    # of raw ids, so callers don't need a second round-trip to render them.
    get("/api/v1/tickets/#{id}", query: { expand: true })
  end

  def search_tickets(query)
    raise ArgumentError, 'Missing search query' if query.blank?

    get('/api/v1/tickets/search', query: { query: query, expand: true })
  end

  private

  def build_ticket_payload(params)
    {
      title: params[:title],
      group: params[:group],
      customer_id: "guess:#{params[:customer_email]}",
      article: {
        body: params[:description].presence || params[:title],
        type: 'note',
        internal: false
      }
    }
  end

  def get(path, query: nil)
    response = HTTParty.get("#{@base_url}#{path}", headers: headers, query: query)
    process_response(response)
  rescue *CONNECTION_ERRORS
    connection_failed_error
  end

  def post(path, body)
    response = HTTParty.post("#{@base_url}#{path}", headers: headers, body: body.to_json)
    process_response(response)
  rescue *CONNECTION_ERRORS
    connection_failed_error
  end

  def headers
    { 'Authorization' => "Token token=#{@api_token}", 'Content-Type' => 'application/json' }
  end

  def process_response(response)
    return { data: response.parsed_response } if response.success?

    { error: error_message_for(response), error_code: response.code }
  end

  def connection_failed_error
    { error: I18n.t('errors.buzzdesk.invalid_base_url'), error_code: 404 }
  end

  # Zammad (and BuzzDesk, its fork) return specific, actionable messages for validation
  # failures like 422 (e.g. "Group 'Sales' has no email address configured") -- we pass
  # those through verbatim since they tell the admin exactly what to fix on the BuzzDesk side.
  def error_message_for(response)
    case response.code
    when 401
      I18n.t('errors.buzzdesk.invalid_token')
    when 404
      I18n.t('errors.buzzdesk.invalid_base_url')
    else
      zammad_error_message(response) || I18n.t('errors.buzzdesk.unexpected')
    end
  end

  def zammad_error_message(response)
    body = response.parsed_response
    return unless body.is_a?(Hash)

    body['error_human'] || body['error']
  end
end
