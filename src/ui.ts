export class Ui {
    private ui: any = {};
    private handlers: any;

    constructor(handlers) {
        this.handlers = handlers;
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
        return this.ui;
    }

    bindEvents() {
        this.ui.splashForm.addEventListener('submit', (e) => this.handlers.handleSplashSubmit(e));
        this.ui.generationForm.addEventListener('submit', (e) => this.handlers.handleGenerationSubmit(e));
        this.ui.chatForm.addEventListener('submit', (e) => this.handlers.handleChatSubmit(e));
        this.ui.clearBtn.addEventListener('click', () => {
            this.ui.generationForm.reset();
            this.updateSummary(); // Also reset summary
        });

        ['model', 'style', 'steps', 'cfg-scale', 'variants'].forEach(id => {
            const camelCaseId = id.replace(/-(\w)/g, (_, c) => c.toUpperCase());
            this.ui[camelCaseId]?.addEventListener('change', () => this.updateSummary());
        });
        this.ui.aspectRatioGroup.addEventListener('change', () => this.updateSummary());

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
        }, 5000); // hardcoded duration for now
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

    showSplashScreen() {
        this.ui.splashScreen.classList.remove('hidden');
    }

    hideSplashScreen() {
        this.ui.splashScreen.classList.add('fade-out');
        this.ui.splashScreen.addEventListener('animationend', () => {
            this.ui.splashScreen.classList.add('hidden');
        }, { once: true });
    }
}
