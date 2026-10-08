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
| **[`02_raciocinio_consolidado_missoes.md`](./02_raciocinio_consolidado_missoes.md)** | Síntese M0 a M5 & V1 | Raciocínio consolidado de todas as missões, alocação balanceada dos US$ 500k, análise de sensibilidade e payback. |
| **[`03_raciocinio_m2_reativacao_incremental.md`](./03_raciocinio_m2_reativacao_incremental.md)** | M2 (20 pts) | Disputa CMO vs CFO resolvida com rigor: prova de 5,92% de taxa de retorno espontâneo (backtest de 12 meses atrás sem campanha), lift incremental (+3 p.p.), economia positiva do voucher VOLTE25 e campanha Gemini PII-free. |

---

## 🔬 Padrão Metodológico de Raciocínio (Template)
Cada decisão documentada segue o ciclo:
1. **Pergunta / Desafio do Comitê**
2. **Hipótese & Alternativas Avaliadas**
3. **Cálculo Matemático / Consulta SQL**
4. **Armadilha Identificada (Sintética, Estatística ou Contábil)**
5. **Decisão Final e Frase de Defesa ao CFO**

