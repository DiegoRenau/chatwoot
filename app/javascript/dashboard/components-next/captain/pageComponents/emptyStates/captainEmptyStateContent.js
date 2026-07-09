import { INBOX_TYPES } from 'dashboard/helper/inbox';

export const assistantsList = [
  {
    account_id: 2,
    config: { product_name: 'HelpDesk Pro' },
    created_at: 1736033561,
    description:
      'Un asistente de IA avanzado diseñado para mejorar las soluciones de atención al cliente automatizando flujos de trabajo y ofreciendo respuestas instantáneas.',
    id: 4,
    name: 'Support Genie',
  },
  {
    account_id: 3,
    config: { product_name: 'CRM Tools' },
    created_at: 1736033562,
    description:
      'Ayuda a optimizar la gestión de relaciones con los clientes organizando contactos, automatizando seguimientos y aportando información útil.',
    id: 5,
    name: 'CRM Assistant',
  },
  {
    account_id: 4,
    config: { product_name: 'SalesFlow' },
    created_at: 1736033563,
    description:
      'Optimiza tu embudo de ventas dando seguimiento a los prospectos, previendo las ventas y automatizando las tareas administrativas.',
    id: 6,
    name: 'SalesBot',
  },
  {
    account_id: 5,
    config: { product_name: 'TicketMaster AI' },
    created_at: 1736033564,
    description:
      'Automatiza la asignación y categorización de tickets y las respuestas a las consultas de los clientes para mejorar la eficiencia del soporte.',
    id: 7,
    name: 'TicketBot',
  },
  {
    account_id: 6,
    config: { product_name: 'FinanceAssist' },
    created_at: 1736033565,
    description:
      'Ofrece analíticas, informes e información financiera que ayudan a los equipos a tomar decisiones financieras basadas en datos.',
    id: 8,
    name: 'Finance Wizard',
  },
  {
    account_id: 8,
    config: { product_name: 'HR Assistant' },
    created_at: 1736033567,
    description:
      'Optimiza las operaciones de RR. HH., incluida la gestión de empleados, la nómina y los procesos de reclutamiento.',
    id: 10,
    name: 'HR Helper',
  },
];

export const documentsList = [
  {
    account_id: 1,
    assistant: { id: 1, name: 'Helper Pro' },
    content:
      'Guía completa sobre cómo usar los filtros de conversación para gestionar los chats de forma eficaz.',
    created_at: 1736143272,
    external_link:
      'https://www.buzzcrm.ai/hc/user-guide/articles/1677688192-how-to-use-conversation-filters',
    id: 3059,
    name: '¿Cómo usar los filtros de conversación? | Guía del usuario | BuzzCRM',
    status: 'available',
  },
  {
    account_id: 2,
    assistant: { id: 2, name: 'Support Genie' },
    content:
      'Guía paso a paso para automatizar la asignación de tickets y mejorar el flujo de trabajo de soporte en BuzzCRM.',
    created_at: 1736143273,
    external_link:
      'https://www.buzzcrm.ai/hc/user-guide/articles/1677688200-automating-ticket-assignments',
    id: 3060,
    name: 'Automatizar la asignación de tickets | Guía del usuario | BuzzCRM',
    status: 'available',
  },
  {
    account_id: 3,
    assistant: { id: 3, name: 'CRM Assistant' },
    content:
      'Una guía detallada sobre cómo gestionar y organizar los perfiles de clientes para mejorar la gestión de relaciones.',
    created_at: 1736143274,
    external_link:
      'https://www.buzzcrm.ai/hc/user-guide/articles/1677688210-managing-customer-profiles',
    id: 3061,
    name: 'Gestionar perfiles de clientes | Guía del usuario | BuzzCRM',
    status: 'available',
  },
  {
    account_id: 4,
    assistant: { id: 4, name: 'SalesBot' },
    content:
      'Aprende a optimizar el seguimiento de ventas y a mejorar tus previsiones de ventas usando funciones avanzadas.',
    created_at: 1736143275,
    external_link:
      'https://www.buzzcrm.ai/hc/user-guide/articles/1677688220-sales-tracking-guide',
    id: 3062,
    name: 'Guía de seguimiento de ventas | Guía del usuario | BuzzCRM',
    status: 'available',
  },
  {
    account_id: 5,
    assistant: { id: 5, name: 'TicketBot' },
    content:
      'Cómo crear, gestionar y resolver tickets de forma eficiente en BuzzCRM.',
    created_at: 1736143276,
    external_link:
      'https://www.buzzcrm.ai/hc/user-guide/articles/1677688230-managing-tickets',
    id: 3063,
    name: 'Gestión de tickets | Guía del usuario | BuzzCRM',
    status: 'available',
  },
  {
    account_id: 6,
    assistant: { id: 6, name: 'Finance Wizard' },
    content:
      'Guía detallada sobre cómo usar las herramientas de informes financieros y generar analíticas útiles.',
    created_at: 1736143277,
    external_link:
      'https://www.buzzcrm.ai/hc/user-guide/articles/1677688240-financial-reporting',
    id: 3064,
    name: 'Informes financieros | Guía del usuario | BuzzCRM',
    status: 'available',
  },
];

export const responsesList = [
  {
    account_id: 1,
    answer:
      'Messenger puede estar desactivado porque estás en un plan gratuito o porque se alcanzó el límite de bandejas de entrada.',
    created_at: 1736283330,
    id: 87,
    question: '¿Por qué está desactivado mi Messenger en BuzzCRM?',
    status: 'pending',
    assistant: {
      account_id: 1,
      config: { product_name: 'BuzzCRM' },
      created_at: 1736033280,
      description:
        'Ayuda con consultas generales y problemas de todo el sistema.',
      id: 1,
      name: 'Assistant 2',
    },
  },
  {
    account_id: 2,
    answer:
      'Puedes integrar tu cuenta de WhatsApp yendo a la sección de Integraciones y seleccionando la opción de integración de WhatsApp.',
    created_at: 1736283340,
    id: 88,
    question: '¿Cómo integro WhatsApp con BuzzCRM?',
    assistant: {
      account_id: 2,
      config: { product_name: 'BuzzCRM' },
      created_at: 1736033281,
      description: 'Ayuda con consultas sobre integraciones y configuración.',
      id: 2,
      name: 'Assistant 3',
    },
  },
  {
    account_id: 3,
    answer:
      "Para restablecer tu contraseña, ve a la página de inicio de sesión y haz clic en 'Olvidé mi contraseña', luego sigue las instrucciones enviadas a tu email.",
    created_at: 1736283350,
    id: 89,
    question: '¿Cómo restablezco mi contraseña en BuzzCRM?',
    assistant: {
      account_id: 3,
      config: { product_name: 'BuzzCRM' },
      created_at: 1736033282,
      description:
        'Se encarga de la gestión de la cuenta y del soporte de recuperación.',
      id: 3,
      name: 'Assistant 4',
    },
  },
  {
    account_id: 4,
    answer:
      "Puedes activar el modo oscuro en la configuración yendo a 'Apariencia' y seleccionando 'Modo oscuro'.",
    created_at: 1736283360,
    id: 90,
    question: '¿Cómo activo el modo oscuro en BuzzCRM?',
    assistant: {
      account_id: 4,
      config: { product_name: 'BuzzCRM' },
      created_at: 1736033283,
      description: 'Ayuda con consultas sobre la interfaz y los temas.',
      id: 4,
      name: 'Assistant 5',
    },
  },
  {
    account_id: 5,
    answer:
      "Para agregar un nuevo miembro del equipo, ve a 'Configuración', luego a 'Equipo' y haz clic en 'Agregar miembro del equipo'.",
    created_at: 1736283370,
    id: 91,
    question: '¿Cómo agrego un nuevo miembro del equipo en BuzzCRM?',
    assistant: {
      account_id: 5,
      config: { product_name: 'BuzzCRM' },
      created_at: 1736033284,
      description:
        'Da soporte a la gestión de equipos y a consultas sobre el acceso de usuarios.',
      id: 5,
      name: 'Assistant 6',
    },
  },
  {
    account_id: 6,
    answer:
      "Las campañas en BuzzCRM te permiten enviar mensajes dirigidos a segmentos específicos de usuarios. Puedes crearlas en la sección 'Campañas'.",
    created_at: 1736283380,
    id: 92,
    question: '¿Qué son las campañas en BuzzCRM?',
    assistant: {
      account_id: 6,
      config: { product_name: 'BuzzCRM' },
      created_at: 1736033285,
      description:
        'Especializado en marketing, gestión de campañas y estrategias de mensajería.',
      id: 6,
      name: 'Assistant 7',
    },
  },
];

export const inboxes = [
  {
    id: 7,
    name: 'Soporte por email',
    channel_type: INBOX_TYPES.EMAIL,
    email: 'support@company.com',
  },
  {
    id: 1,
    name: 'Chat del sitio web',
    channel_type: INBOX_TYPES.WEB,
  },
  {
    id: 2,
    name: 'Soporte de Facebook',
    channel_type: INBOX_TYPES.FB,
  },
  {
    id: 5,
    name: 'Servicio de SMS',
    channel_type: INBOX_TYPES.TWILIO,
    messaging_service_sid: 'MGxxxxxx',
  },
  {
    id: 6,
    name: 'Soporte de WhatsApp',
    channel_type: INBOX_TYPES.WHATSAPP,
    phone_number: '+1987654321',
  },
  {
    id: 8,
    name: 'Soporte de Telegram',
    channel_type: INBOX_TYPES.TELEGRAM,
  },
  {
    id: 9,
    name: 'Soporte de LINE',
    channel_type: INBOX_TYPES.LINE,
  },
  {
    id: 10,
    name: 'Canal de API',
    channel_type: INBOX_TYPES.API,
  },
  {
    id: 11,
    name: 'SMS básico',
    channel_type: INBOX_TYPES.SMS,
    phone_number: '+1555555555',
  },
];
