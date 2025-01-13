----------------------------------------
-- Script de Criação da Visão Computada
----------------------------------------

CREATE OR REPLACE VIEW vw_resumo_pedidos AS
SELECT 
    p.id               AS pedido_id,
    c.nome             AS nome_cliente,
    p.data_pedido      AS data_pedido,
    p.valor_total      AS valor_total,
    (SELECT NVL(SUM(ptaf.pedido_quantidade), 0)
       FROM pedido_tem_action_figure ptaf
      WHERE ptaf.id_pedido = p.id
    ) AS total_itens
FROM pedido p
JOIN cliente c
    ON p.id_cliente = c.id;

----------------------------------------
-- Consulta Usando a Visão Computada
----------------------------------------

SELECT *
FROM vw_resumo_pedidos
ORDER BY pedido_id;

----------------------------------------
-- Atualização Afetando o Conteúdo
----------------------------------------

-- Aumentar a quantidade de um item no pedido 1
UPDATE pedido_tem_action_figure
   SET pedido_quantidade = 10
 WHERE id_pedido = 1
   AND id_action_figure = 5;

-- Consultar novamente a view

--------------------------------------------
-- Script de Criação da Visão Materializada
---------------------------------------------

CREATE MATERIALIZED VIEW mv_pedido_por_dia
REFRESH COMPLETE ON DEMAND
AS
SELECT
    TRUNC(p.data_pedido) AS dia,
    COUNT(*)             AS qtde_pedidos,
    SUM(p.valor_total)   AS valor_total_dia
FROM pedido p
GROUP BY TRUNC(p.data_pedido);


------------------------------------------
-- Consulta Usando a Visão Materializada
------------------------------------------

SELECT *
FROM mv_pedido_por_dia
ORDER BY dia;

----------------------------------------
-- Atualização Afetando o Conteúdo
----------------------------------------

-- Aumentar a quantidade de um item no pedido 1
UPDATE pedido_tem_action_figure
   SET pedido_quantidade = 5
 WHERE id_pedido = 1
   AND id_action_figure = 5;

-- Consultar novamente a view

EXEC DBMS_MVIEW.REFRESH('MV_PEDIDO_POR_DIA', 'C');
