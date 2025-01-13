----------------------------------------------------------------
-- Trigger de Log (DML) – Exemplo de Atualização Automática
----------------------------------------------------------------

----------------------------------------------------------------
-- Criar Tabela de Log
----------------------------------------------------------------

CREATE TABLE pedido_log (
    id_log       NUMBER GENERATED ALWAYS AS IDENTITY,
    id_pedido    NUMBER,
    data_hora    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valor_antigo NUMBER(7,2),
    valor_novo   NUMBER(7,2),

    CONSTRAINT pk_pedido_log PRIMARY KEY (id_log)
);

----------------------------------------------------------------
-- Criar Trigger
----------------------------------------------------------------

CREATE OR REPLACE TRIGGER trg_log_pedido
BEFORE UPDATE OF valor_total ON pedido
FOR EACH ROW
WHEN (OLD.valor_total IS NOT NULL)  -- evita logs de inserts
BEGIN
    INSERT INTO pedido_log (id_pedido, valor_antigo, valor_novo)
    VALUES (:OLD.id, :OLD.valor_total, :NEW.valor_total);
END;
/

----------------------------------------------------------------
-- Testando
-- Atualiza o valor de um pedido
----------------------------------------------------------------

UPDATE pedido
   SET valor_total = valor_total + 50
 WHERE id = 1;

SELECT * FROM pedido_log
ORDER BY id_log DESC;

----------------------------------------------------------------
-- Restrição Complexa via Trigger (lançando exceção)
----------------------------------------------------------------

----------------------------------------------------------------
-- Criar Trigger de Restrição
----------------------------------------------------------------

CREATE OR REPLACE TRIGGER trg_limite_valor_pedido
BEFORE INSERT OR UPDATE OF valor_total ON pedido
FOR EACH ROW
BEGIN
    IF :NEW.valor_total > 5000 THEN
        RAISE_APPLICATION_ERROR(
            -20001,
            'Valor máximo do pedido não pode exceder R$ 5.000,00.'
        );
    END IF;
END;
/

----------------------------------------------------------------
-- Teste do Trigger
-- Tenta inserir pedido acima de 5000
----------------------------------------------------------------

--ex1
INSERT INTO pedido (valor_total, data_pedido, id_cliente)
VALUES (6000, SYSDATE, 1);

--ex2
UPDATE pedido
   SET valor_total = 5500
 WHERE id = 1;
