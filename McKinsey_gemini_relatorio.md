# Nutriz Strategy & Launch Framework

## 1. Executive Summary
**Ação Número 1:** Lançar um MVP ultra-focado em "Biohacking Simplificado para o Público Brasileiro" priorizando a otimização orgânica (ASO) de cauda longa, postergando a aquisição paga até validar a retenção (D1/D7) e a conversão de assinatura no onboarding com os primeiros 1.000 usuários orgânicos.

**Pilares de Suporte:**
*   **Técnico (Flutter):** A base em Flutter permite iteração multiplataforma rápida e UI fluida, mas exige performance impecável (60fps) e gerenciamento de estado rígido em background (imprescindível para que o Android não mate o timer de jejum), tangibilizando a qualidade "Premium".
*   **Usuário (Retenção):** O diferencial não é listar macronutrientes do feijão com arroz (os gigantes já mapeiam isso), mas simplificar e evidenciar o impacto do jejum na saúde celular. A fricção no onboarding serve como qualificador de intenção ("Skin in the Game") antes da oferta.
*   **Financeiro (Monetização):** Sem um canal escalável de tráfego (Growth/Paid Ads) validado, a sobrevivência depende de maximizar a conversão inicial. Lançar sem um funil de assinatura (Paywall) testado é queimar a audiência early-adopter do teste fechado.

---

## 2. SCQ Analysis (Contexto Estratégico)

*   **Situação:** O Nutriz é um app Flutter de monitoramento calórico e saúde celular, operando em closed testing no mercado brasileiro. Entra em um nicho de fitness e nutrição de rápido crescimento (Life Extension / Biohacking).
*   **Complicação:** O ecossistema já é dominado por players estabelecidos (Yazio, MyFitnessPal, Zero) com vasta base de dados e bolsos fundos. Além disso, o app ainda não possui uma máquina de aquisição de usuários desenhada, arriscando um cenário de CAC (Custo de Aquisição) superior ao LTV (Life Time Value).
*   **A "Questão de Ouro":** *Como o Nutriz pode hackear o tráfego orgânico (ASO) na Play Store do Brasil, reter usuários mostrando valor em saúde celular em menos de 3 minutos de uso e converter 5% dessa base em assinantes pagos no primeiro trimestre visando o breakeven?*

---

## 3. Arquitetura do Produto (MECE Issue Tree)

Decomposição do foco de desenvolvimento em três frentes excludentes, mas exaustivas (MECE):

*   **A. Aquisição (Visibilidade na Loja / ASO)**
    *   **A.1. A concorrência em keywords genéricas esmaga apps novos:** Focar o cadastro e a indexação da loja em "Cauda Longa" (ex: "Jejum intermitente e celular", "Biohacking longevidade") ao invés de "dieta online".
    *   **A.2. A dependência de tráfego requer loops virais:** O design precisa construir "momentos compartilháveis" (ex: gráficos estéticos do tempo em estado de autofagia para o Instagram Stories).
*   **B. Retenção (UX / Valor do Jejum)**
    *   **B.1. A curva de aprendizado metabólico eleva o Churn no D1:** A UI (Interface) precisa abstrair conceitos difíceis. Substituir jargões por "Gamificação da Saúde Celular" (anéis progressivos e mensagens reforçadoras durante o jejum).
    *   **B.2. Falhas de confiabilidade destroem o engajamento:** Se o timer do jejum zerar por falhas nativas ou o app apresentar *jank* (quedas de frame visíveis), o usuário remove o app. O serviço de background task em Flutter Android deve ser à prova de balas.
*   **C. Monetização (Conversão Premium)**
    *   **C.1. Ocultar o Paywall adia a objeção de compra:** Testar radicalmente o layout de Paywall durante o Onboarding (quando o usuário está mais intencionado) logo após coletar seus dados ("A ilusão do labor planejado").
    *   **C.2. Feature de tabela calórica não sustenta SaaS:** A proposta do Plano Pro deve ancorar em diferenciação vertical (Insights e rotinas preditivas de queima de gordura/rejuvenescimento) e não no básico.

---

## 4. Benchmarking & Diferenciação

*   **Líderes de Mercado (Yazio / Zero / MFP):** Eles jogam o jogo do volume e possuem centenas de milhões de verbetes alimentares. Competir nesse aspecto é um erro estratégico.
*   **O "Unfair Advantage" do Nutriz:** Foco nichado em **Longevidade Prática**. O Nutriz deve se posicionar não apenas como um diário de calorias, mas como o "Painel de Controle do Biohacker". A interface e a cópia (copywriting) devem traduzir o fasting em progresso tangível de saúde (níveis de açúcar, cicatrização, autofagia). Tudo isso empacotado para a cultura do brasileiro.

---

## 5. Prioritized Launch Roadmap (Impacto vs. Esforço)

### Fase 1: MVP de Validação (Imediato - Próximos 30 dias)
*   **Essencial na Build (Flutter):** Fixar ciclo de vida do app para o Timer não morrer em modo Doze (Android). Integração perfeita de *In-App Purchases* (RevenueCat/Glassfy) + Paywall de Onboarding.
*   **Loja (Google Play):** Otimizar título e descrição (ASO) visando termos de biohacking secundários. Subir capturas de tela mostrando claramente os estágios da saúde celular.
*   **Tracking:** Amplitude ou Mixpanel focados em rastrear as etapas do Onboarding e métricas de D1 e D7.
*   **Risco Crítico:** Rejeição do app devido a políticas médicas do Google (Medical/Health Apps Policy).
    *   *Mitigação:* Isenção de responsabilidade visível no app alertando que os dados e jejum não substituem conselho médico.

### Fase 2: Otimização de Conversão (Curto Prazo - 30 a 60 dias)
*   **Produto:** Polimento visual da home com animações fluidas focadas em *reward* (Rive ou Lottie animations) quando completadas metas de hidratação e jejum.
*   **Loja:** Usar o Store Listing Experiments da Google Play para testar A/B do ícone e das screenshots vs variação regionalizada do Brasil.
*   **Growth:** Fechar parcerias micro-influenciadores brasileiros do nicho de "saúde integrativa" com links promocionais.

### Fase 3: Escala Sustentável (Médio Prazo - 60+ dias)
*   **Produto:** Integrações Health Connect e lançamento do "Social Sharing exportável" para alavancar aquisição Dark Social (WhatsApp).
*   **Aquisição:** Primeiros orçamentos de performance (Google UAC / Meta Ads) voltados, estritamente, em CAC inferior à primeira mensalidade.
*   **Monetização:** Explorar Planos Família ou Vendas Vitalícias limitadas para injetar caixa rápido, caso haja gargalo com modelo SaaS de assinatura mensal.
