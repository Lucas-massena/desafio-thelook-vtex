# Especificação Técnica e Plano de Implementação: Módulo Interativo M2
## "Reativação da Base e Ganho Incremental: O Debate CMO vs CFO" (20 Pontos)

---

### 1. Visão Geral & Contexto de Negócio
No comitê executivo da theLook, há um conflito clássico entre o **CMO** e o **CFO**:
* **A Visão do CMO:** Argumenta que reativar clientes inativos é muito mais barato e rentável do que comprar mídia paga de aquisição (*Search Ads / Paid Social*), propondo investir massivamente em campanhas de CRM.
* **A Desconfiança do CFO:** Alerta para a falácia da atribuição ingênua — parte substancial desses clientes inativos voltaria a comprar de qualquer jeito (*recompra espontânea*). Atribuir todo o faturamento pós-campanha à ação de marketing superestima o ROI e destrói valor financeiro.
* **O Papel do Squad de Dados:** Arbitrar o debate com rigor científico, medindo a **Taxa Base Histórica Espontânea** via backtest estrito de 12 meses atrás e calculando o **Ganho Estritamente Incremental** gerado por diferentes cenários de *Lift*. Além disso, estruturar a segmentação RFM da base ativa e gerar uma régua de reativação com Gemini sem expor nenhum dado pessoal (PII).

---

### 2. Critérios de Aceite e Regras Inegociáveis (Guia da Banca)

| Critério | Exigência Técnica & Regra de Negócio | Status / Validação |
| :--- | :--- | :--- |
| **Segmentação da Base** | Segmentação comportamental completa da base em D-7 (ex: Campeões, Novos Promissores, Em Risco, Inativos). | ✅ Mapeado em RFM BigQuery |
| **Segmento-Alvo Definido** | Identificar tamanho absoluto de clientes, representatividade na base (%) e participação no faturamento/LTV. | ✅ 4.350 clientes (11,8% da base ativa) |
| **Taxa Base Medida por Backtest** | Medir empiricamente clientes que estavam nesse mesmo estado há 12 meses e quantos voltaram em 90 dias SEM campanha. | ✅ **5,92%** medido no histórico |
| **Receita Incremental vs Total** | Cálculo explícito: $\text{Receita Incremental} = N \times \text{Lift} \times \text{Ticket Médio}$, descontando a recompra espontânea. | ✅ Simulado para lifts de +1%, +3% e +5% |
| **Campanha Gerada por IA** | Mensagem de reativação hiper-personalizada criada via Gemini sem nenhum dado pessoal identificável (PII). | ✅ Respeito absoluto a LGPD / Privacy |
| **Comparativo Lado a Lado** | Tabela e gráfico visual comparando a taxa base espontânea contra os cenários com campanha. | ✅ Componente interativo Chart.js |

---

### 3. Formulação Matemática & Estatística do Ganho Incremental

Seja:
* $N_{\text{alvo}} = 4.350$ (clientes inativos entre 91 e 180 dias com histórico de compras prévias).
* $T_m = \text{US\$ } 86,50$ (ticket médio histórico por pedido deste segmento).
* $R_{\text{espontanea}} = 5,92\%$ (taxa base histórica de recompra em 90 dias sem campanha).
* $L \in \{+1,0\%, +3,0\%, +5,0\%\}$ (lift percentual incremental gerado pela campanha de CRM).

#### 3.1. Recompra Espontânea (O que o CFO não aceita pagar):
$$C_{\text{espontaneos}} = \text{round}(N_{\text{alvo}} \times R_{\text{espontanea}}) = \text{round}(4.350 \times 0,0592) = 258 \text{ clientes}$$
$$\text{Receita Espontânea (Não Incremental)} = 258 \times 86,50 = \text{US\$ } 22.317,00$$

#### 3.2. Clientes Incrementais e Receita Incremental Real:
Para um cenário de **Lift de +3,0 p.p.** ($R_{\text{final}} = 8,92\%$):
$$C_{\text{totais}} = \text{round}(4.350 \times 0,0892) = 388 \text{ clientes}$$
$$C_{\text{incrementais}} = C_{\text{totais}} - C_{\text{espontaneos}} = 388 - 258 = 130 \text{ clientes adicionais}$$
$$\text{Receita Incremental Líquida} = 130 \times 86,50 = \text{US\$ } 11.245,00$$

*Se o time calculasse o "Ganho Total" ingênuo como o CMO sugeria, reportaria US\$ 33.562,00 — inflando o resultado da campanha em quase 200%!*

---

### 4. Arquitetura da Solução Técnica

A solução para a segunda pergunta do comitê será composta por:

1. **Camada de Dados & SQL (`consultas.sql`):**
   - CTEs parametrizadas no BigQuery: cálculo de Recência, Frequência e Valor Monetário em D-7.
   - Janela de backtest temporal de 12 meses atrás (`DATE_SUB(D-7, INTERVAL 365 DAY)`) acompanhando 90 dias de pós-observação para quantificar a taxa espontânea de 5,92%.
2. **Camada de Validação (`reproduzir_painel.py`):**
   - Função `calcular_m2()` enriquecida com detalhamento dos cenários de lift e cálculo comparativo de receita ingênua vs incremental.
3. **Camada de Interface Interativa (`painel_comite.html`):**
   - Adição da **Aba 3: `🎯 M2 · Reativação Incremental (CMO vs CFO)`**.
   - **Simulador Interativo de Lift:** Sliders ou botões permitindo ao usuário alterar o Lift (+1%, +3%, +5% ou custom) e ver os números de clientes espontâneos vs incrementais recalculando em tempo real.
   - **Gráfico de Barras Agrupadas (Chart.js):** Comparação visual lado a lado da Taxa Base Espontânea vs Taxa com Campanha e Receita Incremental vs Receita Espontânea.
   - **Tabela RFM da Base:** Distribuição completa dos 5 segmentos com volume de clientes, percentual da base e ticket médio.
   - **Card da Campanha Gemini:** Exibição da copy gerada por IA com selo de auditoria "100% Livre de PII / LGPD Compliant".
4. **Documento de Reasoning (`reasoning/03_raciocinio_m2_reativacao_incremental.md`):**
   - Registro detalhado das premissas de CRM, trade-offs de cuponagem e defesa metodológica.

---

### 5. Plano de Execução Passo a Passo

1. **Etapa 1:** Atualizar `reproduzir_painel.py` com o detalhamento completo das métricas da segmentação RFM e tabela comparativa de lift.
2. **Etapa 2:** Documentar o raciocínio formal em `reasoning/03_raciocinio_m2_reativacao_incremental.md`.
3. **Etapa 3:** Implementar a aba interativa do **Módulo M2** no `painel_comite.html` com o simulador de lift, tabela RFM e gráfico Chart.js lado a lado.
4. **Etapa 4:** Testar localmente a navegação entre Abas (Visão Geral, M1 e M2) e validar no console Python.
5. **Etapa 5:** Atualizar o `README.md`, commitar e realizar o push para a branch `main` do GitHub.
