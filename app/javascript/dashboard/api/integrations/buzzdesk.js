/* global axios */

import ApiClient from '../ApiClient';

class BuzzdeskAPI extends ApiClient {
  constructor() {
    super('integrations/buzzdesk', { accountScoped: true });
  }

  getGroups() {
    return axios.get(`${this.url}/groups`);
  }

  searchTickets(query) {
    return axios.get(`${this.url}/search_tickets?q=${query}`);
  }

  createTicket(data) {
    return axios.post(`${this.url}/create_ticket`, data);
  }

  linkTicket(conversationId, ticketId) {
    return axios.post(`${this.url}/link_ticket`, {
      conversation_id: conversationId,
      ticket_id: ticketId,
    });
  }

  unlinkTicket(id, conversationId) {
    return axios.post(`${this.url}/unlink_ticket`, {
      id,
      conversation_id: conversationId,
    });
  }

  getLinkedTickets(conversationId) {
    return axios.get(
      `${this.url}/linked_tickets?conversation_id=${conversationId}`
    );
  }
}

export default new BuzzdeskAPI();
