
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
                // Accept both multipart/form-data (preferred) and legacy JSON {image: base64}
                const contentType = request.headers.get("content-type") || "";
                if (contentType.includes("multipart/form-data")) {
                    const form = await request.formData();
                    const imageFile = form.get("image");
                    if (!imageFile) return new Response("Missing image file", { status: 400 });
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
                    return await analyzeImageWithGemini(
                        base64Image,
                        env.GEMINI_API_KEY,
                        mimeType,
                    );
                } else {
                    const { image } = await request.json(); // legacy base64 image
                    if (!image) return new Response("Missing image", { status: 400 });
                    return await analyzeImageWithGemini(image, env.GEMINI_API_KEY, "image/jpeg");
                }
            }

            if (path === "/coach-chat" && request.method === "POST") {
                const { message, profile, dailyContext } = await request.json();
                if (!message) return new Response("Missing message", { status: 400 });
                return await coachChatWithGemini(message, profile, dailyContext, env.GEMINI_API_KEY);
            }

            if (path === "/diet-replace-day" && request.method === "POST") {
                const { day, profile, catalog, current, locked } = await request.json();
                if (!day) return new Response("Missing day", { status: 400 });
                if (!catalog || !Array.isArray(catalog) || catalog.length < 10) {
                    return new Response("Missing catalog", { status: 400 });
                }
                return await dietReplaceDayWithGemini(day, profile, catalog, current, locked, env.GEMINI_API_KEY);
            }

            if (path === "/diet-replace-meal" && request.method === "POST") {
                const { day, mealType, profile, catalog, current, weekUsedSameType, dayOtherMealIds, remaining, hints } = await request.json();
                if (!day) return new Response("Missing day", { status: 400 });
                if (!mealType) return new Response("Missing mealType", { status: 400 });
                if (!catalog || !Array.isArray(catalog) || catalog.length < 10) {
                    return new Response("Missing catalog", { status: 400 });
                }
                return await dietReplaceMealWithGemini(
                    day,
                    mealType,
                    profile,
                    catalog,
                    current,
                    weekUsedSameType,
                    dayOtherMealIds,
                    remaining,
                    hints,
                    env.GEMINI_API_KEY
                );
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
    Responda SEMPRE em português (pt-BR) e use nomes comuns no Brasil (não use inglês).

    Busque alimentos que correspondam a "${query}". 
    Retorne uma lista JSON com 5 itens. 
    Formato: [{"name": "Nome do alimento", "calories": 100, "protein": 10, "carbs": 20, "fat": 5, "servingSize": "100g"}]
    Retorne APENAS o JSON.
  `;
    return callGemini(prompt, apiKey);
}

async function analyzeImageWithGemini(base64Image, apiKey, mimeType = "image/jpeg") {
    const prompt = `
    Responda SEMPRE em português (pt-BR) e use o nome mais comum no Brasil (não use inglês).

    Identifique o alimento nesta imagem. Estime o tamanho da porção.
    Retorne um objeto JSON.
    Formato: {"name": "Nome do alimento", "calories": 100, "protein": 10, "carbs": 20, "fat": 5, "servingSize": "100g"}
    Retorne APENAS o JSON.
  `;

    const payload = {
        contents: [{
            parts: [
                { text: prompt },
                { inlineData: { mimeType, data: base64Image } }
            ]
        }]
    };

    return callGeminiPayload(payload, apiKey);
}

async function coachChatWithGemini(message, profile, dailyContext, apiKey) {
    const profileJson = profile ? JSON.stringify(profile) : "{}";

    // Build daily diary context section
    let diarySection = "";
    if (dailyContext) {
        if (dailyContext.isEmpty) {
            diarySection = `
DIÁRIO DE HOJE:
O usuário ainda não registrou nenhum alimento hoje.
Se a pergunta for sobre o que ele comeu, informe gentilmente que não há registros ainda e sugira adicionar alimentos.`;
        } else {
            const foods = Array.isArray(dailyContext.foodsLogged) ? dailyContext.foodsLogged.join(", ") : "nenhum";
            const mealsStatus = [
                dailyContext.hasBreakfast ? "café da manhã ✓" : "café da manhã ✗",
                dailyContext.hasLunch ? "almoço ✓" : "almoço ✗",
                dailyContext.hasDinner ? "jantar ✓" : "jantar ✗",
                dailyContext.hasSnacks ? "lanches ✓" : "lanches ✗",
            ].join(", ");
            diarySection = `
DIÁRIO DE HOJE:
- Alimentos registrados: ${foods}
- Refeições: ${mealsStatus}
- Calorias consumidas: ${dailyContext.totalCalories || 0} de ${dailyContext.calorieGoal || "?"} kcal
- Proteína: ${dailyContext.proteinGrams || 0}g | Carboidratos: ${dailyContext.carbsGrams || 0}g | Gordura: ${dailyContext.fatGrams || 0}g
- Água: ${dailyContext.waterMl || 0}ml

Use esses dados para responder de forma contextualizada sobre a alimentação do usuário.`;
        }
    } else {
        diarySection = `
DIÁRIO DE HOJE:
Dados do diário não disponíveis. Responda de forma genérica.`;
    }

    const prompt = `
Responda SEMPRE em português (pt-BR). Você é um assistente nutricional.

PERFIL DO USUÁRIO (pode estar incompleto): ${profileJson}
${diarySection}

Regras:
- Não faça diagnóstico médico. Se houver sinais/risco, recomende procurar um profissional.
- Seja direto e útil. Use listas quando ajudar.
- Não prometa resultados garantidos.
- Se o usuário perguntar sobre algo que não está no diário, informe que não há dados registrados.

Pergunta do usuário:
${message}

Retorne APENAS JSON válido no formato:
{
  "reply": "texto curto, claro e útil",
  "quickReplies": ["sugestão 1", "sugestão 2"]
}
Sem markdown, sem texto extra.
`;

    return callGemini(prompt, apiKey);
}

async function dietReplaceDayWithGemini(day, profile, catalog, current, locked, apiKey) {
    const profileJson = profile ? JSON.stringify(profile) : "{}";
    const currentJson = current ? JSON.stringify(current) : "{}";
    const lockedJson = Array.isArray(locked) ? JSON.stringify(locked) : "[]";

    // Keep catalog compact: id, mealType, title, kcal, protein_g, carbs_g, fat_g
    const compactCatalog = catalog.map((m) => ({
        id: m.id,
        mealType: m.mealType,
        title: m.title,
        kcal: m.kcal,
        protein_g: m.protein_g,
        carbs_g: m.carbs_g,
        fat_g: m.fat_g,
    }));
    const catalogJson = JSON.stringify(compactCatalog);

    const prompt = `
Responda SEMPRE em português (pt-BR). Você é um assistente de planejamento alimentar.

Objetivo: gerar um NOVO plano de 1 dia usando APENAS itens do catálogo.

Dia: ${day}
Perfil (pode estar incompleto): ${profileJson}
Plano atual (ids por refeição): ${currentJson}
MealTypes fixados (não alterar): ${lockedJson}

Regras:
- Escolha 1 item para cada mealType: breakfast, lunch, dinner, snack.
- Retorne SOMENTE IDs que existam no catálogo e respeitem o mealType.
- Tente aproximar a soma do dia ao calorie_target e macros do perfil (sem ser perfeito).
- Evite repetir o mesmo item do plano atual, quando possível.
- Se algum mealType estiver fixado, mantenha o mesmo ID do plano atual para esse mealType.
- Se dietary_preference indicar restrições, prefira opções compatíveis (ex.: vegetarian -> evitar carnes).

Catálogo (JSON):
${catalogJson}

Retorne APENAS JSON válido no formato:
{
  "meals": {
    "breakfast": "id",
    "lunch": "id",
    "dinner": "id",
    "snack": "id"
  }
}
Sem markdown, sem texto extra.
`;

    return callGemini(prompt, apiKey);
}

async function dietReplaceMealWithGemini(day, mealType, profile, catalog, current, weekUsedSameType, dayOtherMealIds, remaining, hints, apiKey) {
    const profileJson = profile ? JSON.stringify(profile) : "{}";
    const currentJson = current ? JSON.stringify(current) : "{}";
    const weekUsedJson = Array.isArray(weekUsedSameType) ? JSON.stringify(weekUsedSameType) : "[]";
    const dayOtherJson = Array.isArray(dayOtherMealIds) ? JSON.stringify(dayOtherMealIds) : "[]";
    const remainingJson = remaining ? JSON.stringify(remaining) : "{}";
    const hintsJson = Array.isArray(hints) ? JSON.stringify(hints) : "[]";

    const compactCatalog = catalog.map((m) => ({
        id: m.id,
        mealType: m.mealType,
        title: m.title,
        kcal: m.kcal,
        protein_g: m.protein_g,
        carbs_g: m.carbs_g,
        fat_g: m.fat_g,
        ingredients: Array.isArray(m.ingredients) ? m.ingredients : undefined,
    }));
    const catalogJson = JSON.stringify(compactCatalog);

    const prompt = `
Responda SEMPRE em português (pt-BR). Você é um assistente de planejamento alimentar.

Objetivo: substituir UMA refeição do dia usando APENAS itens do catálogo.

Dia: ${day}
MealType para substituir: ${mealType}
Perfil (pode estar incompleto): ${profileJson}
Plano atual (ids por refeição): ${currentJson}
IDs já usados na SEMANA para esse mealType (evite repetir): ${weekUsedJson}
IDs das OUTRAS refeições desse mesmo dia (evite duplicar no dia): ${dayOtherJson}
Macros/Calorias restantes ideais para essa refeição (aprox.): ${remainingJson}
Preferências para esta troca (pode ser vazio): ${hintsJson}

Regras:
- Retorne SOMENTE 1 ID (um item) que exista no catálogo e seja do mesmo mealType.
- Evite repetir o ID atual dessa refeição (quando possível).
- Evite escolher um item que já esteja usado nas outras refeições do mesmo dia (quando possível).
- Evite repetir na semana dentro do mesmo mealType (quando possível).
- Tente manter o total do dia próximo ao calorie_target e macros do perfil (as outras refeições permanecem as mesmas).
- Se dietary_preference indicar restrições, prefira opções compatíveis (ex.: vegetarian -> evitar carnes).
- Use o campo "ingredients" quando existir para checar compatibilidade (vegan/vegetarian/pescetarian etc.).
- Se hints incluir "no_lactose", evite leite/queijo/iogurte/whey etc.
- Se hints incluir "higher_protein", priorize itens com mais proteína (protein_g).
- Se hints incluir "lower_carbs", priorize itens com menos carboidratos (carbs_g).
- Se hints incluir "lower_fat", priorize itens com menos gordura (fat_g).

Catálogo (JSON):
${catalogJson}

Retorne APENAS JSON válido no formato:
{ "mealId": "id" }
Sem markdown, sem texto extra.
`;

    return callGemini(prompt, apiKey);
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
    const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${apiKey}`;

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
