-- ==============================================================================
-- WORKSHOP VTEX DATA & AI - DESAFIO THELOOK: O COMITÊ DE SEGUNDA-FEIRA
-- ARQUIVO: consultas.sql
-- AUTOR: Squad theLook VTEX (Trilha Técnica / BigQuery)
-- DATASET: bigquery-public-data.thelook_ecommerce
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- M0. RAIO-X EM TRÊS NÚMEROS, POR DOIS CAMINHOS
-- Objetivo: Receita líquida dos últimos 12 meses (D-7), Margem Bruta e Categoria Líder.
-- Comparar caminho via order_items vs orders.
-- ------------------------------------------------------------------------------

-- CAMINHO 1: Partindo de order_items (visão item a item - referência para receita líquida e margem)
WITH base_periodo AS (
  SELECT 
    DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY) AS data_fim,
    DATE_SUB(DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY), INTERVAL 365 DAY) AS data_inicio
),
itens_validos AS (
  SELECT
    oi.id,
    oi.order_id,
    oi.user_id,
    oi.sale_price,
    p.cost,
    p.category,
    oi.status,
    oi.created_at
  FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
  JOIN `bigquery-public-data.thelook_ecommerce.products` p ON oi.product_id = p.id
  CROSS JOIN base_periodo bp
  WHERE DATE(oi.created_at) BETWEEN bp.data_inicio AND bp.data_fim
    AND oi.status NOT IN ('Cancelled', 'Returned')
)
SELECT
  'Caminho 1: order_items' AS caminho,
  ROUND(SUM(sale_price), 2) AS receita_liquida_usd,
  ROUND(SUM(sale_price - cost), 2) AS lucro_bruto_usd,
  ROUND(SAFE_DIVIDE(SUM(sale_price - cost), SUM(sale_price)) * 100, 2) AS margem_bruta_pct,
  COUNT(DISTINCT order_id) AS total_pedidos,
  COUNT(id) AS total_itens
FROM itens_validos;

-- CAMINHO 2: Partindo de orders (visão cabeçalho do pedido)
WITH base_periodo AS (
  SELECT 
    DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY) AS data_fim,
    DATE_SUB(DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY), INTERVAL 365 DAY) AS data_inicio
),
pedidos_validos AS (
  SELECT
    o.order_id,
    o.num_of_item,
    o.status,
    SUM(oi.sale_price) AS valor_pedido,
    SUM(p.cost) AS custo_pedido
  FROM `bigquery-public-data.thelook_ecommerce.orders` o
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi ON o.order_id = oi.order_id
  JOIN `bigquery-public-data.thelook_ecommerce.products` p ON oi.product_id = p.id
  CROSS JOIN base_periodo bp
  WHERE DATE(o.created_at) BETWEEN bp.data_inicio AND bp.data_fim
    AND o.status NOT IN ('Cancelled', 'Returned')
  GROUP BY o.order_id, o.num_of_item, o.status
)
SELECT
  'Caminho 2: orders' AS caminho,
  ROUND(SUM(valor_pedido), 2) AS receita_liquida_usd,
  ROUND(SUM(valor_pedido - custo_pedido), 2) AS lucro_bruto_usd,
  ROUND(SAFE_DIVIDE(SUM(valor_pedido - custo_pedido), SUM(valor_pedido)) * 100, 2) AS margem_bruta_pct,
  COUNT(order_id) AS total_pedidos
FROM pedidos_validos;

-- AUDITORIA DA DIFERENÇA ENTRE OS CAMINHOS (M0 - Critério de aceite)
-- Identifica itens cancelados/devolvidos em pedidos com status 'Complete'/'Shipped' ou vice-versa
SELECT
  o.status AS status_pedido,
  oi.status AS status_item,
  COUNT(oi.id) AS qtd_itens,
  ROUND(SUM(oi.sale_price), 2) AS valor_total_usd
FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
JOIN `bigquery-public-data.thelook_ecommerce.orders` o ON oi.order_id = o.order_id
WHERE DATE(oi.created_at) BETWEEN DATE_SUB(CURRENT_DATE(), INTERVAL 372 DAY) AND DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
  AND (
    (o.status IN ('Cancelled', 'Returned') AND oi.status NOT IN ('Cancelled', 'Returned'))
    OR (o.status NOT IN ('Cancelled', 'Returned') AND oi.status IN ('Cancelled', 'Returned'))
  )
GROUP BY 1, 2
ORDER BY valor_total_usd DESC;

-- CATEGORIA LÍDER E MARGEM
WITH base_periodo AS (
  SELECT 
    DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY) AS data_fim,
    DATE_SUB(DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY), INTERVAL 365 DAY) AS data_inicio
)
SELECT
  p.category,
  ROUND(SUM(oi.sale_price), 2) AS receita_usd,
  ROUND(SUM(oi.sale_price - p.cost), 2) AS lucro_bruto_usd,
  ROUND(SAFE_DIVIDE(SUM(oi.sale_price - p.cost), SUM(oi.sale_price)) * 100, 2) AS margem_bruta_pct,
  COUNT(oi.id) AS itens_vendidos
FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
JOIN `bigquery-public-data.thelook_ecommerce.products` p ON oi.product_id = p.id
CROSS JOIN base_periodo bp
WHERE DATE(oi.created_at) BETWEEN bp.data_inicio AND bp.data_fim
  AND oi.status NOT IN ('Cancelled', 'Returned')
GROUP BY p.category
ORDER BY receita_usd DESC
LIMIT 5;


-- ------------------------------------------------------------------------------
-- M1. FECHAMENTO DO MÊS E BACKTEST DE MODELOS DE PREVISÃO
-- Comparação: TimesFM / AI.FORECAST vs Média Móvel de 28 Dias
-- ------------------------------------------------------------------------------

-- PARTE A: BACKTEST NO MÊS ANTERIOR (simulando estar no dia 17)
WITH receita_diaria_passada AS (
  SELECT
    DATE(created_at) AS data_venda,
    ROUND(SUM(sale_price), 2) AS receita_diaria
  FROM `bigquery-public-data.thelook_ecommerce.order_items`
  WHERE status NOT IN ('Cancelled', 'Returned')
    AND DATE(created_at) >= DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY)
  GROUP BY 1
),
historico_ate_dia_17 AS (
  -- Supondo mês de Setembro (dia 1 ao dia 17)
  SELECT 
    AVG(receita_diaria) AS media_diaria_28d_dia17
  FROM receita_diaria_passada
  WHERE data_venda BETWEEN DATE_SUB(DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH), INTERVAL 28 DAY)
                       AND DATE_ADD(DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH), INTERVAL 16 DAY)
),
fechamento_real_mes_anterior AS (
  SELECT
    ROUND(SUM(sale_price), 2) AS receita_real_total,
    ROUND(SUM(CASE WHEN EXTRACT(DAY FROM created_at) <= 17 THEN sale_price ELSE 0 END), 2) AS receita_real_ate_dia17,
    ROUND(SUM(CASE WHEN EXTRACT(DAY FROM created_at) > 17 THEN sale_price ELSE 0 END), 2) AS receita_real_pos_dia17
  FROM `bigquery-public-data.thelook_ecommerce.order_items`
  WHERE status NOT IN ('Cancelled', 'Returned')
    AND DATE(created_at) BETWEEN DATE_TRUNC(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH)
                             AND LAST_DAY(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH)
)
SELECT
  r.receita_real_total,
  r.receita_real_ate_dia17,
  -- Método 1: Média Móvel de 28 dias
  ROUND(r.receita_real_ate_dia17 + (h.media_diaria_28d_dia17 * (EXTRACT(DAY FROM LAST_DAY(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH)) - 17)), 2) AS projecao_media_28d,
  ROUND(ABS(
    (r.receita_real_ate_dia17 + (h.media_diaria_28d_dia17 * (EXTRACT(DAY FROM LAST_DAY(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH), MONTH)) - 17))) - r.receita_real_total
  ) / r.receita_real_total * 100, 2) AS erro_pct_media_28d
FROM fechamento_real_mes_anterior r
CROSS JOIN historico_ate_dia_17 h;


-- PARTE B: PROJEÇÃO DO MÊS ATUAL (TIMESFM / AI.FORECAST)
-- (Sintaxe para BigQuery ML com modelo ARIMA_PLUS ou AI.FORECAST)
/*
CREATE OR REPLACE MODEL `mlops-workspace.vtex_workshop.modelo_forecast_thelook`
OPTIONS(model_type='ARIMA_PLUS', time_series_timestamp_col='data_venda', time_series_data_col='receita_diaria') AS
SELECT
  DATE(created_at) AS data_venda,
  SUM(sale_price) AS receita_diaria
FROM `bigquery-public-data.thelook_ecommerce.order_items`
WHERE status NOT IN ('Cancelled', 'Returned')
  AND DATE(created_at) <= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
GROUP BY 1;

SELECT
  forecast_timestamp,
  forecast_value,
  prediction_interval_lower_bound AS pessimista,
  prediction_interval_upper_bound AS otimista
FROM ML.FORECAST(MODEL `mlops-workspace.vtex_workshop.modelo_forecast_thelook`,
  STRUCT(21 AS horizon, 0.9 AS confidence_level));
*/


-- ------------------------------------------------------------------------------
-- M2. SEGMENTAÇÃO RFM, TAXA BASE HISTÓRICA E GANHO INCREMENTAL
-- ------------------------------------------------------------------------------

-- Segmentação RFM em D-7
WITH base_d7 AS (
  SELECT DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY) AS data_ref
),
rfm_raw AS (
  SELECT
    oi.user_id,
    DATE_DIFF(ref.data_ref, MAX(DATE(oi.created_at)), DAY) AS recencia_dias,
    COUNT(DISTINCT oi.order_id) AS frequencia_pedidos,
    SUM(oi.sale_price) AS valor_monetario
  FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
  CROSS JOIN base_d7 ref
  WHERE DATE(oi.created_at) <= ref.data_ref
    AND oi.status NOT IN ('Cancelled', 'Returned')
  GROUP BY oi.user_id, ref.data_ref
),
segmentos AS (
  SELECT
    user_id,
    recencia_dias,
    frequencia_pedidos,
    valor_monetario,
    CASE
      WHEN recencia_dias <= 60 AND frequencia_pedidos >= 2 THEN 'Campeões / Leais'
      WHEN recencia_dias <= 90 AND frequencia_pedidos = 1 THEN 'Novos Promissores'
      WHEN recencia_dias BETWEEN 91 AND 180 THEN 'Em Risco / Hibernando (Alvo Reativação)'
      WHEN recencia_dias > 180 AND frequencia_pedidos >= 2 THEN 'Inativos Valiosos'
      ELSE 'Inativos Casuais'
    END AS segmento
  FROM rfm_raw
)
SELECT
  segmento,
  COUNT(user_id) AS total_clientes,
  ROUND(COUNT(user_id) * 100.0 / SUM(COUNT(user_id)) OVER(), 2) AS pct_base,
  ROUND(SUM(valor_monetario), 2) AS receita_total_acumulada,
  ROUND(AVG(valor_monetario), 2) AS ltv_medio,
  ROUND(AVG(valor_monetario / frequencia_pedidos), 2) AS ticket_medio_pedido
FROM segmentos
GROUP BY segmento
ORDER BY total_clientes DESC;

-- BACKTEST DA TAXA BASE ESPONTÂNEA DE REATIVAÇÃO (12 MESES ATRÁS)
WITH base_ref_passada AS (
  SELECT DATE_SUB(DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY), INTERVAL 365 DAY) AS data_ref
),
clientes_em_risco_passado AS (
  SELECT
    oi.user_id,
    DATE_DIFF(ref.data_ref, MAX(DATE(oi.created_at)), DAY) AS recencia_dias,
    COUNT(DISTINCT oi.order_id) AS frequencia
  FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
  CROSS JOIN base_ref_passada ref
  WHERE DATE(oi.created_at) <= ref.data_ref
    AND oi.status NOT IN ('Cancelled', 'Returned')
  GROUP BY oi.user_id, ref.data_ref
  HAVING recencia_dias BETWEEN 91 AND 180
),
recompras_90d AS (
  SELECT
    c.user_id,
    COUNT(DISTINCT oi.order_id) AS compras_posteriores
  FROM clientes_em_risco_passado c
  CROSS JOIN base_ref_passada ref
  JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi ON c.user_id = oi.user_id
  WHERE DATE(oi.created_at) > ref.data_ref
    AND DATE(oi.created_at) <= DATE_ADD(ref.data_ref, INTERVAL 90 DAY)
    AND oi.status NOT IN ('Cancelled', 'Returned')
  GROUP BY c.user_id
)
SELECT
  COUNT(c.user_id) AS total_clientes_em_risco_ano_anterior,
  COUNT(r.user_id) AS clientes_que_voltaram_espontaneamente,
  ROUND(COUNT(r.user_id) * 100.0 / COUNT(c.user_id), 2) AS taxa_base_espontanea_pct
FROM clientes_em_risco_passado c
LEFT JOIN recompras_90d r ON c.user_id = r.user_id;


-- ------------------------------------------------------------------------------
-- M3. CAPITAL EM ESTOQUE PARADO E FILA DE EXCEÇÕES DE PEDIDOS
-- ------------------------------------------------------------------------------

-- ESTOQUE DISPONÍVEL IMOBILIZADO AO CUSTO POR FAIXA DE IDADE E CATEGORIA
WITH estoque_disponivel AS (
  SELECT
    id,
    product_id,
    cost,
    product_category,
    created_at,
    DATE_DIFF(CURRENT_DATE(), DATE(created_at), DAY) AS dias_em_estoque
  FROM `bigquery-public-data.thelook_ecommerce.inventory_items`
  WHERE sold_at IS NULL
)
SELECT
  CASE
    WHEN dias_em_estoque <= 30 THEN '0 a 30 dias (Giro Rápido)'
    WHEN dias_em_estoque <= 90 THEN '31 a 90 dias (Normal)'
    WHEN dias_em_estoque <= 180 THEN '91 a 180 dias (Atenção)'
    ELSE '> 180 dias (Estoque Parado/Obsoleto)'
  END AS faixa_idade,
  COUNT(id) AS pecas_estoque,
  ROUND(SUM(cost), 2) AS capital_imobilizado_custo_usd,
  ROUND(SUM(cost) * 100.0 / SUM(SUM(cost)) OVER(), 2) AS pct_capital
FROM estoque_disponivel
GROUP BY 1
ORDER BY capital_imobilizado_custo_usd DESC;

-- TOP 3 CATEGORIAS EM ESTOQUE PARADO (>90 DIAS)
SELECT
  product_category,
  COUNT(id) AS pecas_paradas,
  ROUND(SUM(cost), 2) AS capital_parado_custo_usd
FROM `bigquery-public-data.thelook_ecommerce.inventory_items`
WHERE sold_at IS NULL
  AND DATE_DIFF(CURRENT_DATE(), DATE(created_at), DAY) > 90
GROUP BY 1
ORDER BY capital_parado_custo_usd DESC
LIMIT 3;

-- FILA BRUTA DE EXCEÇÕES DE PEDIDOS (COM DISTRIBUIÇÃO POR ANO DE CRIAÇÃO)
-- Atenção: Mostra a distorção do dado sintético (anomalia de qualidade)
SELECT
  EXTRACT(YEAR FROM o.created_at) AS ano_criacao,
  o.status,
  COUNT(DISTINCT o.order_id) AS total_pedidos_excecao,
  ROUND(SUM(oi.sale_price), 2) AS valor_em_risco_usd
FROM `bigquery-public-data.thelook_ecommerce.orders` o
JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi ON o.order_id = oi.order_id
WHERE (
  (o.status = 'Processing' AND DATE_DIFF(CURRENT_DATE(), DATE(o.created_at), DAY) > 3)
  OR (o.status = 'Shipped' AND o.delivered_at IS NULL AND DATE_DIFF(CURRENT_DATE(), DATE(o.shipped_at), DAY) > 10)
)
GROUP BY 1, 2
ORDER BY ano_criacao ASC, valor_em_risco_usd DESC;

-- FILA DEPURADA PARA O BACKOFFICE (Regra Operacional Real: Janela de 60 dias)
SELECT
  o.status,
  CASE
    WHEN o.status = 'Processing' THEN 'Travado em Processamento (>3 dias)'
    ELSE 'Atraso em Transporte (>10 dias sem entrega)'
  END AS motivo_excecao,
  COUNT(DISTINCT o.order_id) AS pedidos_acionaveis,
  ROUND(SUM(oi.sale_price), 2) AS valor_em_risco_operacional_usd,
  ROUND(AVG(DATE_DIFF(CURRENT_DATE(), DATE(o.created_at), DAY)), 1) AS dias_medios_parado
FROM `bigquery-public-data.thelook_ecommerce.orders` o
JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi ON o.order_id = oi.order_id
WHERE (
  (o.status = 'Processing' AND DATE_DIFF(CURRENT_DATE(), DATE(o.created_at), DAY) BETWEEN 4 AND 60)
  OR (o.status = 'Shipped' AND o.delivered_at IS NULL AND DATE_DIFF(CURRENT_DATE(), DATE(o.shipped_at), DAY) BETWEEN 11 AND 60)
)
GROUP BY 1, 2;


-- ------------------------------------------------------------------------------
-- M4. ANÁLISE DE CANAIS DE MÍDIA, ESTÍMULO ESTATÍSTICO E RETAIL MEDIA
-- ------------------------------------------------------------------------------

-- CONVERSÃO POR CANAL (ÚLTIMOS 90 DIAS, CORTE D-7)
WITH sessoes_usuarios AS (
  SELECT
    session_id,
    traffic_source,
    MAX(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS converteu_compra
  FROM `bigquery-public-data.thelook_ecommerce.events`
  WHERE DATE(created_at) BETWEEN DATE_SUB(DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY), INTERVAL 90 DAY)
                             AND DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
  GROUP BY session_id, traffic_source
)
SELECT
  traffic_source,
  COUNT(session_id) AS total_sessoes,
  SUM(converteu_compra) AS total_compras,
  ROUND(SUM(converteu_compra) * 1.0 / COUNT(session_id), 4) AS taxa_conversao,
  -- Intervalo de Confiança de Wilson (95% -> z = 1.96)
  ROUND(
    ( (SUM(converteu_compra) + 1.96*1.96/2) / (COUNT(session_id) + 1.96*1.96)
      - 1.96 / (COUNT(session_id) + 1.96*1.96) * SQRT( (SUM(converteu_compra)*(COUNT(session_id)-SUM(converteu_compra))/COUNT(session_id)) + (1.96*1.96/4) )
    ) * 100, 2
  ) AS ic_inferior_pct,
  ROUND(
    ( (SUM(converteu_compra) + 1.96*1.96/2) / (COUNT(session_id) + 1.96*1.96)
      + 1.96 / (COUNT(session_id) + 1.96*1.96) * SQRT( (SUM(converteu_compra)*(COUNT(session_id)-SUM(converteu_compra))/COUNT(session_id)) + (1.96*1.96/4) )
    ) * 100, 2
  ) AS ic_superior_pct
FROM sessoes_usuarios
GROUP BY traffic_source
ORDER BY taxa_conversao DESC;

-- TOP 10 PRODUTOS PARA PATROCÍNIO NO RETAIL MEDIA (Margem Esperada por Visita)
WITH visitas_produto AS (
  SELECT
    CAST(SUBSTR(uri, 10) AS INT64) AS product_id,
    COUNT(DISTINCT session_id) AS total_visitas
  FROM `bigquery-public-data.thelook_ecommerce.events`
  WHERE event_type = 'product'
    AND uri LIKE '/product/%'
    AND DATE(created_at) >= DATE_SUB(DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY), INTERVAL 90 DAY)
  GROUP BY 1
),
vendas_produto AS (
  SELECT
    oi.product_id,
    p.name,
    p.category,
    p.retail_price,
    p.cost,
    (p.retail_price - p.cost) AS margem_bruta_unitaria,
    COUNT(oi.id) AS total_vendas
  FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
  JOIN `bigquery-public-data.thelook_ecommerce.products` p ON oi.product_id = p.id
  WHERE oi.status NOT IN ('Cancelled', 'Returned')
    AND DATE(oi.created_at) >= DATE_SUB(DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY), INTERVAL 90 DAY)
  GROUP BY 1, 2, 3, 4, 5
)
SELECT
  v.product_id,
  v.name AS nome_produto,
  v.category,
  ROUND(v.retail_price, 2) AS preco_venda,
  ROUND(v.margem_bruta_unitaria, 2) AS margem_unitaria_usd,
  vis.total_visitas,
  v.total_vendas,
  ROUND(SAFE_DIVIDE(v.total_vendas, vis.total_visitas), 4) AS taxa_conversao_visita,
  -- Margem esperada por visita = Margem Unitária * Conversão
  ROUND(v.margem_bruta_unitaria * SAFE_DIVIDE(v.total_vendas, vis.total_visitas), 3) AS margem_esperada_por_visita_usd
FROM vendas_produto v
JOIN visitas_produto vis ON v.product_id = vis.product_id
WHERE vis.total_visitas >= 150 -- Filtro de relevância amostral
ORDER BY margem_esperada_por_visita_usd DESC
LIMIT 10;

