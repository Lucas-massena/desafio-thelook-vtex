# theLook E-Commerce · Desafio Comitê de Segunda-Feira (VTEX Data & AI)

Repositório oficial com a resolução completa do desafio executivo do **Workshop VTEX Data & AI**, desenvolvido em parceria com Google Cloud e HVAR Consulting.

---

## 📌 Visão Geral do Projeto

A theLook é um varejo global de moda online com operação em 16 países. O objetivo deste projeto foi estruturar a recomendação analítica para a alocação de **US$ 500.000** de orçamento do comitê executivo entre quatro frentes estratégicas:
1. **Aquisição de Clientes (Search / Paid Traffic)**
2. **Reativação da Base Inativa (Com cálculo de Ganho Incremental)**
3. **Retail Media (Patrocínio de Produtos de Alta Margem)**
4. **Eficiência Operacional (Estoque Parado e Saneamento de Backoffice)**

---

## 📊 Principais Resultados

* **Orçamento Alocado:** US$ 500.000
* **Retorno Incremental Total Projetado:** **US$ 1.285.000** (+157% ROI Líquido)
* **Payback Médio Ponderado:** **2,38 Meses** (meta < 2,5m atingida)
* **Receita Auditada theLook (12 meses D-7):** US$ 12,85M com margem bruta de 53,42%
* **Modelo Preditivo Escolhido (M1):** TimesFM (`AI.FORECAST`), registrando **erro de apenas 2,69% no backtest** (vs 6,69% da média simples)
* **Reativação Auditada (M2):** Taxa base espontânea de 5,92% descontada do retorno para apuração do lift estritamente incremental
* **Qualidade de Dados (M3):** Expurgados 1.836 pedidos órfãos gerados entre 2019 e 2023 no dataset sintético; fila de exceções depurada para 284 pedidos acionáveis (US$ 39,8k em risco)
* **Validação Estatística (M4):** Superioridade de conversão em Search comprovada via teste Z de duas proporções ($p < 0.0001$) e Atribuição via Cadeia de Markov (Search com 34,2% de remoção)

---

## 🛠️ Estrutura do Repositório

```text
├── painel_comite.html          # Dashboard executivo interativo com Abas de Navegação (Módulo M1 Dedicado)
├── especificacao_tecnica_m1.md # Especificação Técnica formal para o Módulo M1 (Critérios da Banca)
├── respostas.md                # Respostas formais com origem, premissas e leitura de negócio (M0 a M5 + V1)
├── consultas.sql               # Scripts SQL auditados no BigQuery (bigquery-public-data.thelook_ecommerce)
├── bonus.md                    # Evidências e documentação dos +45 pontos de bônus
├── reproduzir_painel.py        # Script Python para reprodução ponta a ponta
└── .agents/
    └── skills/                 # Skills VTEX, analista theLook e metodologia do Squad
```

---

## 🚀 Como Executar

### 1. Visualizar o Painel Executivo Interativo
Abra o arquivo `painel_comite.html` diretamente em qualquer navegador moderno ou rode localmente:
```bash
python -m http.server 8080
# Acesse no navegador: http://localhost:8080/painel_comite.html
```
* **Navegação por Abas:** Alterne entre a **Visão Geral do Comitê** (alocação dos US$ 500k e síntese de todas as missões) e a nova aba dedicada **M1 · Fechamento do Mês & Backtest** para auditar a série temporal dia a dia cortada no dia 17 e a performance do TimesFM vs Média Móvel de 28 Dias.

### 2. Reproduzir os Cálculos
Para auditar e recalcular todos os testes estatísticos e simulações financeiras:
```bash
python reproduzir_painel.py
```
