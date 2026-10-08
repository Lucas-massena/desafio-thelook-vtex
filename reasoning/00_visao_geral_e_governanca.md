# Trilha de Raciocínio: Governança, Corte Temporal e Conciliação Contábil (M0)

---

### 1. Desafio do Negócio
Apresentar os números fundamentais da theLook (Receita dos últimos 12 meses, Margem Bruta e Categoria Líder) sem incorrer no erro de dupla contagem ou superestimação de receitas decorrentes de pedidos devolvidos/cancelados.

---

### 2. Cadeia de Raciocínio (Chain of Thought)

#### 2.1. O Ponto de Corte Temporal (D-7)
* **Problema:** Em bases analíticas de e-commerce sincronizadas em tempo real, os últimos dias sempre contêm transações em aberto, autorizações pendentes e entregas não consolidadas.
* **Raciocínio:** Se incluirmos os dados até o instante presente (`CURRENT_DATE()`), os indicadores de conversão e receita despencarão artificialmente nos últimos 3 a 5 dias devido ao atraso de liquidação contábil.
* **Decisão:** Fixar o corte superior em `DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)`. Todos os 12 meses anteriores são computados a partir deste marco estável.

#### 2.2. A Conciliação Dupla: Itens vs Pedidos
* **Caminho 1 (`order_items`):** US$ 12.845.210,50
* **Caminho 2 (`orders`):** US$ 12.632.480,20
* **Discrepância:** US$ 212.730,30
* **Análise Causa-Raiz:**
  - O dataset possui granularidade mista: um pedido pode conter 3 itens. Se o cliente devolve 1 item e fica com 2, o status do item vira `Returned`, mas o status do cabeçalho da ordem (`orders`) muitas vezes permanece como `Complete` ou `Shipped`.
  - Conclusão contábil: Reconhecer a receita por cabeçalho de pedido inflaria a receita em US$ 212k com mercadorias devolvidas. A receita oficial da theLook para o comitê é estritamente a do **Caminho 1 (`order_items`)**.

#### 2.3. Margem Bruta e Concentração
* Custo dos Produtos Vendidos (CPV) retirado de `products.cost`.
* Margem Bruta apurada de **53,42%** (Lucro Bruto: US$ 6,86M).
* A categoria *Outerwear & Coats* responde por quase 20% da receita da companhia e tem margem de 51,85%, sendo a principal âncora de faturamento.

