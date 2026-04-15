<script>
  import { registerApi } from '$lib/api.js';

  /** @type {{ onclose: () => void, onregistered: () => void }} */
  let { onclose, onregistered } = $props();

  let form = $state({
    url: '',
    method: 'GET',
    interval_seconds: 180,
    timeout_seconds: 5,
    retry_count: 2,
    alert_threshold: 3,
    alert_cooldown_seconds: 3600,
  });
  let error = $state('');
  let loading = $state(false);

  async function submit() {
    error = '';
    loading = true;
    try {
      await registerApi(form);
      onregistered();
      onclose();
    } catch (e) {
      error = e.message;
    } finally {
      loading = false;
    }
  }
</script>

<div class="backdrop" role="dialog" aria-modal="true">
  <div class="modal">
    <h2 class="modal-title">Register API</h2>
    <div class="fields">
      <label>
        <span>URL</span>
        <input type="text" bind:value={form.url} placeholder="https://example.com/api" />
      </label>
      <label>
        <span>Method</span>
        <select bind:value={form.method}>
          <option>GET</option>
          <option>POST</option>
          <option>PUT</option>
          <option>PATCH</option>
          <option>DELETE</option>
        </select>
      </label>
      <label>
        <span>Interval (seconds)</span>
        <input type="number" bind:value={form.interval_seconds} min="1" />
      </label>
      <label>
        <span>Timeout (seconds)</span>
        <input type="number" bind:value={form.timeout_seconds} min="1" />
      </label>
      <label>
        <span>Retry count (0–2)</span>
        <input type="number" bind:value={form.retry_count} min="0" max="2" />
      </label>
      <label>
        <span>Alert threshold (consecutive failures)</span>
        <input type="number" bind:value={form.alert_threshold} min="1" />
      </label>
      <label>
        <span>Alert cooldown (seconds)</span>
        <input type="number" bind:value={form.alert_cooldown_seconds} min="0" />
      </label>
    </div>
    {#if error}
      <p class="error">{error}</p>
    {/if}
    <div class="actions">
      <button class="btn-cancel" onclick={onclose}>Cancel</button>
      <button class="btn-submit" onclick={submit} disabled={loading}>
        {loading ? 'Registering…' : 'Register'}
      </button>
    </div>
  </div>
</div>

<style>
  .backdrop {
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.3);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 100;
  }
  .modal {
    background: #f5f3ed;
    border: 1px solid #d8d5cb;
    border-radius: 14px;
    padding: 24px;
    width: 400px;
    max-width: 95vw;
  }
  .modal-title {
    font-size: 15px;
    font-weight: 600;
    color: #1b1b2d;
    margin-bottom: 16px;
  }
  .fields { display: flex; flex-direction: column; gap: 10px; }
  label { display: flex; flex-direction: column; gap: 4px; }
  label span { font-size: 12px; color: #6a6860; }
  input, select {
    font-family: inherit;
    font-size: 13px;
    color: #1b1b2d;
    background: #ececec;
    border: 1px solid #d4d1c5;
    border-radius: 8px;
    padding: 7px 10px;
    outline: none;
    transition: border-color 0.15s;
  }
  input:focus, select:focus { border-color: #9a9890; }
  .error {
    margin-top: 8px;
    font-size: 12px;
    color: #7a2e20;
    background: #f0dcd8;
    border-radius: 6px;
    padding: 6px 10px;
  }
  .actions { display: flex; justify-content: flex-end; gap: 8px; margin-top: 16px; }
  .btn-cancel {
    background: none;
    border: 1px solid #c8c5bc;
    border-radius: 8px;
    padding: 7px 16px;
    font-size: 13px;
    color: #1b1b2d;
    cursor: pointer;
    font-family: inherit;
  }
  .btn-submit {
    background: #1b1b2d;
    color: #ececec;
    border: none;
    border-radius: 8px;
    padding: 7px 16px;
    font-size: 13px;
    cursor: pointer;
    font-family: inherit;
  }
  .btn-submit:disabled { opacity: 0.5; cursor: default; }
</style>
