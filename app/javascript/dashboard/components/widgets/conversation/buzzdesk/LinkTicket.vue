<script setup>
import { ref, computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { useTrack, useAlert } from 'dashboard/composables';
import BuzzdeskAPI from 'dashboard/api/integrations/buzzdesk';
import FilterButton from 'dashboard/components/ui/Dropdown/DropdownButton.vue';
import FilterListDropdown from 'dashboard/components/ui/Dropdown/DropdownList.vue';
import { parseAPIErrorResponse } from 'dashboard/store/utils/api';
import { BUZZDESK_EVENTS } from 'dashboard/helper/AnalyticsHelper/events';
import Button from 'dashboard/components-next/button/Button.vue';

const props = defineProps({
  conversationId: {
    type: [Number, String],
    required: true,
  },
});

const emit = defineEmits(['close']);

const { t } = useI18n();
const tickets = ref([]);
const shouldShowDropdown = ref(false);
const selectedOption = ref({ id: null, name: '' });
const isFetching = ref(false);
const isLinking = ref(false);

const toggleDropdown = () => {
  tickets.value = [];
  shouldShowDropdown.value = !shouldShowDropdown.value;
};

const linkTicketTitle = computed(() => {
  return selectedOption.value.id
    ? selectedOption.value.name
    : t('INTEGRATION_SETTINGS.BUZZDESK.LINK.SELECT');
});

const isSubmitDisabled = computed(() => {
  return !selectedOption.value.id || isLinking.value;
});

const onSelectTicket = item => {
  selectedOption.value = item;
  toggleDropdown();
};

const onClose = () => {
  emit('close');
};

const onSearch = async value => {
  tickets.value = [];
  if (!value) return;
  try {
    isFetching.value = true;
    const response = await BuzzdeskAPI.searchTickets(value);
    tickets.value = response.data.map(ticket => ({
      id: ticket.id,
      name: `#${ticket.number} ${ticket.title}`,
    }));
  } catch (error) {
    useAlert(
      parseAPIErrorResponse(
        error,
        t('INTEGRATION_SETTINGS.BUZZDESK.LINK.ERROR')
      )
    );
  } finally {
    isFetching.value = false;
  }
};

const linkTicket = async () => {
  const { id: ticketId } = selectedOption.value;
  try {
    isLinking.value = true;
    await BuzzdeskAPI.linkTicket(props.conversationId, ticketId);
    useAlert(t('INTEGRATION_SETTINGS.BUZZDESK.LINK.LINK_SUCCESS'));
    tickets.value = [];
    onClose();
    useTrack(BUZZDESK_EVENTS.LINK_TICKET);
  } catch (error) {
    useAlert(
      parseAPIErrorResponse(
        error,
        t('INTEGRATION_SETTINGS.BUZZDESK.LINK.LINK_ERROR')
      )
    );
  } finally {
    isLinking.value = false;
  }
};
</script>

<template>
  <div
    class="flex flex-col justify-between"
    :class="shouldShowDropdown ? 'h-[256px]' : 'gap-2'"
  >
    <FilterButton
      trailing-icon
      icon="i-lucide-chevron-down"
      :button-text="linkTicketTitle"
      class="justify-between w-full h-[2.5rem] py-1.5 px-3 rounded-xl bg-n-alpha-black2 outline outline-1 outline-n-weak dark:outline-n-weak hover:outline-n-slate-6 dark:hover:outline-n-slate-6"
      @click="toggleDropdown"
    >
      <template v-if="shouldShowDropdown" #dropdown>
        <FilterListDropdown
          v-if="tickets"
          v-on-clickaway="toggleDropdown"
          :show-clear-filter="false"
          :list-items="tickets"
          :active-filter-id="selectedOption.id"
          :is-loading="isFetching"
          :input-placeholder="$t('INTEGRATION_SETTINGS.BUZZDESK.LINK.SEARCH')"
          :loading-placeholder="
            $t('INTEGRATION_SETTINGS.BUZZDESK.LINK.LOADING')
          "
          enable-search
          class="left-0 flex flex-col w-full overflow-y-auto h-fit !max-h-[160px] md:left-auto md:right-0 top-10"
          @on-search="onSearch"
          @select="onSelectTicket"
        />
      </template>
    </FilterButton>
    <div class="flex items-center justify-end w-full gap-2 mt-2">
      <Button
        faded
        slate
        type="reset"
        :label="$t('INTEGRATION_SETTINGS.BUZZDESK.ADD_OR_LINK.CANCEL')"
        @click.prevent="onClose"
      />
      <Button
        type="submit"
        :label="$t('INTEGRATION_SETTINGS.BUZZDESK.LINK.TITLE')"
        :disabled="isSubmitDisabled"
        :is-loading="isLinking"
        @click.prevent="linkTicket"
      />
    </div>
  </div>
</template>
