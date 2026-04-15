<script>
  import StatusBadge from './StatusBadge.svelte';
  import { goto } from '$app/navigation';

  /** @type {{ api: import('../types').Api, result?: import('../types').CheckResult | null }} */
  let { api, result = null } = $props();

  function formatTime(iso) {
    if (!iso) return '—';
    const d = new Date(iso);
    const diff = Math.floor((Date.now() - d) / 1000);
    if (diff < 10) return 'just now';
    if (diff < 60) return `${diff}s ago`;
    if (diff < 3600) return `${Math.floor(diff / 60)}m ago`;
    return d.toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit' });
  }
</script>

<div class="card" role="button" tabindex="0"
  onclick={() => goto(`/${api.apiId}`)}
  onkeydown={(e) => e.key === 'Enter' && goto(`/${api.apiId}`)}>
  <div class="card-top">
    <span class="card-url">{api.url}</span>
    <StatusBadge {api} {result} />
  </div>
  <div class="card-meta">
    <div class="meta-item">
      <span class="meta-label">Latency</span>
      <span class="meta-val">{result?.latencyMs != null ? `${result.latencyMs}ms` : '—'}</span>
    </div>
    <div class="meta-item">
      <span class="meta-label">Last check</span>
      <span class="meta-val">{formatTime(result?.checkedAt)}</span>
    </div>
  </div>
  {#if api.consecutiveFailures > 0}
    <div class="fail-count">{api.consecutiveFailures} consecutive failures</div>
  {/if}
</div>

<style>
  .card {
    background: #f5f3ed;
    border: 1px solid #d8d5cb;
    border-radius: 12px;
    padding: 16px;
    cursor: pointer;
    transition: background 0.15s;
  }
  .card:hover { background: #f0ede5; }
  .card-top {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    margin-bottom: 10px;
  }
  .card-url {
    font-size: 13px;
    font-weight: 500;
    color: #1b1b2d;
    word-break: break-all;
    flex: 1;
    margin-right: 8px;
  }
  .card-meta { display: flex; gap: 16px; margin-top: 8px; }
  .meta-item { display: flex; flex-direction: column; gap: 2px; }
  .meta-label { font-size: 11px; color: #8a8780; }
  .meta-val { font-size: 13px; color: #1b1b2d; font-weight: 500; }
  .fail-count {
    display: inline-block;
    margin-top: 8px;
    font-size: 11px;
    background: #f0dcd8;
    color: #7a2e20;
    border-radius: 6px;
    padding: 2px 8px;
  }
</style>
