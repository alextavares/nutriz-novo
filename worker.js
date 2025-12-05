
export default {
    async fetch(request, env) {
        // Handle CORS
        if (request.method === "OPTIONS") {
            return new Response(null, {
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
                    "Access-Control-Allow-Headers": "Content-Type",
                },
            });
        }

        const url = new URL(request.url);
        const path = url.pathname;

        try {
            if (path === "/search-food" && request.method === "GET") {
                const query = url.searchParams.get("q");
                if (!query) return new Response("Missing query", { status: 400 });
                return await searchFoodWithGemini(query, env.GEMINI_API_KEY);
            }

            if (path === "/analyze-food" && request.method === "POST") {
                const { image } = await request.json(); // Expecting base64 image
                if (!image) return new Response("Missing image", { status: 400 });
                return await analyzeImageWithGemini(image, env.GEMINI_API_KEY);
            }

            if (path === "/list-models" && request.method === "GET") {
                const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models?key=${env.GEMINI_API_KEY}`);
                const data = await response.json();
                return new Response(JSON.stringify(data), {
                    headers: { "Content-Type": "application/json" }
                });
            }

            return new Response("Not Found", { status: 404 });

        } catch (e) {
            return new Response(JSON.stringify({ error: e.message }), {
                status: 500,
                headers: {
                    "Content-Type": "application/json",
                    "Access-Control-Allow-Origin": "*"
                },
            });
        }
    },
};

async function searchFoodWithGemini(query, apiKey) {
    const prompt = `
    Search for food items matching "${query}". 
    Return a JSON list of 5 items. 
    Format: [{"name": "Food Name", "calories": 100, "protein": 10, "carbs": 20, "fat": 5, "servingSize": "100g"}]
    Only return the JSON.
  `;
    return callGemini(prompt, apiKey);
}

async function analyzeImageWithGemini(base64Image, apiKey) {
    const prompt = `
    Identify the food in this image. Estimate the portion size.
    Return a JSON object.
    Format: {"name": "Food Name", "calories": 100, "protein": 10, "carbs": 20, "fat": 5, "servingSize": "100g"}
    Only return the JSON.
  `;

    const payload = {
        contents: [{
            parts: [
                { text: prompt },
                { inline_data: { mime_type: "image/jpeg", data: base64Image } }
            ]
        }]
    };

    return callGeminiPayload(payload, apiKey);
}

async function callGemini(textPrompt, apiKey) {
    const payload = {
        contents: [{
            parts: [{ text: textPrompt }]
        }]
    };
    return callGeminiPayload(payload, apiKey);
}

async function callGeminiPayload(payload, apiKey) {
    const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${apiKey}`;

    const response = await fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
    });

    const data = await response.json();

    if (!data.candidates || !data.candidates[0]) {
        return new Response(JSON.stringify({ error: "Gemini API Error", details: data }), {
            status: 500,
            headers: { "Content-Type": "application/json" }
        });
    }

    const text = data.candidates[0].content.parts[0].text;

    // Extract JSON from markdown code block if present
    const jsonMatch = text.match(/```json\n([\s\S]*?)\n```/) || text.match(/```\n([\s\S]*?)\n```/);
    const jsonStr = jsonMatch ? jsonMatch[1] : text;

    return new Response(jsonStr, {
        headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
    });
}
