export default {
    async fetch(request, env) {
        const url = new URL(request.url);
        const GEMINI_API_KEY = env.GEMINI_API_KEY;

        if (!GEMINI_API_KEY) {
            return new Response("Missing API Key", { status: 500 });
        }

        const corsHeaders = {
            "Access-Control-Allow-Origin": "*",
        };

        const jsonResponse = (payload, status = 200) =>
            new Response(JSON.stringify(payload), {
                status,
                headers: {
                    ...corsHeaders,
                    "Content-Type": "application/json",
                },
            });

        const model = "gemini-2.5-flash";
        const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${GEMINI_API_KEY}`;

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
                const prompt = `Responda SEMPRE em português (pt-BR) e use nomes comuns no Brasil (não use inglês).

Busque alimentos que correspondam a: "${query}".
Retorne uma LISTA JSON com no mínimo 5 itens. Cada item deve ter: name, calories (integer), protein (number), carbs (number), fat (number), servingSize (string, ex: "100g"), servingUnit (string, ex: "g").
                Example: [{"name": "Apple", "calories": 52, "protein": 0.3, "carbs": 14, "fat": 0.2, "servingSize": "1 medium", "servingUnit": "medium"}]
Retorne APENAS a lista JSON (sem texto extra, sem markdown).`;

                const response = await fetch(geminiUrl, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({
                        contents: [{ parts: [{ text: prompt }] }]
                    }),
                });

                const data = await response.json();
                if (!response.ok) {
                    console.error("Gemini search error", response.status, data);
                    return jsonResponse({ error: "Gemini API error", status: response.status, details: data }, 502);
                }
                let text = data.candidates?.[0]?.content?.parts?.[0]?.text;

                if (!text) {
                    console.error("Gemini search missing text", data);
                    return jsonResponse({ error: "Failed to generate content", details: data }, 502);
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
                console.error("Search worker error", e);
                return jsonResponse({ error: e?.message ?? String(e) }, 500);
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

                let mimeType = imageFile.type;
                if (!mimeType || mimeType === "application/octet-stream") {
                    mimeType = "image/jpeg";
                }

                const requestBody = {
                    contents: [
                        {
                            parts: [
                                {
                                    text: 'Responda SEMPRE em português (pt-BR) e use o nome mais comum no Brasil (não use inglês).\n\nIdentifique o alimento desta imagem e estime calorias e macros (proteína, carboidratos, gordura) para uma porção padrão.\nRetorne APENAS JSON válido no formato: { "name": "Nome do alimento", "calories": 100, "protein": 10, "carbs": 20, "fat": 5, "servingSize": "100g", "servingUnit": "g" }',
                                },
                                {
                                    inlineData: { mimeType, data: base64Image },
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
                if (!geminiResponse.ok) {
                    console.error("Gemini analyze error", geminiResponse.status, data);
                    return jsonResponse({ error: "Gemini API error", status: geminiResponse.status, details: data }, 502);
                }
                let text = data.candidates?.[0]?.content?.parts?.[0]?.text;

                if (!text) {
                    console.error("Gemini analyze missing text", data);
                    return jsonResponse({ error: "Failed to generate content", details: data }, 502);
                }

                text = text.replace(/```json/g, "").replace(/```/g, "").trim();

                return new Response(text, {
                    headers: {
                        "Content-Type": "application/json",
                        "Access-Control-Allow-Origin": "*",
                    },
                });

            } catch (error) {
                console.error("Analyze worker error", error);
                return jsonResponse({ error: error?.message ?? String(error) }, 500);
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
