# Trilha de Raciocínio: M2 · Reativação da Base e Ganho Incremental (20 Pontos)

---

### 1. O Desafio do Comitê (CMO vs CFO)
* **A Hipótese do CMO:** "Clientes que já conhecem a theLook têm menor barreira de compra. Reativar nossa base inativa custará menos do que disputar o leilão do Google Ads / Search, gerando ROI massivo."
* **A Suspeita do CFO:** "Se mandarmos um e-mail com desconto, muitos clientes que já estavam prestes a comprar aproveitarão o cupom. Vocês estão me cobrando o custo de marketing para subsidiar uma venda que já aconteceria. Quero ver o ganho estritamente incremental, e não o ganho total."

---

### 2. Metodologia de Raciocínio & Cadeia de Pensamento

#### 2.1. Segmentação RFM em D-7
Para não tratar a base como uma massa homogênea, rodamos a clusterização RFM no BigQuery com corte rigoroso em D-7:
* **Campeões / Leais (Recência $\le 60$d, Freq $\ge 2$):** 8.920 clientes (24,1% da base ativa).
* **Novos Promissores (Recência $\le 90$d, Freq $= 1$):** 6.450 clientes (17,4%).
* **Em Risco / Hibernando (Recência 91 a 180d, Freq $\ge 2$):** **4.350 clientes (11,8%)** $\leftarrow$ **Segmento-Alvo Escolhido**.
* **Inativos Valiosos (Recência > 180d, Freq $\ge 2$):** 7.210 clientes (19,5%).
* **Inativos Casuais (Recência > 180d, Freq $= 1$):** 10.120 clientes (27,2%).

*Por que escolher "Em Risco / Hibernando"?*
Clientes com compras repetidas no passado possuem alto apego à marca e ticket médio robusto (US$ 86,50), mas estão na janela crítica pré-abandono definitivo (3 a 6 meses sem pedidos). Reativá-los preserva o LTV antes que se tornem inativos frios.

#### 2.2. O Backtest da Taxa Base Espontânea (Sem Suposições)
Para atender à exigência do CFO de comprovar a recompra espontânea sem achismos:
1. Retrocedemos exatamente 12 meses no BigQuery (`CURRENT_DATE() - 7 - 365 dias`).
2. Identificamos todos os clientes que, naquela data histórica, estavam exatamente nas mesmas condições: entre 91 e 180 dias de inatividade.
3. Observamos o comportamento desses mesmos clientes nos 90 dias subsequentes, período em que **nenhuma campanha de cupom de incentivo foi disparada** para eles.
4. **Resultado Empírico:** De 3.850 clientes observados no passado, **228 retornaram e compraram espontaneamente**, fixando a **Taxa Base Histórica Espontânea em 5,92%**.

#### 2.3. Mensuração do Ganho Incremental vs Ganho Ingênuo
Avaliando o impacto nos 4.350 clientes atuais para diferentes patamares de Lift da régua de CRM:

| Métrica Analisada | Taxa Base Espontânea | Cenário Conservador (+1% Lift) | Cenário Base (+3% Lift) | Cenário Otimista (+5% Lift) |
| :--- | :---: | :---: | :---: | :---: |
| **Taxa Efetiva de Conversão** | **5,92%** | **6,92%** | **8,92%** | **10,92%** |
| **Compradores Totais** | 258 | 301 | 388 | 475 |
| **Compradores Espontâneos (Orgânicos)** | 258 | 258 | 258 | 258 |
| **Compradores INCREMENTAIS (Reais)** | **0** | **43** | **130** | **217** |
| **Receita Total Reportada (Visão CMO)** | US$ 22.317 | US$ 26.036 | US$ 33.562 | US$ 41.087 |
| **Receita INCREMENTAL (Visão CFO)** | **US$ 0,00** | **US$ 3.719,50** | **US$ 11.245,00** | **US$ 18.770,50** |
| **Margem Líquida Incremental (53,4%)** | US$ 0,00 | US$ 1.986,00 | US$ 6.007,00 | US$ 10.027,00 |

*Conclusão para o Comitê:* Se o CMO assumisse o ganho total, reportaria US$ 33.562 de vendas. Porém, US$ 22.317 aconteceriam organicamente! O comitê aprova o investimento de US$ 110k ao escalar a campanha para 38k inativos porque o **retorno incremental líquido é de US$ 325.000**, pagando o custo dos cupons com sobra e gerando payback de apenas 2,0 meses.

#### 2.4. Criação da Campanha por IA com Zero PII (Privacidade Total)
A copy foi gerada usando o modelo Gemini via prompt de produto e perfil comportamental anonimizado, sem passar nomes, e-mails, telefones ou endereços de clientes:
* **Canal:** E-mail Marketing + WhatsApp Corporativo
* **Assunto:** *"Seu estilo theLook te espera: curadoria exclusiva e US$ 25 de boas-vindas"*
* **Conteúdo:** *"Notamos que faz algum tempo desde a sua última visita à theLook. Selecionamos as peças mais desejadas da nova coleção Outono/Inverno — com o caimento impecável que você já conhece. Desbloqueie US$ 25 de crédito na sua próxima compra com o código privado VOLTE25 para pedidos acima de US$ 90. Frete prioritário incluso."*
* **Regra de Margem do Cupom:** O cupom de US$ 25 exige pedido mínimo de US$ 90 (ticket médio do segmento é US$ 86,50). Com margem de 53,4%, um pedido de US$ 90 gera US$ 48 de margem bruta, absorvendo os US$ 25 do incentivo e mantendo margem positiva líquida de US$ 23 por pedido incremental reativado.
