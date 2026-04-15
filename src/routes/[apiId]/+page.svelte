<script>
  import { onMount, onDestroy } from 'svelte';
  import { goto } from '$app/navigation';
  import { page } from '$app/stores';
  import StatusBadge from '$lib/components/StatusBadge.svelte';
  import LatencyChart from '$lib/components/LatencyChart.svelte';
  import ResultTable from '$lib/components/ResultTable.svelte';
  import { getApi, getResults, toggleEnabled, deleteApi } from '$lib/api.js';

  const apiId = $derived($page.params.apiId);

  let api = $state(null);
  let results = $state([]);
  let error = $state('');
  let toggling = $state(false);
  let refreshing = $state(false);
  let confirmDelete = $state(false);
  let timer;

  const latestResult = $derived(results[0] ?? null);

  const errorRate24h = $derived(() => {
    const cutoff = Date.now() - 24 * 60 * 60 * 1000;
    const recent = results.filter((r) => new Date(r.checkedAt).getTime() >= cutoff);
    if (recent.length === 0) return null;
    const failed = recent.filter((r) => !r.success).length;
    return Math.round((failed / recent.length) * 100);
  });

  async function fetchData() {
    refreshing = true;
    try {
      const [apiData, resultsData] = await Promise.all([
        getApi(apiId),
        getResults(apiId, 50),
      ]);
      api = apiData;
      results = resultsData;
      error = '';
    } catch (e) {
      error = e.message;
    } finally {
      refreshing = false;
    }
  }

  async function handleToggle() {
    if (!api || toggling) return;
    toggling = true;
    try {
      const { enabled } = await toggleEnabled(apiId);
      api = { ...api, enabled };
    } catch (e) {
      error = e.message;
    } finally {
      toggling = false;
    }
  }

  async function handleDelete() {
    try {
      await deleteApi(apiId);
      goto('/');
    } catch (e) {
      error = e.message;
      confirmDelete = false;
    }
  }

  onMount(() => {
    fetchData();
    timer = setInterval(fetchData, 10000);
  });
  onDestroy(() => clearInterval(timer));
</script>

<div class="topbar">
  <span class="logo">Pulse</span>
  <button class="btn-refresh" onclick={fetchData} disabled={refreshing} aria-label="Refresh">
    <svg class:spin={refreshing} xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
      <path d="M21 12a9 9 0 1 1-9-9c2.52 0 4.93 1 6.74 2.74L21 8"/>
      <path d="M21 3v5h-5"/>
    </svg>
  </button>
</div>

<div class="page">
  {#if error}
    <p class="error-banner">{error}</p>
  {/if}

  {#if api}
    <div class="detail-header">
      <button class="back" onclick={() => goto('/')}>← Back</button>
      <span class="detail-url">{api.url}</span>
      <StatusBadge {api} result={latestResult} />
      <div class="toggle" class:disabled={toggling}>
        <span class="toggle-label">{api.enabled ? 'Active' : 'Inactive'}</span>
        <button
          class="toggle-track"
          class:on={api.enabled}
          onclick={handleToggle}
          aria-label="Toggle monitoring"
        >
          <div class="toggle-thumb"></div>
        </button>
      </div>
      <button class="btn-del" onclick={() => (confirmDelete = true)}>Delete</button>
    </div>

    <div class="stats">
      <div class="stat">
        <div class="stat-label">Last latency</div>
        <div class="stat-val">
          {latestResult?.latencyMs != null ? latestResult.latencyMs : '—'}<span class="stat-unit"> ms</span>
        </div>
      </div>
      <div class="stat">
        <div class="stat-label">Error rate (24h)</div>
        <div class="stat-val">
          {errorRate24h() != null ? errorRate24h() : '—'}<span class="stat-unit">%</span>
        </div>
      </div>
      <div class="stat">
        <div class="stat-label">Consecutive failures</div>
        <div class="stat-val">
          {api.consecutiveFailures}
        </div>
      </div>
    </div>

    {#if results.length > 0}
      <LatencyChart {results} />
    {/if}

    <ResultTable {results} />
  {:else if !error}
    <p class="loading">Loading…</p>
  {/if}
</div>

{#if confirmDelete}
  <div class="backdrop" role="dialog" aria-modal="true">
    <div class="confirm-box">
      <p class="confirm-msg">Delete this API?<br /><span class="confirm-url">{api?.url}</span></p>
      <div class="confirm-actions">
        <button class="btn-cancel" onclick={() => (confirmDelete = false)}>Cancel</button>
        <button class="btn-delete" onclick={handleDelete}>Delete</button>
      </div>
    </div>
  </div>
{/if}

<style>
  .topbar {
    background: #e3e1d8;
    border-bottom: 1px solid #d4d1c5;
    padding: 14px 24px;
    position: sticky;
    top: 0;
    z-index: 10;
    display: flex;
    align-items: center;
    justify-content: space-between;
  }
  .logo { font-size: 17px; font-weight: 500; color: #1b1b2d; letter-spacing: 0.02em; }
  .btn-refresh {
    display: flex;
    align-items: center;
    justify-content: center;
    background: none;
    border: 1px solid #c8c5bc;
    border-radius: 8px;
    padding: 7px 8px;
    color: #4a4840;
  }
  .btn-refresh:disabled { opacity: 0.5; cursor: default; }
  :global(.spin) { animation: spin 0.7s linear infinite; }
  @keyframes spin { to { transform: rotate(360deg); } }
  .page { padding: 24px; }
  .detail-header {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 20px;
    flex-wrap: wrap;
  }
  .back {
    background: none;
    border: 1px solid #c8c5bc;
    border-radius: 8px;
    padding: 6px 12px;
    font-size: 13px;
    color: #1b1b2d;
    font-family: inherit;
    flex-shrink: 0;
  }
  .detail-url {
    font-size: 15px;
    font-weight: 500;
    color: #1b1b2d;
    flex: 1;
    word-break: break-all;
  }
  .toggle {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 12px;
    color: #6a6860;
    flex-shrink: 0;
  }
  .toggle.disabled { opacity: 0.5; pointer-events: none; }
  .toggle-label { font-size: 12px; color: #6a6860; }
  .toggle-track {
    width: 32px;
    height: 18px;
    background: #c8c5bc;
    border-radius: 9px;
    position: relative;
    border: none;
    transition: background 0.2s;
    flex-shrink: 0;
  }
  .toggle-track.on { background: #a8c8b8; }
  .toggle-thumb {
    width: 14px;
    height: 14px;
    background: #f5f3ed;
    border-radius: 50%;
    position: absolute;
    top: 2px;
    left: 2px;
    transition: left 0.2s;
    pointer-events: none;
  }
  .toggle-track.on .toggle-thumb { left: 16px; }
  .btn-del {
    background: none;
    border: 1px solid #d4b8b4;
    border-radius: 8px;
    padding: 6px 12px;
    font-size: 12px;
    color: #8a4a40;
    font-family: inherit;
    flex-shrink: 0;
  }
  .stats {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 12px;
    margin-bottom: 20px;
  }
  .stat {
    background: #ede9e0;
    border-radius: 10px;
    padding: 14px 16px;
  }
  .stat-label { font-size: 11px; color: #7a7870; margin-bottom: 4px; }
  .stat-val { font-size: 22px; font-weight: 500; color: #1b1b2d; }
  .stat-unit { font-size: 12px; color: #8a8780; font-weight: 400; }
  .error-banner {
    font-size: 13px;
    color: #7a2e20;
    background: #f0dcd8;
    border-radius: 8px;
    padding: 8px 12px;
    margin-bottom: 16px;
  }
  .loading { font-size: 13px; color: #8a8780; padding: 24px 0; }

  /* delete confirm dialog */
  .backdrop {
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.3);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 100;
  }
  .confirm-box {
    background: #f5f3ed;
    border: 1px solid #d8d5cb;
    border-radius: 14px;
    padding: 24px;
    width: 320px;
    max-width: 95vw;
  }
  .confirm-msg {
    font-size: 14px;
    color: #1b1b2d;
    line-height: 1.6;
    margin-bottom: 16px;
  }
  .confirm-url { font-size: 12px; color: #6a6860; word-break: break-all; }
  .confirm-actions { display: flex; justify-content: flex-end; gap: 8px; }
  .btn-cancel {
    background: none;
    border: 1px solid #c8c5bc;
    border-radius: 8px;
    padding: 7px 16px;
    font-size: 13px;
    color: #1b1b2d;
    font-family: inherit;
  }
  .btn-delete {
    background: #8a4a40;
    color: #fff;
    border: none;
    border-radius: 8px;
    padding: 7px 16px;
    font-size: 13px;
    font-family: inherit;
  }
</style>
