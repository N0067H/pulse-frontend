<script>
  /** @type {{ results: import('../types').CheckResult[] }} */
  let { results } = $props();

  function formatTime(iso) {
    if (!iso) return '—';
    const d = new Date(iso);
    return d.toLocaleString('ko-KR', {
      month: '2-digit', day: '2-digit',
      hour: '2-digit', minute: '2-digit', second: '2-digit',
    });
  }
</script>

<div class="table-box">
  <table class="tbl">
    <thead>
      <tr>
        <th style="width:30%">Time</th>
        <th style="width:15%">Status</th>
        <th style="width:18%">Latency</th>
        <th style="width:15%">Result</th>
        <th style="width:22%">Error type</th>
      </tr>
    </thead>
    <tbody>
      {#each results as r (r.checkedAt)}
        <tr>
          <td>{formatTime(r.checkedAt)}</td>
          <td>{r.statusCode ?? '—'}</td>
          <td>{r.latencyMs != null ? `${r.latencyMs}ms` : '—'}</td>
          <td>
            <span class="badge-sm {r.success ? 'ok' : 'fail'}">
              {r.success ? 'OK' : 'Failed'}
            </span>
          </td>
          <td class="error-type">{r.errorType ?? ''}</td>
        </tr>
      {/each}
      {#if results.length === 0}
        <tr><td colspan="5" class="empty">No results yet.</td></tr>
      {/if}
    </tbody>
  </table>
</div>

<style>
  .table-box {
    background: #f5f3ed;
    border: 1px solid #d8d5cb;
    border-radius: 12px;
    overflow: hidden;
  }
  .tbl {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;
    font-size: 12px;
  }
  .tbl th {
    background: #ede9e0;
    color: #7a7870;
    font-weight: 500;
    padding: 8px 12px;
    text-align: left;
    border-bottom: 1px solid #d8d5cb;
  }
  .tbl td {
    padding: 8px 12px;
    color: #1b1b2d;
    border-bottom: 1px solid #ece9e1;
  }
  .tbl tr:last-child td { border-bottom: none; }
  .badge-sm {
    font-size: 10px;
    border-radius: 5px;
    padding: 2px 6px;
    font-weight: 500;
  }
  .ok   { background: #d4e0c6; color: #3a5830; }
  .fail { background: #e4cdc8; color: #7a2e20; }
  .error-type { color: #8a4a40; font-size: 11px; }
  .empty { text-align: center; color: #8a8780; padding: 24px; }
</style>
