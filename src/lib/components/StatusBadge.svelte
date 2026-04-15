<script>
  /** @type {{ api: import('../types').Api, result?: import('../types').CheckResult | null }} */
  let { api, result = null } = $props();

  const label = $derived(
    !api.enabled ? 'Inactive' : result?.success === false ? 'Failed' : result?.success === true ? 'OK' : '—'
  );
  const cls = $derived(
    !api.enabled ? 'off' : result?.success === false ? 'fail' : result?.success === true ? 'ok' : 'neutral'
  );
</script>

<span class="badge {cls}">{label}</span>

<style>
  .badge {
    font-size: 11px;
    font-weight: 500;
    border-radius: 6px;
    padding: 3px 8px;
    white-space: nowrap;
  }
  .ok   { background: #d4e0c6; color: #3a5830; }
  .fail { background: #e4cdc8; color: #7a2e20; }
  .off  { background: #e0ddd6; color: #5a574f; }
  .neutral { background: #e8e5de; color: #6a6860; }
</style>
