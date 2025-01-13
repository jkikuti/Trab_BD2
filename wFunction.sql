-----------------------------------------------------------
-- Ranking dos pedidos por valor_total
-----------------------------------------------------------

SELECT
    p.id,
    p.valor_total,
    RANK() OVER (ORDER BY p.valor_total DESC) AS rank_valor
FROM pedido p
ORDER BY p.valor_total DESC;

-----------------------------------------------------------
-- Soma acumulada (running total) por cliente
-----------------------------------------------------------

SELECT
    c.nome AS cliente,
    p.id   AS pedido,
    p.valor_total,
    SUM(p.valor_total) 
      OVER (PARTITION BY c.id ORDER BY p.data_pedido) AS soma_acumulada
FROM pedido p
JOIN cliente c ON p.id_cliente = c.id
ORDER BY c.nome, p.data_pedido;
