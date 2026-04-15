<script>
  import { onMount, onDestroy } from 'svelte';
  import ApiCard from '$lib/components/ApiCard.svelte';
  import RegisterModal from '$lib/components/RegisterModal.svelte';
  import { getApis, getResults } from '$lib/api.js';

  let apis = $state([]);
  let latestResults = $state({});
  let showModal = $state(false);
  let error = $state('');
  let refreshing = $state(false);
  let timer;

  async function fetchAll() {
    refreshing = true;
    try {
      const list = await getApis();
      apis = list;
      error = '';
      // fetch latest result for each API concurrently
      const entries = await Promise.allSettled(
        list.map(async (api) => {
          const results = await getResults(api.apiId, 1);
          return [api.apiId, results[0] ?? null];
        })
      );
      const map = {};
      for (const e of entries) {
        if (e.status === 'fulfilled') {
          const [id, result] = e.value;
          map[id] = result;
        }
      }
      latestResults = map;
    } catch (e) {
      error = e.message;
    } finally {
      refreshing = false;
    }
  }

  onMount(() => {
    fetchAll();
    timer = setInterval(fetchAll, 10000);
  });
  onDestroy(() => clearInterval(timer));
</script>

<div class="topbar">
  <span class="logo">Pulse</span>
  <div class="topbar-actions">
    <button class="btn-refresh" onclick={fetchAll} disabled={refreshing} aria-label="Refresh">
      <svg class:spin={refreshing} xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M21 12a9 9 0 1 1-9-9c2.52 0 4.93 1 6.74 2.74L21 8"/>
        <path d="M21 3v5h-5"/>
      </svg>
    </button>
    <button class="btn-reg" onclick={() => (showModal = true)}>+ Add API</button>
  </div>
</div>

<div class="page">
  {#if error}
    <p class="error-banner">{error}</p>
  {/if}

  <div class="section-label">
    Monitoring · {apis.length} APIs
  </div>

  {#if apis.length === 0 && !error}
    <p class="empty">No APIs registered yet.</p>
  {:else}
    <div class="cards">
      {#each apis as api (api.apiId)}
        <ApiCard {api} result={latestResults[api.apiId] ?? null} />
      {/each}
    </div>
  {/if}
</div>

{#if showModal}
  <RegisterModal
    onclose={() => (showModal = false)}
    onregistered={fetchAll}
  />
{/if}

<style>
  .topbar {
    background: #e3e1d8;
    border-bottom: 1px solid #d4d1c5;
    padding: 14px 24px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    position: sticky;
    top: 0;
    z-index: 10;
  }
  .logo { font-size: 17px; font-weight: 500; color: #1b1b2d; letter-spacing: 0.02em; }
  .topbar-actions { display: flex; align-items: center; gap: 8px; }
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
  .btn-refresh svg { display: block; }
  :global(.spin) { animation: spin 0.7s linear infinite; }
  @keyframes spin { to { transform: rotate(360deg); } }
  .btn-reg {
    background: #1b1b2d;
    color: #ececec;
    border: none;
    border-radius: 8px;
    padding: 7px 16px;
    font-size: 13px;
    font-family: inherit;
  }
  .page { padding: 24px; }
  .section-label {
    font-size: 11px;
    font-weight: 500;
    color: #7a7870;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    margin-bottom: 12px;
  }
  .cards {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 12px;
  }
  .empty { font-size: 13px; color: #8a8780; padding: 24px 0; }
  .error-banner {
    font-size: 13px;
    color: #7a2e20;
    background: #f0dcd8;
    border-radius: 8px;
    padding: 8px 12px;
    margin-bottom: 16px;
  }
</style>
