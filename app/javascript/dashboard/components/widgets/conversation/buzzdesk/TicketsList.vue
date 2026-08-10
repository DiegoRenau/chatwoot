<script setup>
import { computed, ref, onMounted, watch } from 'vue';
import { useAlert, useTrack } from 'dashboard/composables';
import { useI18n } from 'vue-i18n';
import BuzzdeskAPI from 'dashboard/api/integrations/buzzdesk';
import CreateOrLinkTicket from './CreateOrLinkTicket.vue';
import TicketItem from './TicketItem.vue';
import NextButton from 'dashboard/components-next/button/Button.vue';
import Spinner from 'dashboard/components-next/spinner/Spinner.vue';
import { BUZZDESK_EVENTS } from 'dashboard/helper/AnalyticsHelper/events';
import { parseAPIErrorResponse } from 'dashboard/store/utils/api';

const props = defineProps({
  conversationId: {
    type: [Number, String],
    required: true,
  },
});

const { t } = useI18n();

const linkedTickets = ref([]);
const isLoading = ref(false);
const shouldShowCreateModal = ref(false);

const hasTickets = computed(() => linkedTickets.value.length > 0);

const loadLinkedTickets = async () => {
  isLoading.value = true;
  linkedTickets.value = [];
  try {
    const response = await BuzzdeskAPI.getLinkedTickets(props.conversationId);
    linkedTickets.value = response.data || [];
  } catch (error) {
    // Silent fail - not critical for UX
  } finally {
    isLoading.value = false;
  }
};

const unlinkTicket = async id => {
  try {
    await BuzzdeskAPI.unlinkTicket(id, props.conversationId);
    useTrack(BUZZDESK_EVENTS.UNLINK_TICKET);
    linkedTickets.value = linkedTickets.value.filter(
      ticket => ticket.id !== id
    );
    useAlert(t('INTEGRATION_SETTINGS.BUZZDESK.UNLINK.SUCCESS'));
  } catch (error) {
    useAlert(
      parseAPIErrorResponse(
        error,
        t('INTEGRATION_SETTINGS.BUZZDESK.UNLINK.ERROR')
      )
    );
  }
};

const openCreateModal = () => {
  shouldShowCreateModal.value = true;
};

const closeCreateModal = () => {
  shouldShowCreateModal.value = false;
  loadLinkedTickets();
};

watch(
  () => props.conversationId,
  () => {
    loadLinkedTickets();
  }
);

onMounted(() => {
  loadLinkedTickets();
});
</script>

<template>
  <div>
    <div class="px-4 pt-3 pb-2">
      <NextButton
        ghost
        xs
        icon="i-lucide-plus"
        :label="$t('INTEGRATION_SETTINGS.BUZZDESK.ADD_OR_LINK_BUTTON')"
        @click="openCreateModal"
      />
    </div>

    <div v-if="isLoading" class="flex justify-center p-8">
      <Spinner />
    </div>

    <div v-else-if="!hasTickets" class="flex justify-center p-4">
      <p class="text-sm text-n-slate-11">
        {{ $t('INTEGRATION_SETTINGS.BUZZDESK.NO_LINKED_TICKETS') }}
      </p>
    </div>

    <div v-else class="max-h-[300px] overflow-y-auto">
      <TicketItem
        v-for="linkedTicket in linkedTickets"
        :key="linkedTicket.id"
        class="px-4 pt-3 pb-4 border-b border-n-weak last:border-b-0"
        :linked-ticket="linkedTicket"
        @unlink-ticket="unlinkTicket"
      />
    </div>

    <woot-modal
      v-model:show="shouldShowCreateModal"
      :on-close="closeCreateModal"
      :close-on-backdrop-click="false"
      class="!items-start [&>div]:!top-12 [&>div]:sticky"
    >
      <CreateOrLinkTicket
        :conversation-id="conversationId"
        @close="closeCreateModal"
      />
    </woot-modal>
  </div>
</template>
