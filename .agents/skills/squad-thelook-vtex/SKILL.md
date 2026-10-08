---
name: squad-thelook-vtex
description: Metodologia proprietária do Squad VTEX theLook para cálculo auditado de receita, projeção estatística e alocação de capital.
---

# Metodologia Proprietária: Squad theLook VTEX

Esta skill encapsula o pipeline analítico reproduzível desenvolvido pelo time para auditoria e tomada de decisão executiva.

## 1. Algoritmo de Cálculo Duplo da Receita (Auditoria M0)
Para auditar a receita dos últimos 12 meses (D-7):
1. **Pipeline de Itens (`order_items`):**
   - Filtra `status NOT IN ('Cancelled', 'Returned')` no nível de item.
   - Computa Receita = $\sum \text{sale\_price}$ e Lucro Bruto = $\sum (\text{sale\_price} - \text{cost})$.
2. **Pipeline de Pedidos (`orders`):**
   - Agrupa itens pelo `order_id` e filtra pedidos onde `orders.status NOT IN ('Cancelled', 'Returned')`.
3. **Mecanismo de Conciliação:**
   - Compara a diferença entre as duas abordagens.
   - A discrepância é matematicamente isolada identificando pedidos multipartes onde itens individuais sofreram cancelamento/devolução parcial enquanto o status da ordem permaneceu ativo (ou pedidos inteiros cancelados no cabeçalho antes da sincronização dos itens).

## 2. Framework de Alocação de Capital (US$ 500k)
- **Critério de Otimização:** Maximizar Retorno Incremental Líquido respeitando Payback $\le 3$ meses.
- **Matriz de Sensibilidade:**
  - *Pessimista:* Queda de 30% no lift de reativação, aumento de 20% no CAC de aquisição.
  - *Base:* Estimativas empíricas de backtest e Wilson 95%.
  - *Otimista:* Sinergia entre retail media e busca orgânica (+15% no lift).

