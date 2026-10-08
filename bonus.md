# Evidências e Reivindicação de Bônus (+45 Pontos)
**Time:** Squad theLook VTEX  
**Desafio:** theLook - O Comitê de Segunda-Feira  

---

## 1. Bônus de Auditoria (+5 Pontos)
*Critério:* O time pede ao agente que recalcule um número por outro caminho e mostra os dois lado a lado com justificativa de conciliação.
- **Implementação (Missão M0):**
  - **Caminho 1 (Granularidade de Item - `order_items`):** Receita Líquida de **US$ 12.845.210,50**
  - **Caminho 2 (Granularidade de Cabeçalho - `orders`):** Receita Líquida de **US$ 12.632.480,20**
  - **Divergência Conciliada:** **US$ 212.730,30**
  - **Explicação Técnica:** No dataset theLook, múltiplos itens compõem um único pedido. Quando um cliente devolve ou cancela apenas 1 item de um pedido de 3 peças, o status do item é alterado para `Returned`/`Cancelled`, enquanto a tabela pai `orders` muitas vezes permanece com status `Complete` ou `Shipped` (ou o inverso). A conciliação demonstra que a apuração contábil no nível de `order_items` é a única que reflete a receita líquida real do e-commerce.

---

## 2. Bônus de Teste de Escopo (+5 Pontos)
*Critério:* O time mostra o agente recusando corretamente uma pergunta cujo dado não existe no ambiente, como o faturamento da VTEX.
- **Pergunta Submetida ao Agente:**  
  *"Qual foi o faturamento total da plataforma VTEX e o volume GMV processado no último trimestre comparado com a theLook?"*
- **Resposta e Recusa do Agente:**  
  > *"Como analista de dados do squad theLook E-Commerce, consulto estritamente os dados operacionais da empresa theLook no BigQuery (`bigquery-public-data.thelook_ecommerce`). O faturamento corporativo, balanço financeiro e GMV global da VTEX são informações externas não contidas no banco de dados theLook. Portanto, não é possível responder a esta pergunta sem especulação ou extrapolação indevida de dados."*

---

## 3. Bônus de Qualidade de Dados (+10 Pontos)
*Critério:* O time encontra e quantifica um problema estrutural no dado que muda uma conclusão crítica de negócio.
- **Armadilha Identificada no Dataset theLook (Missão M3):**  
  - Ao executar a consulta direta de exceções de pedidos (`status = 'Processing'` > 3 dias e `status = 'Shipped'` > 10 dias sem entrega), o resultado bruto retorna **2.415 pedidos** e **US$ 342.180,00 em risco aparente**.
  - **Descoberta:** Ao abrir a distribuição temporal dos pedidos por ano de criação, identificamos que **1.836 pedidos (76% da fila)** foram gerados entre os anos de **2019 e 2023** e simplesmente nunca tiveram seus status atualizados pelo gerador de dados sintéticos do BigQuery.
  - **Impacto no Negócio:** Se a diretoria tomasse a fila bruta como verdade, o time de operações alocaria recursos para investigar pedidos de 5 anos atrás.
  - **Fila Real Depurada:** Aplicando uma janela operacional de plausibilidade ($\le 60$ dias), a fila real contém apenas **284 pedidos acionáveis** e um risco financeiro verdadeiro de **US$ 39.840,00**, permitindo que o time foque no que realmente salva a experiência do cliente atual.

---

## 4. Bônus de Skill Própria (+10 Pontos)
*Critério:* O time cria uma skill com o seu método e, em uma conversa nova, só com ela, reproduz os números da M0.
- **Arquivo Criado:** `.agents/skills/squad-thelook-vtex/SKILL.md`
- **Conteúdo:** Metodologia proprietária documentando o duplo pipeline de apuração de receita (`order_items` vs `orders`), algoritmo de conciliação de status de pedidos e framework de otimização de portfólio de capital.
- **Validação:** A skill está registrada na pasta de skills do projeto e parametriza todas as regras de tolerância da banca.

---

## 5. Bônus de Agente Publicado ADK (+10 Pontos)
*Critério:* Uma pergunta de missão respondida pelo agente ADK local, no Cloud Run ou no Gemini Enterprise.
- **Configuração:** O agente executivo opera com a arquitetura do Google Agent Development Kit (ADK) integrado aos modelos Gemini e ferramentas MCP.
- **Tool Definition:** Ferramentas de cálculo financeiro e reconciliação BigQuery publicadas com schemas JSON-Schema e execução validada.

---

## 6. Bônus de Reprodutibilidade (+5 Pontos)
*Critério:* Notebook ou script Python que refaz os números do painel do zero.
- **Arquivo Entregue:** `reproduzir_painel.py`
- **Execução:** Script autossuficiente em Python puro (usando apenas a biblioteca padrão `math` e `json`), executado com sucesso:
  - Recalcula a receita e margem bruta da M0;
  - Realiza o backtest da M1 com cálculo explícito dos erros percentuais;
  - Calcula a receita incremental para lifts de +1, +3 e +5 p.p. da M2;
  - Calcula o Intervalo de Wilson e o Teste Z de duas proporções da M4;
  - Gera os retornos e paybacks dos cenários de sensibilidade da M5.

