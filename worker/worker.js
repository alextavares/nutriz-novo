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

        const GEMINI_MODEL = "gemini-2.0-flash";
        const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${GEMINI_API_KEY}`;

        // Handle CORS preflight
        if (request.method === "OPTIONS") {
            return new Response(null, {
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
                    "Access-Control-Allow-Headers": "Content-Type",
                },
            });
        }

        // ─────────────────────────────────────────────────────────────────────
        // Endpoint: POST /coach-chat
        // ─────────────────────────────────────────────────────────────────────
        if (request.method === "POST" && url.pathname === "/coach-chat") {
            try {
                const body = await request.json();
                const { message, profile, dailyContext, history = [] } = body;

                if (!message || typeof message !== "string") {
                    return jsonResponse({ error: "Missing 'message' field" }, 400);
                }

                // ── Build system instruction ──────────────────────────────
                let profileBlock = "";
                if (profile) {
                    profileBlock = `
Perfil do usuário:
- Sexo: ${profile.gender ?? "não informado"}
- Idade: ${profile.age ?? "não informada"} anos
- Altura: ${profile.height_cm ?? "?"}cm | Peso atual: ${profile.current_weight_kg ?? "?"}kg | Peso meta: ${profile.target_weight_kg ?? "?"}kg
- Meta calórica diária: ${profile.calorie_target ?? "?"}kcal
- Macros diários: Proteína ${profile.protein_g ?? "?"}g | Carbs ${profile.carbs_g ?? "?"}g | Gordura ${profile.fat_g ?? "?"}g
- Objetivo principal: ${profile.main_goal ?? "não informado"}
- Preferência alimentar: ${profile.dietary_preference ?? "não informada"}`;
                }

                let diaryBlock = "";
                if (dailyContext && !dailyContext.isEmpty) {
                    const remaining = (dailyContext.calorieGoal ?? 0) - (dailyContext.totalCalories ?? 0);
                    diaryBlock = `
Diário de hoje:
- Calorias consumidas: ${dailyContext.totalCalories}kcal de ${dailyContext.calorieGoal}kcal (${remaining >= 0 ? remaining + "kcal restantes" : Math.abs(remaining) + "kcal acima da meta"})
- Proteína: ${dailyContext.proteinGrams}g | Carbs: ${dailyContext.carbsGrams}g | Gordura: ${dailyContext.fatGrams}g
- Refeições registradas: ${[
                            dailyContext.hasBreakfast && "café da manhã",
                            dailyContext.hasLunch && "almoço",
                            dailyContext.hasDinner && "jantar",
                            dailyContext.hasSnacks && "lanches",
                        ].filter(Boolean).join(", ") || "nenhuma"}
- Alimentos registrados: ${dailyContext.foodsLogged?.length > 0 ? dailyContext.foodsLogged.slice(0, 10).join(", ") : "nenhum"}
- Água: ${dailyContext.waterMl ?? 0}ml`;
                } else if (dailyContext && dailyContext.isEmpty) {
                    diaryBlock = `\nDiário de hoje: nenhum alimento registrado ainda.`;
                }

                const systemInstruction = `Você é o Coach Nutriz, assistente nutricional do app Nutriz (Brasil).

Regras obrigatórias:
- Responda SEMPRE em português brasileiro, de forma direta, empática e motivadora.
- Use linguagem simples e acessível.
- Respostas curtas: no máximo 4 parágrafos ou uma lista com até 6 itens.
- Não invente valores calóricos ou nutricionais exatos — diga "aproximadamente" quando estimar.
- Quando o tema envolver saúde clínica (diabetes, hipertensão, distúrbios alimentares), inclua: "Consulte um profissional de saúde para orientação personalizada."
- Não responda perguntas fora do contexto de nutrição, alimentação, suplementação, hábitos saudáveis ou jejum intermitente.
- Formate respostas com markdown simples quando útil (negrito, listas com hífen).

Formato da resposta — retorne APENAS JSON válido:
{
  "reply": "sua resposta em markdown",
  "quickReplies": ["sugestão 1", "sugestão 2", "sugestão 3"]
}

As quickReplies devem ser perguntas curtas e relevantes que o usuário provavelmente vai querer perguntar em seguida, baseadas na resposta dada.
${profileBlock}${diaryBlock}`;

                // ── Build multi-turn conversation (history) ───────────────
                const contents = [];

                // Add conversation history as alternating user/model turns
                for (const turn of history) {
                    const role = turn.role === "assistant" ? "model" : "user";
                    contents.push({
                        role,
                        parts: [{ text: turn.text }],
                    });
                }

                // Add the current user message
                contents.push({
                    role: "user",
                    parts: [{ text: message }],
                });

                // ── Call Gemini ───────────────────────────────────────────
                const geminiResp = await fetch(geminiUrl, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({
                        system_instruction: {
                            parts: [{ text: systemInstruction }],
                        },
                        contents,
                        generationConfig: {
                            temperature: 0.7,
                            topP: 0.9,
                            maxOutputTokens: 600,
                        },
                    }),
                });

                const data = await geminiResp.json();

                if (!geminiResp.ok) {
                    console.error("Gemini coach error", geminiResp.status, JSON.stringify(data));
                    return jsonResponse({ error: "Gemini API error", status: geminiResp.status }, 502);
                }

                let text = data.candidates?.[0]?.content?.parts?.[0]?.text ?? "";
                text = text.replace(/```json/g, "").replace(/```/g, "").trim();

                if (!text) {
                    console.error("Gemini coach: empty response", JSON.stringify(data));
                    return jsonResponse({ error: "Empty response from AI" }, 502);
                }

                // ── Parse and validate JSON ───────────────────────────────
                let parsed;
                try {
                    parsed = JSON.parse(text);
                } catch {
                    // If Gemini didn't honour JSON format, wrap the plain text
                    parsed = {
                        reply: text,
                        quickReplies: [],
                    };
                }

                const reply = typeof parsed.reply === "string" ? parsed.reply.trim() : text;
                const quickReplies = Array.isArray(parsed.quickReplies)
                    ? parsed.quickReplies.filter((s) => typeof s === "string" && s.trim()).slice(0, 4)
                    : [];

                return jsonResponse({ reply, quickReplies });

            } catch (e) {
                console.error("Coach chat worker error", e);
                return jsonResponse({ error: e?.message ?? String(e) }, 500);
            }
        }

        // ─────────────────────────────────────────────────────────────────────
        // Endpoint: GET /proxy-off
        // ─────────────────────────────────────────────────────────────────────
        if (request.method === "GET" && url.pathname === "/proxy-off") {
            const query = url.searchParams.get("q");
            if (!query) {
                return new Response("Missing query parameter 'q'", { status: 400, headers: corsHeaders });
            }
            try {
                const offUrl = `https://world.openfoodfacts.org/api/v2/search?search_terms=${encodeURIComponent(query)}&fields=code,product_name,nutriments,brands,image_small_url&page_size=24`;
                const offResponse = await fetch(offUrl, {
                    headers: {
                        "User-Agent": "NutrizApp - Android/iOS - Version 1.0 - https://nutriz.app"
                    }
                });

                const data = await offResponse.json();
                return jsonResponse(data);
            } catch (e) {
                return jsonResponse({ error: e.message }, 500);
            }
        }

        // ─────────────────────────────────────────────────────────────────────
        // Endpoint: GET /search-food (Hybrid: D1 TACO + Gemini Fallback)
        // ─────────────────────────────────────────────────────────────────────
        if (request.method === "GET" && url.pathname === "/search-food") {
            const query = url.searchParams.get("q");
            if (!query) {
                return new Response("Missing query parameter 'q'", { status: 400 });
            }

            let finalResults = [];

            // 1. Try D1 (TACO Database)
            if (env.DB) {
                try {
                    const { results } = await env.DB.prepare(
                        "SELECT * FROM foods WHERE name LIKE ? LIMIT 15"
                    ).bind(`%${query}%`).all();

                    if (results && results.length > 0) {
                        finalResults = results.map(f => ({
                            id: f.id,
                            name: f.name,
                            brand: f.brand,
                            calories: f.calories,
                            protein: f.protein,
                            carbs: f.carbs,
                            fat: f.fat,
                            servingSize: f.servingSize,
                            servingUnit: f.servingSize.includes('g') ? 'g' : 'ml'
                        }));
                    }
                } catch (e) {
                    console.error("D1 search error", e);
                }
            }

            // 2. Fallback: Gemini AI if we don't have enough results
            if (finalResults.length < 3) {
                try {
                    const prompt = `Responda SEMPRE em português (pt-BR) e use nomes comuns no Brasil (não use inglês).
Busque alimentos que correspondam a: "${query}".
Retorne uma LISTA JSON com no máximo 5 itens (diferentes dos que já temos). Cada item deve ter: name, calories (integer), protein (number), carbs (number), fat (number), servingSize (string, ex: "100g"), servingUnit (string).
Retorne APENAS a lista JSON (sem texto extra, sem markdown).`;

                    const response = await fetch(geminiUrl, {
                        method: "POST",
                        headers: { "Content-Type": "application/json" },
                        body: JSON.stringify({
                            contents: [{ parts: [{ text: prompt }] }]
                        }),
                    });

                    if (response.ok) {
                        const data = await response.json();
                        let aiText = data.candidates?.[0]?.content?.parts?.[0]?.text || "[]";
                        aiText = aiText.replace(/```json/g, "").replace(/```/g, "").trim();
                        try {
                            const aiList = JSON.parse(aiText);
                            if (Array.isArray(aiList)) {
                                finalResults = [...finalResults, ...aiList];
                            }
                        } catch (e) { /* ignore parse error */ }
                    }
                } catch (e) {
                    console.error("AI fallback error", e);
                }
            }

            return jsonResponse(finalResults);
        }

        // ─────────────────────────────────────────────────────────────────────
        // Endpoint: POST /analyze-food
        // ─────────────────────────────────────────────────────────────────────
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

        // ─────────────────────────────────────────────────────────────────────
        // Debug: GET / — list models
        // ─────────────────────────────────────────────────────────────────────
        if (request.method === "GET") {
            const modelsUrl = `https://generativelanguage.googleapis.com/v1beta/models?key=${GEMINI_API_KEY}`;
            const response = await fetch(modelsUrl);
            return response;
        }

        return new Response("Not Found", { status: 404 });
    },
};
