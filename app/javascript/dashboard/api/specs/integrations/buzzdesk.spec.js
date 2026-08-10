import BuzzdeskAPIClient from '../../integrations/buzzdesk';
import ApiClient from '../../ApiClient';

describe('#buzzdeskAPI', () => {
  it('creates correct instance', () => {
    expect(BuzzdeskAPIClient).toBeInstanceOf(ApiClient);
    expect(BuzzdeskAPIClient).toHaveProperty('getGroups');
    expect(BuzzdeskAPIClient).toHaveProperty('searchTickets');
    expect(BuzzdeskAPIClient).toHaveProperty('createTicket');
    expect(BuzzdeskAPIClient).toHaveProperty('linkTicket');
    expect(BuzzdeskAPIClient).toHaveProperty('unlinkTicket');
    expect(BuzzdeskAPIClient).toHaveProperty('getLinkedTickets');
  });

  describe('getGroups', () => {
    const originalAxios = window.axios;
    const axiosMock = {
      post: vi.fn(() => Promise.resolve()),
      get: vi.fn(() => Promise.resolve()),
      patch: vi.fn(() => Promise.resolve()),
      delete: vi.fn(() => Promise.resolve()),
    };

    beforeEach(() => {
      window.axios = axiosMock;
    });

    afterEach(() => {
      window.axios = originalAxios;
    });

    it('creates a valid request', () => {
      BuzzdeskAPIClient.getGroups();
      expect(axiosMock.get).toHaveBeenCalledWith(
        '/api/v1/integrations/buzzdesk/groups'
      );
    });
  });

  describe('searchTickets', () => {
    const originalAxios = window.axios;
    const axiosMock = {
      post: vi.fn(() => Promise.resolve()),
      get: vi.fn(() => Promise.resolve()),
      patch: vi.fn(() => Promise.resolve()),
      delete: vi.fn(() => Promise.resolve()),
    };

    beforeEach(() => {
      window.axios = axiosMock;
    });

    afterEach(() => {
      window.axios = originalAxios;
    });

    it('creates a valid request', () => {
      BuzzdeskAPIClient.searchTickets('login');
      expect(axiosMock.get).toHaveBeenCalledWith(
        '/api/v1/integrations/buzzdesk/search_tickets?q=login'
      );
    });
  });

  describe('createTicket', () => {
    const originalAxios = window.axios;
    const axiosMock = {
      post: vi.fn(() => Promise.resolve()),
      get: vi.fn(() => Promise.resolve()),
      patch: vi.fn(() => Promise.resolve()),
      delete: vi.fn(() => Promise.resolve()),
    };

    beforeEach(() => {
      window.axios = axiosMock;
    });

    afterEach(() => {
      window.axios = originalAxios;
    });

    it('creates a valid request', () => {
      const ticketData = {
        title: 'Cannot log in',
        group: 'Users',
        conversation_id: 123,
      };
      BuzzdeskAPIClient.createTicket(ticketData);
      expect(axiosMock.post).toHaveBeenCalledWith(
        '/api/v1/integrations/buzzdesk/create_ticket',
        ticketData
      );
    });
  });

  describe('linkTicket', () => {
    const originalAxios = window.axios;
    const axiosMock = {
      post: vi.fn(() => Promise.resolve()),
      get: vi.fn(() => Promise.resolve()),
      patch: vi.fn(() => Promise.resolve()),
      delete: vi.fn(() => Promise.resolve()),
    };

    beforeEach(() => {
      window.axios = axiosMock;
    });

    afterEach(() => {
      window.axios = originalAxios;
    });

    it('creates a valid request', () => {
      BuzzdeskAPIClient.linkTicket(1, '42');
      expect(axiosMock.post).toHaveBeenCalledWith(
        '/api/v1/integrations/buzzdesk/link_ticket',
        {
          conversation_id: 1,
          ticket_id: '42',
        }
      );
    });
  });

  describe('unlinkTicket', () => {
    const originalAxios = window.axios;
    const axiosMock = {
      post: vi.fn(() => Promise.resolve()),
      get: vi.fn(() => Promise.resolve()),
      patch: vi.fn(() => Promise.resolve()),
      delete: vi.fn(() => Promise.resolve()),
    };

    beforeEach(() => {
      window.axios = axiosMock;
    });

    afterEach(() => {
      window.axios = originalAxios;
    });

    it('creates a valid request', () => {
      BuzzdeskAPIClient.unlinkTicket(5, 1);
      expect(axiosMock.post).toHaveBeenCalledWith(
        '/api/v1/integrations/buzzdesk/unlink_ticket',
        {
          id: 5,
          conversation_id: 1,
        }
      );
    });
  });

  describe('getLinkedTickets', () => {
    const originalAxios = window.axios;
    const axiosMock = {
      post: vi.fn(() => Promise.resolve()),
      get: vi.fn(() => Promise.resolve()),
      patch: vi.fn(() => Promise.resolve()),
      delete: vi.fn(() => Promise.resolve()),
    };

    beforeEach(() => {
      window.axios = axiosMock;
    });

    afterEach(() => {
      window.axios = originalAxios;
    });

    it('creates a valid request', () => {
      BuzzdeskAPIClient.getLinkedTickets(1);
      expect(axiosMock.get).toHaveBeenCalledWith(
        '/api/v1/integrations/buzzdesk/linked_tickets?conversation_id=1'
      );
    });
  });
});
