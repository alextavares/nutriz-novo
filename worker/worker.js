export default {
    async fetch(request, env) {
        const url = new URL(request.url);
        const GEMINI_API_KEY = env.GEMINI_API_KEY;

        if (!GEMINI_API_KEY) {
            return new Response("Missing API Key", { status: 500 });
        }

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

        // Endpoint: /search-food (GET)
        if (request.method === "GET" && url.pathname === "/search-food") {
            const query = url.searchParams.get("q");
            if (!query) {
                return new Response("Missing query parameter 'q'", { status: 400 });
            }

            try {
                const model = "gemini-2.0-flash";
                const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${GEMINI_API_KEY}`;

                const prompt = `Search for food items matching "${query}". Return a JSON LIST of at least 5 items. Each item must have: name, calories (integer), protein (number), carbs (number), fat (number), servingSize (string, e.g. "100g"), servingUnit (string, e.g. "g").
                Example: [{"name": "Apple", "calories": 52, "protein": 0.3, "carbs": 14, "fat": 0.2, "servingSize": "1 medium", "servingUnit": "medium"}]
                Return ONLY the JSON list.`;

                const response = await fetch(geminiUrl, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({
                        contents: [{ parts: [{ text: prompt }] }]
                    }),
                });

                const data = await response.json();
                let text = data.candidates?.[0]?.content?.parts?.[0]?.text;

                if (!text) {
                    return new Response("Failed to generate content", { status: 500 });
                }

                // Clean up markdown code blocks if present
                text = text.replace(/```json/g, "").replace(/```/g, "").trim();

                return new Response(text, {
                    headers: {
                        "Content-Type": "application/json",
                        "Access-Control-Allow-Origin": "*",
                    },
                });
            } catch (e) {
                return new Response(`Error: ${e.message}`, { status: 500 });
            }
        }

        // Endpoint: /analyze-food (POST)
        if (request.method === "POST" && url.pathname === "/analyze-food") {
            try {
                const formData = await request.formData();
                const imageFile = formData.get("image");

                if (!imageFile) {
                    return new Response("No image file provided", { status: 400 });
                }

                const arrayBuffer = await imageFile.arrayBuffer();
                const base64Image = btoa(
                    new Uint8Array(arrayBuffer).reduce(
                        (data, byte) => data + String.fromCharCode(byte),
                        ""
                    )
                );

                const model = "gemini-2.0-flash";
                const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${GEMINI_API_KEY}`;

                let mimeType = imageFile.type;
                if (!mimeType || mimeType === "application/octet-stream") {
                    mimeType = "image/jpeg";
                }

                const requestBody = {
                    contents: [
                        {
                            parts: [
                                {
                                    text: 'Identify this food and estimate its calories and macros (protein, carbs, fat) for a standard serving. Return ONLY valid JSON in this format: { "name": "Food Name", "calories": 100, "protein": 10, "carbs": 20, "fat": 5, "servingSize": "100g", "servingUnit": "g" }',
                                },
                                {
                                    inline_data: {
                                        mime_type: mimeType,
                                        data: base64Image,
                                    },
                                },
                            ],
                        },
                    ],
                };

                const geminiResponse = await fetch(geminiUrl, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify(requestBody),
                });

                const data = await geminiResponse.json();
                let text = data.candidates?.[0]?.content?.parts?.[0]?.text;

                if (!text) {
                    return new Response("Failed to generate content", { status: 500 });
                }

                text = text.replace(/```json/g, "").replace(/```/g, "").trim();

                return new Response(text, {
                    headers: {
                        "Content-Type": "application/json",
                        "Access-Control-Allow-Origin": "*",
                    },
                });

            } catch (error) {
                return new Response(`Worker Error: ${error.message}`, { status: 500 });
            }
        }

        // Default: List models (debug)
        if (request.method === "GET") {
            const url = `https://generativelanguage.googleapis.com/v1beta/models?key=${GEMINI_API_KEY}`;
            const response = await fetch(url);
            return response;
        }

        return new Response("Not Found", { status: 404 });
    },
};
