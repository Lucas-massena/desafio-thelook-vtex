# Trilha de Raciocínio: M2, M3, M4 e M5 (Metodologia Completa)

---

### M2: Reativação da Base e a Armadilha da Recompra Espontânea (20 Pontos)
* **A Armadilha Comum:** Times de CRM costumam enviar cupom para clientes inativos, contar todos que compraram nos 90 dias seguintes e atribuir 100% da receita à campanha.
* **O Raciocínio Rigoroso:** Realizamos um backtest de 12 meses observando cohorts similares que não receberam nenhuma campanha.
  - Resultado: **5,92% dos clientes inativos entre 91 e 180 dias recompram espontaneamente**.
  - O ganho real da campanha é exclusivamente o **Lift Marginal** acima dos 5,92%.
  - Para o segmento de 4.350 clientes com ticket de US$ 86,50, um lift de +3,0 p.p. gera 130 pedidos adicionais e **US$ 11.245,00 em receita incremental**.
  - Expandindo para 38k inativos, a receita incremental líquida é projetada em **US$ 325.000,00**.

---

### M3: Capital Imobilizado e a Armadilha do Dado Sintético (10 Pontos)
* **Descoberta Crítica no BigQuery:**
  - A query pura de pedidos com status `Processing` (>3d) ou `Shipped` (>10d sem entrega) retornou **2.415 pedidos e US$ 342.180,00 em risco**.
  - Ao inspecionar a data de criação, descobrimos que **1.836 pedidos (76% da fila)** foram criados entre **2019 e 2023**. Trata-se de lixo gerado pelo simulador de dados sintéticos que nunca atualizou o status.
  - Se a operação tentasse resolver essa fila bruta, desperdiçaria tempo ligando para clientes de 5 anos atrás.
  - Aplicando a regra de plausibilidade operacional ($\le 60$ dias), isolamos a **fila acionável real de 284 pedidos e US$ 39.840,00 em risco**, permitindo alocação cirúrgica do time de backoffice.
* **Estoque Obsoleto:** Identificamos US$ 260.000 imobilizados há mais de 180 dias ao custo, com concentração maciça em casacos pesados (*Outerwear & Coats*).

---

### M4: Mídia e Retail Media com Rigor Estatístico (15 Pontos)
* **Validação de Significância dos Canais:**
  - Search: conversão de 8,50% [IC 95%: 8,24% - 8,77%].
  - Display: conversão de 7,10% [IC 95%: 6,66% - 7,56%].
  - Teste Z de duas proporções: **$Z = 4,9944$ ($p < 0,0001$)**. Comprovado que a superioridade de Search não é ruído amostral; Display deve ter verba cortada.
* **Atribuição por Cadeia de Markov:** Search responde por 34,2% do efeito de remoção (*removal effect*), sendo o canal decisivo de conversão na jornada multitoque.
* **Retail Media por Margem Esperada:**
  $$\text{Margem Esperada / Visita} = \text{Margem Unitária (US\$)} \times \text{Taxa de Conversão}$$
  O produto líder (*Winter Trench Coat Deluxe*) entrega **US$ 4,04 por visita**, viabilizando CPCs rentáveis em parcerias com fornecedores.

---

### M5 & V1: Alocação dos US$ 500k e a Virada das 16:10 (30 Pontos)
* **O Desafio da Virada:** Com o leilão de busca inflacionado em +22% no trimestre e a exigência de payback $< 2,5$ meses:
  - Reduzimos Aquisição de US$ 200k para **US$ 160k** (foco em termos de alta conversão comprovada).
  - Aumentamos Retail Media para **US$ 130k** (aproveitando o estoque parado e margem direta de marcas).
  - Direcionamos **US$ 110k** para Reativação (foco no público de maior ticket) e **US$ 100k** para Operação (fila de 284 pedidos).
* **Resultado Consolidado:**
  - Retorno Incremental Líquido: **US$ 1.285.000,00** (+157% ROI Líquido).
  - Payback Médio Ponderado: **2,38 meses** (meta batida).
  - No cenário de estresse severo (-30% lift e CAC inflacionado), o projeto ainda retorna **US$ 895.000,00** e payback de 3,4 meses.
