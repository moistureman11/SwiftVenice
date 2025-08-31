import { config } from './src/config';
import { initialState } from './src/state';
import { Api } from './src/api';
import { Ui } from './src/ui';

class VeniceImageStudio {
    config: any;
    state: any;
    api: Api;
    ui: Ui;
    uiElements: any;

    constructor() {
        this.config = config;
        this.state = initialState;

        const handlers = {
            handleSplashSubmit: (e) => this.handleSplashSubmit(e),
            handleGenerationSubmit: (e) => this.handleGenerationSubmit(e),
            handleChatSubmit: (e) => this.handleChatSubmit(e),
        };

        this.api = new Api(this.config, this.state);
        this.ui = new Ui(handlers);
    }

    async init() {
        console.log("Initializing Venice AI Studio...");
        this.uiElements = this.ui.initUI();
        this.ui.bindEvents();
        this.loadState();

        if (!this.state.username) {
            this.ui.showSplashScreen();
        } else {
            this.startApp();
        }
    }
    
    loadState() {
        this.state.username = localStorage.getItem(this.config.USERNAME_KEY) || '';
        // In a real app, you would load image history, chat history, etc. here
    }

    async startApp() {
        this.uiElements.studioTitle.textContent = `${this.state.username}'s AI Studio`;
        this.ui.hideSplashScreen();
        this.uiElements.mainApp.classList.remove('hidden');
        this.uiElements.mainApp.classList.add('fade-in');
        
        this.updateStats();

        try {
            await this.loadInitialData();
            this.ui.updateSummary(); // Update summary with loaded model defaults
        } catch (error) {
            console.error("Initialization failed:", error);
            // Error toast is shown inside loadInitialData
        }
    }

    async loadInitialData() {
        this.ui.showToast('Loading initial data...', 'info');
        this.uiElements.generateBtn.disabled = true;
        
        try {
            const allModelsRes = await this.api.fetchAPI('/models');
            const models = this.api.normalizeModelList(allModelsRes);

            if (models.length > 0) {
                const imageModels = models.filter(m => m.pipeline === 'text-to-image');
                const chatModels = models.filter(m => m.pipeline === 'chat');

                if (imageModels.length > 0) {
                    this.ui.populateSelect(this.uiElements.model, imageModels, 'id', 'name');
                    this.uiElements.model.disabled = false;
                    
                    const firstModel = imageModels[0];
                    if (firstModel && firstModel.styles) {
                        this.ui.populateSelect(this.uiElements.style, firstModel.styles, 'id', 'name');
                    }
                    this.uiElements.style.disabled = false;
                } else {
                     this.ui.showToast('Failed to load image models.', 'error');
                }

                if (chatModels.length > 0) {
                    this.ui.populateSelect(this.uiElements.chatModel, chatModels, 'id', 'name');
                    this.uiElements.chatModel.disabled = false;
                } else {
                    this.ui.showToast('Failed to load chat models.', 'error');
                }
                
                this.ui.showToast('Studio is ready!', 'success');
            } else {
                 throw new Error("Could not fetch necessary model data.");
            }
        } catch (error) {
            console.error("Failed to load initial data:", error);
            this.ui.showToast(`Failed to load initial data: ${error.message}`, 'error');
            throw error;
        } finally {
             this.uiElements.generateBtn.disabled = false;
        }
    }
    
    updateStats() {
        this.uiElements.imageCount.textContent = this.state.imageHistory.length;
        const storageSize = (JSON.stringify(localStorage).length / 1024 / 1024).toFixed(2);
        this.uiElements.storageUsed.textContent = `${storageSize} MB`;
    }

    handleSplashSubmit(e) {
        e.preventDefault();
        const username = this.uiElements.usernameInput.value.trim();
        if (username) {
            this.state.username = username;
            localStorage.setItem(this.config.USERNAME_KEY, username);
            this.startApp();
        }
    }

    async handleGenerationSubmit(e) {
        e.preventDefault();
        this.ui.showToast('Image generation is not implemented yet.', 'info');
        console.log('Generation form submitted with:', {
            prompt: this.uiElements.prompt.value,
            model: this.uiElements.model.value,
        });
    }

    async handleChatSubmit(e) {
        e.preventDefault();
        const input = this.uiElements.chatInput.value.trim();
        if (!input) return;
        this.ui.showToast('Chat is not implemented yet.', 'info');
        console.log('Chat form submitted with:', input);
        this.uiElements.chatInput.value = '';
    }
}

// App Entry Point
document.addEventListener('DOMContentLoaded', () => {
    const app = new VeniceImageStudio();
    app.init();
});