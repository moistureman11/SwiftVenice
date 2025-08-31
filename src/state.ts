export const initialState = {
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
