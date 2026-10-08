---
name: analista-thelook
description: Diretrizes de análise de dados, regras de negócio e boas práticas para o dataset e-commerce theLook no BigQuery.
---

# Skill: Analista theLook E-Commerce

Esta skill orienta o agente sobre as regras de negócio essenciais, definições contábeis e armadilhas do dataset sintético `thelook_ecommerce`.

## 1. Princípios Inegociáveis

1. **Rigor em Receita Líquida:**
   - Apenas itens e pedidos faturados e não cancelados/devolvidos (`status NOT IN ('Cancelled', 'Returned')`).
   - Custo dos Produtos Vendidos (CPV) vem de `products.cost` ou `inventory_items.cost`.
   - $\text{Margem Bruta} = \frac{\text{Receita Líquida} - \text{CPV}}{\text{Receita Líquida}}$.

2. **Corte Temporal (D-7):**
   - Para evitar viés de dados incompletos na borda presente, todas as análises de fechamento encerram 7 dias antes da data atual (`DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)`).

3. **Ganho Incremental vs Ganho Total:**
   - Campanhas de marketing e reativação NUNCA devem assumir que 100% dos compradores retornaram por causa da campanha.
   - Sempre medir a **Taxa Base Histórica Espontânea** via backtest (ex: clientes similares 12 meses atrás que recompraram em 90 dias sem campanha).
   - O impacto da ação é estritamente o **Lift** acima da taxa base:
     $$\text{Receita Incremental} = \text{Tamanho do Segmento} \times \text{Lift} \times \text{Ticket Médio}$$

4. **Tratamento de Armadilhas no Dado Sintético:**
   - Pedidos "em processamento" ou "em trânsito" com anos de idade são resíduos do gerador sintético de dados.
   - Fila acionável de backoffice deve aplicar corte de bom senso operacional (ex: pedidos nos últimos 60 dias).

5. **Proteção Total a PII (LGPD / Privacidade):**
   - NUNCA consultar, exibir, exportar ou processar quaisquer dados pessoais identificáveis (PII), contatos, nomes, endereços ou identificadores de rede dos clientes.
   - Agregações devem sempre ser anonimizadas no nível de cohort, segmento ou produto.

