export const config = {
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
