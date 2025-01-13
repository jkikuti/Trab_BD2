-----------------------------------------------------------
-- Criação da Função
-----------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_info_pedido (
    p_id_pedido IN NUMBER
) RETURN VARCHAR2
IS
    v_nome_cliente  VARCHAR2(200);
    v_valor_total   NUMBER(7,2);
    v_result        VARCHAR2(400);
BEGIN
    SELECT c.nome, p.valor_total
      INTO v_nome_cliente, v_valor_total
      FROM pedido p
      JOIN cliente c ON p.id_cliente = c.id
     WHERE p.id = p_id_pedido;

    v_result := 'Cliente: ' || v_nome_cliente
                || ' - Total R$ ' || TO_CHAR(v_valor_total, '9999990.00');
    RETURN v_result;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Pedido não encontrado!';
END;
/

-----------------------------------------------------------
-- Consulta que Invoca a Função
-----------------------------------------------------------

SELECT p.id,
       fn_info_pedido(p.id) AS info
FROM pedido p
WHERE p.id <= 3;
