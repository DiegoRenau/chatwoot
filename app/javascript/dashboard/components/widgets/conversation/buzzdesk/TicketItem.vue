<script setup>
import { computed } from 'vue';
import Icon from 'dashboard/components-next/icon/Icon.vue';
import TicketHeader from './TicketHeader.vue';

const props = defineProps({
  linkedTicket: {
    type: Object,
    required: true,
  },
});

const emit = defineEmits(['unlinkTicket']);

const { linkedTicket } = props;

const ticket = computed(() => linkedTicket.ticket);

const unlinkTicket = () => {
  emit('unlinkTicket', linkedTicket.id);
};
</script>

<template>
  <div class="flex flex-col gap-3">
    <div class="flex flex-col w-full">
      <TicketHeader
        :number="linkedTicket.number"
        :ticket-url="ticket?.url"
        @unlink-ticket="unlinkTicket"
      />

      <h3 class="mt-2 text-sm font-medium text-n-slate-12">
        {{ linkedTicket.title }}
      </h3>

      <p
        v-if="linkedTicket.status_unavailable"
        class="mt-1 text-xs text-n-amber-11"
      >
        {{ $t('INTEGRATION_SETTINGS.BUZZDESK.STATUS_UNAVAILABLE') }}
      </p>
    </div>

    <div
      v-if="!linkedTicket.status_unavailable"
      class="flex items-center gap-2"
    >
      <div v-if="ticket?.state" class="flex items-center gap-1">
        <Icon icon="i-lucide-activity" class="size-4 text-n-slate-11" />
        <span class="text-xs text-n-slate-12">{{ ticket.state }}</span>
      </div>

      <div
        v-if="ticket?.state && ticket?.priority"
        class="w-px h-3 bg-n-slate-4"
      />

      <div v-if="ticket?.priority" class="flex items-center gap-1">
        <Icon icon="i-lucide-flag" class="size-4 text-n-slate-11" />
        <span class="text-xs text-n-slate-12">{{ ticket.priority }}</span>
      </div>

      <div v-if="ticket?.group" class="w-px h-3 bg-n-slate-4" />

      <div v-if="ticket?.group" class="flex items-center gap-1">
        <Icon icon="i-lucide-users" class="size-4 text-n-slate-11" />
        <span class="text-xs text-n-slate-12">{{ ticket.group }}</span>
      </div>
    </div>
  </div>
</template>
