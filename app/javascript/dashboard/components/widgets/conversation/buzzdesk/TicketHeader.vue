<script setup>
import Button from 'dashboard/components-next/button/Button.vue';
import Icon from 'dashboard/components-next/icon/Icon.vue';

const props = defineProps({
  number: {
    type: String,
    required: true,
  },
  ticketUrl: {
    type: String,
    default: null,
  },
});

const emit = defineEmits(['unlinkTicket']);

const unlinkTicket = () => {
  emit('unlinkTicket');
};

const openTicket = () => {
  if (!props.ticketUrl) return;
  window.open(props.ticketUrl, '_blank');
};
</script>

<template>
  <div class="flex items-center justify-between">
    <div
      class="flex items-center gap-2 px-2 py-1.5 border rounded-lg border-n-strong"
    >
      <div class="flex items-center gap-1">
        <Icon icon="i-lucide-ticket" class="size-4 text-n-slate-11" />
        <span class="text-xs font-medium text-n-slate-12"> #{{ number }} </span>
      </div>
      <span class="w-px h-3 text-n-weak bg-n-weak" />

      <Button
        link
        xs
        slate
        icon="i-lucide-arrow-up-right"
        class="!size-4"
        :disabled="!ticketUrl"
        @click="openTicket"
      />
    </div>

    <Button ghost xs slate icon="i-lucide-unlink" @click="unlinkTicket" />
  </div>
</template>
