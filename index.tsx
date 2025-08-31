

class VeniceImageStudio {
    config: any;
    state: any;
    ui: any;

    constructor() {
        this.config = {
            API_BASE_URL: "https://api.venice.ai/api/v1",
            IMAGE_STORAGE_KEY: 'venice_image_history',
            CHAT_STORAGE_KEY: 'venice_chat_history',
            PROMPT_TEMPLATES_KEY: 'venice_prompt_templates',
            API_KEYS_STORAGE_KEY: 'venice_api_keys', // New
            ACTIVE_API_KEY_ID_KEY: 'venice_active_api_key_id', // New
            USERNAME_KEY: 'venice_username', // New
            CHAT_MODEL_STORAGE_KEY: 'venice_chat_model',
            SYSTEM_PROMPT_STORAGE_KEY: 'venice_system_prompt',
            FAVORITE_IMAGES_KEY: 'venice_favorite_images',
            MAX_FIRESTORE_PAYLOAD_SIZE: 1048487,
            NEGATIVE_PROMPT_PRESETS: {
                none: "",
                sfw: "ugly, deformed, noisy, blurry, distorted, grainy, low quality, jpeg artifacts, signature, watermark, text, username",
                human: "deformed, disfigured, ugly, bad anatomy, extra limbs, missing limbs, fused fingers, too many fingers, long neck, mutated hands, poorly drawn hands, poorly drawn face, blurry",
                animal: "deformed, disfigured, ugly, bad anatomy, extra limbs, missing limbs, mutated, poorly drawn",
                nsfw: "nsfw, nude, naked, sexually explicit, porn, xxx, explicit content, sexual, erotic, lewd, obscene, suggestive"
            },
            COMPRESSION_QUALITY: 0.85,
            TOAST_DURATION: 5000,
            CHAT_CONTEXT_LIMIT: 100,
            FORBIDDEN_KEYWORDS: [
                "cp", "csam", "child porn", "child pornography", "child abuse", "rape", "nonconsensual",
                "incest", "forced", "molest", "abuse", "exploit", "loli", "lolita", "shota", "pedo",
                "pedophile", "prepubescent", "kiddy", "kid sex", "sexy kid", "kid pussy", "kid dick",
                "sexy boy", "sexy girl", "kiddy porn", "toddler", "infant", "underage sex", "minor porn",
                "baby", "newborn", "youth exploit", "preteen porn", "juvenile abuse", "schoolgirl", "schoolboy", "training bra"
            ],
            API_KEYS: {
                venice: [
                    "ctALAad7pRX1N7WGmWhOS8kAyAJAxXgH1XnJFahlR4",
                    "GigfpMSQdlDtk-mNgnu2QrYgDEj4RopT2Fy6k0JcBS",
                    "h234fqKxJjgZM25s0McliSCqNTi_STH28Ah1qoqHxM",
                    "uWLZy3X7HNz4BJUAjo8ULnAQUjSzD-SizYP9I77UVN"
                ]
            }
        };

        this.state = {
            isGenerating: false,
            isChatting: false,
            isSummarizing: false,
            username: '',
            apiKeys: [],
            activeApiKeyId: null,
            imageHistory: [],
            chatHistory: [],
            promptTemplates: [],
            veniceApiKeyIndex: 0,
            isSelectionMode: false,
            selectedImageIds: new Set(),
            favoritedImageIds: new Set(),
            current: null
        };
        
        this.ui = {};
    }

    async init() {
        console.log("Initializing Venice AI Studio...");
        this.initUI();
        this.bindEvents();
        this.loadState();

        if (!this.state.username) {
            this.showSplashScreen();
        } else {
            this.startApp();
        }
    }
    
    initUI() {
        const ids = [
            'splash-screen', 'splash-form', 'username-input', 'main-app', 'studio-title',
            'image-count', 'storage-used', 'model', 'style', 'chat-model', 'system-prompt',
            'generation-form', 'prompt', 'negative-prompt', 'generate-btn', 'clear-btn',
            'gallery-grid', 'empty-state', 'loading-state',
            'chat-container', 'chat-form', 'chat-input', 'chat-send-btn', 'summarize-btn',
            'summary-container', 'summary-content',
            'summary-model', 'summary-style', 'summary-aspect', 'summary-steps', 'summary-cfg', 'summary-variants',
            'cfg-scale', 'cfg-scale-value', 'steps', 'steps-value', 'variants', 'variants-value',
            'seed', 'random-seed-btn',
            'toast-container'
        ];
        
        const toCamelCase = s => s.replace(/([-_][a-z])/ig, ($1) => $1.toUpperCase().replace('-', ''));
        
        ids.forEach(id => {
            const element = document.getElementById(id);
            if (element) {
                this.ui[toCamelCase(id)] = element;
            } else {
                console.warn(`UI element with ID "${id}" not found.`);
            }
        });
        
        this.ui.aspectRatioGroup = document.getElementById('aspect-ratio-group');
    }

    bindEvents() {
        this.ui.splashForm.addEventListener('submit', (e) => this.handleSplashSubmit(e));
        this.ui.generationForm.addEventListener('submit', (e) => this.handleGenerationSubmit(e));
        this.ui.chatForm.addEventListener('submit', (e) => this.handleChatSubmit(e));
        this.ui.clearBtn.addEventListener('click', () => {
            this.ui.generationForm.reset();
            this.updateSummary(); // Also reset summary
        });
        
        // Summary listeners
        ['model', 'style', 'steps', 'cfg-scale', 'variants'].forEach(id => {
            const camelCaseId = id.replace(/-(\w)/g, (_, c) => c.toUpperCase());
            this.ui[camelCaseId]?.addEventListener('change', () => this.updateSummary());
        });
        this.ui.aspectRatioGroup.addEventListener('change', () => this.updateSummary());
        
        // Range slider value displays
        ['cfg-scale', 'steps', 'variants'].forEach(id => {
            const camelCaseId = id.replace(/-(\w)/g, (_, c) => c.toUpperCase());
            const input = this.ui[camelCaseId];
            const valueDisplay = this.ui[`${camelCaseId}Value`];
            if (input && valueDisplay) {
                input.addEventListener('input', () => {
                    valueDisplay.textContent = input.value;
                    this.updateSummary();
                });
            }
        });
        
        this.ui.randomSeedBtn.addEventListener('click', () => {
            this.ui.seed.value = String(Math.floor(Math.random() * 2**32));
        });
    }

    handleSplashSubmit(e) {
        e.preventDefault();
        const username = this.ui.usernameInput.value.trim();
        if (username) {
            this.state.username = username;
            localStorage.setItem(this.config.USERNAME_KEY, username);
            this.startApp();
        }
    }

    async startApp() {
        this.ui.studioTitle.textContent = `${this.state.username}'s AI Studio`;
        this.hideSplashScreen();
        this.ui.mainApp.classList.remove('hidden');
        this.ui.mainApp.classList.add('fade-in');
        
        this.updateStats();

        try {
            await this.loadInitialData();
            this.updateSummary(); // Update summary with loaded model defaults
        } catch (error) {
            console.error("Initialization failed:", error);
            // Error toast is shown inside loadInitialData
        }
    }

    showSplashScreen() {
        this.ui.splashScreen.classList.remove('hidden');
    }

    hideSplashScreen() {
        this.ui.splashScreen.classList.add('fade-out');
        this.ui.splashScreen.addEventListener('animationend', () => {
            this.ui.splashScreen.classList.add('hidden');
        }, { once: true });
    }
    
    loadState() {
        this.state.username = localStorage.getItem(this.config.USERNAME_KEY) || '';
        // In a real app, you would load image history, chat history, etc. here
    }

    async loadInitialData() {
        this.showToast('Loading initial data...', 'info');
        this.ui.generateBtn.disabled = true;
        
        try {
            const allModelsRes = await this.fetchAPI('/models');

            if (allModelsRes && allModelsRes.data) {
                const imageModels = allModelsRes.data.filter(m => m.pipeline === 'text-to-image');
                const chatModels = allModelsRes.data.filter(m => m.pipeline === 'chat');

                if (imageModels.length > 0) {
                    this.populateSelect(this.ui.model, imageModels, 'id', 'name');
                    this.ui.model.disabled = false;
                    
                    const firstModel = imageModels[0];
                    if (firstModel && firstModel.styles) {
                        this.populateSelect(this.ui.style, firstModel.styles, 'id', 'name');
                    }
                    this.ui.style.disabled = false;
                } else {
                     this.showToast('Failed to load image models.', 'error');
                }

                if (chatModels.length > 0) {
                    this.populateSelect(this.ui.chatModel, chatModels, 'id', 'name');
                    this.ui.chatModel.disabled = false;
                } else {
                    this.showToast('Failed to load chat models.', 'error');
                }
                
                this.showToast('Studio is ready!', 'success');
            } else {
                 throw new Error("Could not fetch necessary model data.");
            }
        } catch (error) {
            console.error("Failed to load initial data:", error);
            this.showToast(`Failed to load initial data: ${error.message}`, 'error');
            throw error;
        } finally {
             this.ui.generateBtn.disabled = false;
        }
    }
    
    async fetchAPI(endpoint, options = {}) {
        const url = `${this.config.API_BASE_URL}${endpoint}`;
        const apiKey = this.config.API_KEYS.venice[this.state.veniceApiKeyIndex];
    
        const headers = {
            'Authorization': `Bearer ${apiKey}`,
            ...options['headers'],
        };
    
        const finalOptions = { ...options, headers };
    
        // Only add Content-Type if there's a body.
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
    
    populateSelect(selectElement, data, valueKey, textKey) {
        if (!selectElement || !Array.isArray(data)) return;
        selectElement.innerHTML = '';
        if (data.length === 0) {
            selectElement.innerHTML = '<option>No options</option>';
            selectElement.disabled = true;
            return;
        }
        data.forEach(item => {
            const option = document.createElement('option');
            option.value = item[valueKey];
            option.textContent = item[textKey];
            selectElement.appendChild(option);
        });
    }

    updateSummary() {
        this.ui.summaryModel.textContent = this.ui.model.selectedOptions[0]?.textContent || 'N/A';
        this.ui.summaryStyle.textContent = this.ui.style.selectedOptions[0]?.textContent || 'None';
        const checkedAspect = document.querySelector('input[name="aspect"]:checked');
        this.ui.summaryAspect.textContent = checkedAspect ? checkedAspect.value : 'N/A';
        this.ui.summarySteps.textContent = this.ui.steps.value;
        this.ui.summaryCfg.textContent = this.ui.cfgScale.value;
        this.ui.summaryVariants.textContent = this.ui.variants.value;
    }
    
    updateStats() {
        this.ui.imageCount.textContent = this.state.imageHistory.length;
        const storageSize = (JSON.stringify(localStorage).length / 1024 / 1024).toFixed(2);
        this.ui.storageUsed.textContent = `${storageSize} MB`;
    }

    async handleGenerationSubmit(e) {
        e.preventDefault();
        this.showToast('Image generation is not implemented yet.', 'info');
        console.log('Generation form submitted with:', {
            prompt: this.ui.prompt.value,
            model: this.ui.model.value,
        });
    }

    async handleChatSubmit(e) {
        e.preventDefault();
        const input = this.ui.chatInput.value.trim();
        if (!input) return;
        this.showToast('Chat is not implemented yet.', 'info');
        console.log('Chat form submitted with:', input);
        this.ui.chatInput.value = '';
    }

    showToast(message, type = 'info') {
        const toast = document.createElement('div');
        toast.className = 'toast p-4 rounded-lg shadow-lg text-white font-semibold max-w-sm w-full text-center';
        
        const colors = {
            info: 'bg-blue-600/80 backdrop-blur',
            success: 'bg-green-600/80 backdrop-blur',
            error: 'bg-red-600/80 backdrop-blur',
            warning: 'bg-yellow-600/80 backdrop-blur'
        };
        toast.classList.add(...(colors[type] || colors.info).split(' '));
        toast.textContent = message;
        
        this.ui.toastContainer.appendChild(toast);
        
        setTimeout(() => {
            toast.style.opacity = '0';
            toast.addEventListener('transitionend', () => toast.remove());
        }, this.config.TOAST_DURATION);
    }
}

// App Entry Point
document.addEventListener('DOMContentLoaded', () => {
    const app = new VeniceImageStudio();
    app.init();
});