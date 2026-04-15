<script>
  import { onMount, onDestroy } from 'svelte';
  import Chart from 'chart.js/auto';

  /** @type {{ results: import('../types').CheckResult[] }} */
  let { results } = $props();

  let canvas;
  let chart;

  function buildChart() {
    if (!canvas) return;
    const items = [...results].reverse(); // oldest → newest
    const labels = items.map((r) => {
      const d = new Date(r.checkedAt);
      return d.toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
    });
    const data = items.map((r) => (r.success ? r.latencyMs ?? 0 : 0));
    const colors = items.map((r) => (r.success ? '#a8b89a' : '#c87060'));

    if (chart) {
      chart.data.labels = labels;
      chart.data.datasets[0].data = data.map((v, i) => (items[i].success ? v : 60));
      chart.data.datasets[0].backgroundColor = colors;
      chart.update('none');
      return;
    }

    chart = new Chart(canvas, {
      type: 'bar',
      data: {
        labels,
        datasets: [{
          data: data.map((v, i) => (items[i].success ? v : 60)),
          backgroundColor: colors,
          borderRadius: 3,
          borderSkipped: false,
        }],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false },
          tooltip: {
            callbacks: {
              label: (ctx) => {
                const r = items[ctx.dataIndex];
                return r.success ? `${r.latencyMs}ms` : `Failed${r.errorType ? ` (${r.errorType})` : ''}`;
              },
            },
          },
        },
        scales: {
          x: { display: false },
          y: { display: false, min: 0 },
        },
      },
    });
  }

  $effect(() => {
    // re-run whenever results changes
    void results;
    buildChart();
  });

  onMount(buildChart);
  onDestroy(() => chart?.destroy());
</script>

<div class="chart-box">
  <div class="chart-title">Latency trend (last {results.length} checks)</div>
  <div class="chart-area">
    <canvas bind:this={canvas}></canvas>
  </div>
</div>

<style>
  .chart-box {
    background: #f5f3ed;
    border: 1px solid #d8d5cb;
    border-radius: 12px;
    padding: 16px;
    margin-bottom: 16px;
  }
  .chart-title { font-size: 12px; color: #7a7870; margin-bottom: 12px; }
  .chart-area { position: relative; height: 100px; }
</style>
