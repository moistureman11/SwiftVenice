export class Api {
    private config: any;
    private state: any;

    constructor(config, state) {
        this.config = config;
        this.state = state;
    }

    normalizeModelList(resp) {
        if (!resp) return [];
        if (Array.isArray(resp)) return resp;
        if (resp.data && Array.isArray(resp.data)) return resp.data;
        if (resp.models && Array.isArray(resp.models)) return resp.models;
        return [];
    }

    async fetchAPI(endpoint, options = {}) {
        const url = `${this.config.API_BASE_URL}${endpoint}`;
        const apiKey = this.config.API_KEYS.venice[this.state.veniceApiKeyIndex];

        const headers = {
            'Authorization': `Bearer ${apiKey}`,
            ...options['headers'],
        };

        const finalOptions = { ...options, headers };

        if (finalOptions['body']) {
            finalOptions.headers['Content-Type'] = 'application/json';
        }

        const response = await fetch(url, finalOptions);

        if (!response.ok) {
            if ((response.status === 401 || response.status === 403) && this.state.veniceApiKeyIndex < this.config.API_KEYS.venice.length - 1) {
                this.state.veniceApiKeyIndex++;
                console.warn(`API Key failed. Rotating to index ${this.state.veniceApiKeyIndex}. Retrying...`);
                return this.fetchAPI(endpoint, options);
            }
            const errorData = await response.json().catch(() => ({ message: response.statusText }));
            throw new Error(errorData.message || `HTTP error! status: ${response.status}`);
        }

        return response.json();
    }
}
