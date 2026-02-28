# Política de Privacidade — Nutriz

**Última atualização:** 23/12/2025

Esta Política de Privacidade descreve como o app **Nutriz** (“Aplicativo”, “nós”) trata informações quando você usa o aplicativo.

> **Importante (para publicação):** substitua os campos entre colchetes no final deste documento (ex.: e‑mail de suporte).

## 1) Quais dados o app trata

### 1.1 Dados informados por você (no app)
O Nutriz permite que você registre e/ou edite informações que podem incluir:
- **Perfil:** nome, gênero, data de nascimento, altura, foto (opcional).
- **Dados de saúde e bem‑estar:** peso inicial e atual, metas, medições corporais, ingestão de água.
- **Diário alimentar:** refeições, itens/alimentos consumidos, quantidades e informações nutricionais.

Esses dados são usados para fornecer as funções do app (cálculos, metas, histórico, gráficos e gamificação).

### 1.2 Fotos enviadas para análise (recurso opcional)
Se você usar o recurso de **analisar alimento por foto**, o app:
- acessa uma foto escolhida por você (galeria/câmera via seletor do sistema); e
- **envia a imagem** para um serviço de análise do Nutriz para tentar retornar nome do alimento e macros/calorias.

No código atual, esse serviço é acessado por:
- `https://nutriz-food-ai.alexandretmoraes110.workers.dev/analyze-food`

Use este recurso apenas se concordar com o envio da imagem para análise.

### 1.3 Consultas de alimentos e códigos de barras
Ao buscar alimentos ou consultar por **código de barras**, o app pode enviar:
- o **texto digitado** (termo de busca); e/ou
- o **código de barras** escaneado/digitado

para fontes externas, incluindo:
- **OpenFoodFacts** (`https://world.openfoodfacts.org`)

### 1.4 Compras no app (planos/premium)
O app possui uma seção de **planos/assinaturas**. Dependendo de como você configurar a monetização:
- pagamentos são processados pela **Google Play** (e você não nos fornece dados do seu cartão);
- o app pode usar o SDK **RevenueCat** (`purchases_flutter`) para verificar status de assinatura/restauração de compras.

Esses serviços podem tratar dados relacionados à compra (ex.: status de assinatura) e identificadores técnicos necessários para entregar o serviço.

### 1.5 Dados técnicos e de uso (no dispositivo)
O app contém um registro simples de eventos (“analytics”) **salvo localmente no aparelho** (arquivo), com informações como:
- plataforma (ex.: Android), idioma/localidade e fuso horário; e
- eventos de uso (ex.: tempo até a primeira refeição).

O código atual não envia esses eventos automaticamente para um servidor de analytics de terceiros.

## 2) Como usamos os dados
Usamos as informações para:
- operar as funcionalidades do app (diário, metas, cálculos, gráficos, gamificação);
- analisar imagens de alimentos quando você solicita (recurso opcional);
- buscar informações nutricionais em bases públicas (ex.: OpenFoodFacts);
- oferecer e validar recursos premium/assinaturas (quando aplicável);
- melhorar estabilidade e depuração (quando você reporta problemas).

## 3) Onde os dados ficam armazenados
- **No dispositivo:** os dados do perfil/diário/medições são armazenados localmente no aparelho (banco local do app).
- **Em serviços externos:** quando você usa certos recursos, dados podem ser enviados:
  - **Fotos** para o serviço de análise (item 1.2).
  - **Busca/código de barras** para OpenFoodFacts (item 1.3).
  - **Compras/assinaturas** para Google Play/RevenueCat (item 1.4), se habilitado.

## 4) Compartilhamento com terceiros
Podemos compartilhar dados **apenas** quando necessário para fornecer recursos:
- OpenFoodFacts (busca/código de barras);
- Provedores de pagamento/assinatura (Google Play; e RevenueCat se configurado).

Cada serviço pode ter sua própria política de privacidade:
- OpenFoodFacts: https://world.openfoodfacts.org/privacy
- Google Play / Google Payments: https://policies.google.com/privacy
- RevenueCat: https://www.revenuecat.com/privacy/

## 5) Base legal (LGPD — Brasil)
Em geral, tratamos dados com base em:
- **execução de contrato**/prestação do serviço (para operar o app); e/ou
- **consentimento** (ex.: uso de fotos para análise), quando aplicável; e/ou
- **legítimo interesse** (ex.: melhoria do app), quando aplicável.

## 6) Seus controles e escolhas
Você pode:
- não usar o recurso de análise por foto (e não enviar imagens);
- revogar permissões no Android (Fotos/Câmera) nas configurações do aparelho;
- excluir dados localmente apagando registros dentro do app (quando disponível) ou **desinstalando** o aplicativo (o que remove os dados locais do app no dispositivo).

## 7) Retenção
- Dados locais permanecem no seu dispositivo enquanto você mantiver o app instalado.
- Dados enviados para serviços externos podem ser retidos conforme a finalidade do serviço e políticas aplicáveis.

## 8) Segurança
Adotamos medidas razoáveis para proteger dados no app e em trânsito (ex.: comunicação via HTTPS para serviços externos). Ainda assim, nenhum sistema é 100% seguro.

## 9) Crianças e adolescentes
O app não é destinado a menores de 13 anos. Se você acredita que uma criança nos forneceu dados pessoais, entre em contato para avaliarmos a solicitação.

## 10) Contato
Se você tiver dúvidas, solicitações ou quiser exercer direitos (LGPD), entre em contato:
- **Responsável:** [SEU NOME/EMPRESA]
- **E‑mail:** [SEU EMAIL DE SUPORTE]
- **País/UF:** [BRASIL/UF]

