# Histórico de Raciocínio (Reasoning Log) · Squad theLook VTEX

Esta pasta armazena o histórico analítico, as decisões arquiteturais, o raciocínio formal e as cadeias de pensamento (*chain of thought*) utilizadas pelo Squad e pelos Agentes de IA durante a resolução do **Desafio theLook: O Comitê de Segunda-Feira** (Workshop VTEX Data & AI).

---

## 🎯 Objetivo da Trilha de Raciocínio
Demonstrar a **rastreabilidade total (100% auditável e sem alucinações)** de cada métrica levada ao CFO e ao Conselho de Administração. Todos os cálculos decorrem de dados brutos do BigQuery (`bigquery-public-data.thelook_ecommerce`), premissas de negócio consolidadas em D-7 e modelos validados por testes estatísticos de hipótese e backtests cegos.

---

## 📚 Índice de Documentos de Raciocínio

| Arquivo | Missão / Tópico | Síntese do Raciocínio e Decisões Críticas |
| :--- | :--- | :--- |
| **[`00_visao_geral_e_governanca.md`](./00_visao_geral_e_governanca.md)** | Governança & D-7 | Critério de corte temporal em D-7, eliminação de viés de borda, conciliação de receita dupla (`order_items` vs `orders`) e proteção a PII. |
| **[`01_raciocinio_m1_fechamento_e_backtest.md`](./01_raciocinio_m1_fechamento_e_backtest.md)** | M1 (15 pts) | Racional do backtest cego no dia 17, justificativa técnica da superioridade do TimesFM (`AI.FORECAST`) sobre a Média Móvel de 28 Dias (modelagem de fins de semana) e defesa para o CFO. |
| **[`02_raciocinio_m2_reativacao_incremental.md`](./02_raciocinio_m2_reativacao_incremental.md)** | M2 (20 pts) | Por que receita de reativação sem descontar taxa base espontânea destrói valor: comprovação dos 5,92% de recompra orgânica e cálculo do lift estritamente incremental. |
| **[`03_raciocinio_m3_estoque_e_qualidade_dados.md`](./03_raciocinio_m3_estoque_e_qualidade_dados.md)** | M3 (10 pts) | Diagnóstico da anomalia do dado sintético (76% da fila gerada entre 2019-2023), saneamento da fila de exceções para 284 pedidos acionáveis e US$ 260k em casacos parados. |
| **[`04_raciocinio_m4_estatistica_e_retail_media.md`](./04_raciocinio_m4_estatistica_e_retail_media.md)** | M4 (15 pts) | Validação matemática de canais via Intervalo de Wilson 95%, Teste Z de duas proporções ($Z=4,99, p<0.0001$), Atribuição por Cadeia de Markov e ranking de Retail Media por margem esperada/visita. |
| **[`05_raciocinio_m5_alocacao_e_virada_v1.md`](./05_raciocinio_m5_alocacao_e_virada_v1.md)** | M5 & V1 (30 pts) | Racional da redistribuição de capital pós-virada das 16:10: amortecimento da inflação de CAC de busca (+22%), priorização de Retail Media e encurtamento do payback para 2,38 meses. |

---

## 🔬 Padrão Metodológico de Raciocínio (Template)
Cada decisão documentada segue o ciclo:
1. **Pergunta / Desafio do Comitê**
2. **Hipótese & Alternativas Avaliadas**
3. **Cálculo Matemático / Consulta SQL**
4. **Armadilha Identificada (Sintética, Estatística ou Contábil)**
5. **Decisão Final e Frase de Defesa ao CFO**
