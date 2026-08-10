<script setup>
import { reactive, computed, onMounted, ref } from 'vue';
import { useVuelidate } from '@vuelidate/core';
import { useI18n } from 'vue-i18n';
import { useTrack, useAlert } from 'dashboard/composables';
import BuzzdeskAPI from 'dashboard/api/integrations/buzzdesk';
import validations from './validations';
import { parseAPIErrorResponse } from 'dashboard/store/utils/api';
import FilterButton from 'dashboard/components/ui/Dropdown/DropdownButton.vue';
import FilterListDropdown from 'dashboard/components/ui/Dropdown/DropdownList.vue';
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

const groups = ref([]);
const shouldShowGroupDropdown = ref(false);
const isCreating = ref(false);
const inputStyles = { borderRadius: '0.75rem', fontSize: '0.875rem' };

const formState = reactive({
  title: '',
  description: '',
  group: '',
});
const v$ = useVuelidate(validations, formState);

const isSubmitDisabled = computed(
  () => v$.value.title.$invalid || v$.value.group.$invalid || isCreating.value
);
const titleError = computed(() =>
  v$.value.title.$error
    ? t('INTEGRATION_SETTINGS.BUZZDESK.ADD_OR_LINK.FORM.TITLE.REQUIRED_ERROR')
    : ''
);
const groupError = computed(() =>
  v$.value.group.$error
    ? t('INTEGRATION_SETTINGS.BUZZDESK.ADD_OR_LINK.FORM.GROUP.REQUIRED_ERROR')
    : ''
);

const groupButtonText = computed(
  () =>
    formState.group ||
    t('INTEGRATION_SETTINGS.BUZZDESK.ADD_OR_LINK.FORM.GROUP.PLACEHOLDER')
);

const onClose = () => emit('close');

const toggleGroupDropdown = () => {
  shouldShowGroupDropdown.value = !shouldShowGroupDropdown.value;
};

const onSelectGroup = item => {
  formState.group = item.name;
  toggleGroupDropdown();
  v$.value.group.$touch();
};

const getGroups = async () => {
  try {
    const response = await BuzzdeskAPI.getGroups();
    groups.value = response.data.map(group => ({
      id: group.id,
      name: group.name,
    }));
  } catch (error) {
    useAlert(
      parseAPIErrorResponse(
        error,
        t('INTEGRATION_SETTINGS.BUZZDESK.ADD_OR_LINK.LOADING_GROUPS_ERROR')
      )
    );
  }
};

const createTicket = async () => {
  v$.value.$touch();
  if (v$.value.$invalid) return;

  const payload = {
    conversation_id: props.conversationId,
    title: formState.title,
    description: formState.description || undefined,
    group: formState.group,
  };

  try {
    isCreating.value = true;
    await BuzzdeskAPI.createTicket(payload);
    useAlert(t('INTEGRATION_SETTINGS.BUZZDESK.ADD_OR_LINK.CREATE_SUCCESS'));
    useTrack(BUZZDESK_EVENTS.CREATE_TICKET);
    onClose();
  } catch (error) {
    useAlert(
      parseAPIErrorResponse(
        error,
        t('INTEGRATION_SETTINGS.BUZZDESK.ADD_OR_LINK.CREATE_ERROR')
      )
    );
  } finally {
    isCreating.value = false;
  }
};

onMounted(getGroups);
</script>

<template>
  <div>
    <woot-input
      v-model="formState.title"
      :class="{ error: v$.title.$error }"
      class="w-full"
      :styles="{ ...inputStyles, padding: '0.375rem 0.75rem' }"
      :label="$t('INTEGRATION_SETTINGS.BUZZDESK.ADD_OR_LINK.FORM.TITLE.LABEL')"
      :placeholder="
        $t('INTEGRATION_SETTINGS.BUZZDESK.ADD_OR_LINK.FORM.TITLE.PLACEHOLDER')
      "
      :error="titleError"
      @input="v$.title.$touch"
    />
    <label>
      {{
        $t('INTEGRATION_SETTINGS.BUZZDESK.ADD_OR_LINK.FORM.DESCRIPTION.LABEL')
      }}
      <textarea
        v-model="formState.description"
        :style="{ ...inputStyles, padding: '0.5rem 0.75rem' }"
        rows="3"
        class="text-sm"
        :placeholder="
          $t(
            'INTEGRATION_SETTINGS.BUZZDESK.ADD_OR_LINK.FORM.DESCRIPTION.PLACEHOLDER'
          )
        "
      />
    </label>
    <label :class="{ error: groupError }">
      {{ $t('INTEGRATION_SETTINGS.BUZZDESK.ADD_OR_LINK.FORM.GROUP.LABEL') }}
      <FilterButton
        trailing-icon
        icon="i-lucide-chevron-down"
        :button-text="groupButtonText"
        class="justify-between w-full h-[2.5rem] py-1.5 px-3 rounded-xl bg-n-alpha-black2 outline outline-1 outline-n-weak dark:outline-n-weak hover:outline-n-slate-6 dark:hover:outline-n-slate-6"
        @click="toggleGroupDropdown"
      >
        <template v-if="shouldShowGroupDropdown" #dropdown>
          <FilterListDropdown
            v-on-clickaway="toggleGroupDropdown"
            :show-clear-filter="false"
            :list-items="groups"
            :active-filter-id="formState.group"
            :input-placeholder="
              $t('INTEGRATION_SETTINGS.BUZZDESK.ADD_OR_LINK.FORM.GROUP.SEARCH')
            "
            enable-search
            class="left-0 flex flex-col w-full overflow-y-auto h-fit !max-h-[160px] md:left-auto md:right-0 top-10"
            @select="onSelectGroup"
          />
        </template>
      </FilterButton>
      <span v-if="groupError" class="mt-1 message">{{ groupError }}</span>
    </label>
    <div class="flex items-center justify-end w-full gap-2 mt-8">
      <Button
        faded
        slate
        type="reset"
        :label="$t('INTEGRATION_SETTINGS.BUZZDESK.ADD_OR_LINK.CANCEL')"
        @click.prevent="onClose"
      />
      <Button
        type="submit"
        :label="$t('INTEGRATION_SETTINGS.BUZZDESK.ADD_OR_LINK.CREATE')"
        :disabled="isSubmitDisabled"
        :is-loading="isCreating"
        @click.prevent="createTicket"
      />
    </div>
  </div>
</template>
