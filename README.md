# pulse-frontend

SvelteKit frontend for [Pulse](../pulse-backend) — a lightweight API uptime monitoring dashboard.

## Stack

- [SvelteKit](https://svelte.dev/docs/kit) (Svelte 5)
- [Chart.js](https://www.chartjs.org/) — latency trend chart
- Polling every 10 seconds (no WebSocket)

## Development

Requires the backend (`pulse-backend`) running on `http://localhost:8080`.

```sh
npm install
npm run dev
```

Opens at `http://localhost:5173`. The Vite dev server proxies `/apis` to `localhost:8080`.

## Build

```sh
npm run build
npm run preview
```

## Pages

| Route | Description |
|---|---|
| `/` | API list with status badges, latency, last check time |
| `/:apiId` | Detail view — latency chart, result table, enable toggle, delete |
