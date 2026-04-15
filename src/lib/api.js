const BASE = '';

async function request(path, options = {}) {
  const res = await fetch(`${BASE}${path}`, {
    headers: { 'Content-Type': 'application/json' },
    ...options,
  });
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body.message || `HTTP ${res.status}`);
  }
  if (res.status === 204) return null;
  return res.json();
}

export const getApis = () => request('/apis');

export const registerApi = (body) =>
  request('/apis', { method: 'POST', body: JSON.stringify(body) });

export const getApi = (apiId) => request(`/apis/${apiId}`);

export const deleteApi = (apiId) => request(`/apis/${apiId}`, { method: 'DELETE' });

export const toggleEnabled = (apiId) =>
  request(`/apis/${apiId}/enabled`, { method: 'PATCH' });

export const getResults = (apiId, limit = 50) =>
  request(`/apis/${apiId}/results?limit=${limit}`);
