CREATE OR REPLACE PROCEDURE pr_carga_loja(
    p_escala IN NUMBER
) IS
    /* 
       Observações: 
       - p_escala define o “fator de escala” na geração de dados.
       - DBMS_RANDOM é usado para gerar valores pseudoaleatórios.
       - Ajuste os loops conforme a quantidade desejada por tabela.
    */

    v_count         NUMBER := 0;      
    v_random_name   VARCHAR2(200);
    v_random_email  VARCHAR2(200);
    v_random_cpf    VARCHAR2(14);
    v_random_int    NUMBER;
    v_sufixo        VARCHAR2(5);

    v_dominios      VARCHAR2(100) := 'gmail.com|yahoo.com|hotmail.com';
    v_dominio_array DBMS_UTILITY.lname_array;  -- array auxiliar para split do domínio
    v_partcount     BINARY_INTEGER := 0;

    -----------------------------------------------------------------------
    -- Para o item 6 (pedido_tem_action_figure), definimos um tipo array:
    -----------------------------------------------------------------------
    TYPE tAFIDs IS TABLE OF NUMBER INDEX BY PLS_INTEGER; 
    vUsedAFIDs   tAFIDs;     -- array para action_figures já usados no pedido
    vLoopCount   NUMBER;
    vRandAF      NUMBER;
    vNumItens    NUMBER;

BEGIN
    ----------------------------------------------------------------------------
    -- Inicializa gerador de números aleatórios
    ----------------------------------------------------------------------------
    DBMS_RANDOM.INITIALIZE(TRUNC(DBMS_UTILITY.GET_TIME));

    ----------------------------------------------------------------------------
    -- 1) Inserir ESTADOS (exemplo: 5 * p_escala)
    ----------------------------------------------------------------------------
    FOR i IN 1 .. (5 * p_escala) LOOP
        -- Gerar “sigla” aleatória (2 letras maiúsculas)
        v_sufixo := DBMS_RANDOM.STRING('U', 2);  -- 2 letras maiúsculas
        INSERT INTO estado (sigla_estado)
        VALUES (v_sufixo);
    END LOOP;

    ----------------------------------------------------------------------------
    -- 2) Inserir CLIENTES (exemplo: 10 * p_escala)
    ----------------------------------------------------------------------------
    -- nomes, e-mails e cpfs semi-aleatórios
    ----------------------------------------------------------------------------

    -- Dividir a string de domínios em array
    v_partcount := 1;
    v_dominio_array(v_partcount) := REGEXP_SUBSTR(v_dominios, '[^|]+', 1, v_partcount);

    WHILE v_dominio_array(v_partcount) IS NOT NULL LOOP
        v_partcount := v_partcount + 1;
        v_dominio_array(v_partcount) := REGEXP_SUBSTR(v_dominios, '[^|]+', 1, v_partcount);
    END LOOP;

    FOR i IN 1 .. (10 * p_escala) LOOP
        -- Nome aleatório
        v_random_name := DBMS_RANDOM.STRING('A', TRUNC(DBMS_RANDOM.VALUE(5, 10)));

        -- CPF aleatório (11 dígitos)
        v_random_cpf := '';
        FOR j IN 1 .. 11 LOOP
            v_random_cpf := v_random_cpf || TRUNC(DBMS_RANDOM.VALUE(0,10));
        END LOOP;

        -- Montar e-mail
        v_sufixo       := TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(100,999))); -- 3 dígitos
        v_random_email :=   LOWER(v_random_name)
                          || v_sufixo
                          || '@'
                          || v_dominio_array(TRUNC(DBMS_RANDOM.VALUE(1, v_partcount)));

        INSERT INTO cliente (cpf, nome, email, senha)
        VALUES (
            v_random_cpf,
            INITCAP(v_random_name), 
            v_random_email,
            'abc123'
        );
    END LOOP;

    ----------------------------------------------------------------------------
    -- 3) Inserir FABRICANTES (exemplo: 3 * p_escala)
    ----------------------------------------------------------------------------
    FOR i IN 1 .. (3 * p_escala) LOOP
        v_random_name := DBMS_RANDOM.STRING('A', TRUNC(DBMS_RANDOM.VALUE(5, 10)));
        INSERT INTO fabricante (nome_fabricante)
        VALUES (INITCAP(v_random_name));
    END LOOP;

    ----------------------------------------------------------------------------
    -- 4) Inserir ACTION_FIGURE (exemplo: 8 * p_escala)
    ----------------------------------------------------------------------------
    FOR i IN 1 .. (8 * p_escala) LOOP
        v_random_name := DBMS_RANDOM.STRING('A', TRUNC(DBMS_RANDOM.VALUE(5, 10)));

        -- Pegar um id_fabricante qualquer existente
        SELECT id 
          INTO v_random_int
          FROM (SELECT id FROM fabricante ORDER BY DBMS_RANDOM.VALUE)
         WHERE ROWNUM = 1;

        INSERT INTO action_figure (
            personagem, universo, tamanho, preco, descricao, categoria, estoque, id_fabricante
        ) VALUES (
            INITCAP(v_random_name),
            'Universo ' || TO_CHAR(i),
            TRUNC(DBMS_RANDOM.VALUE(10, 30)),    -- tamanho (10 a 30 cm)
            ROUND(DBMS_RANDOM.VALUE(50, 500),2), -- preco (R$ 50 a 500)
            'Descrição genérica ' || i,
            'Colecionável',
            TRUNC(DBMS_RANDOM.VALUE(0,100)),     -- estoque
            v_random_int
        );
    END LOOP;

    ----------------------------------------------------------------------------
    -- 5) Inserir PEDIDOS (exemplo: 5 * p_escala)
    ----------------------------------------------------------------------------
    FOR i IN 1 .. (5 * p_escala) LOOP
        SELECT id 
          INTO v_random_int
          FROM (SELECT id FROM cliente ORDER BY DBMS_RANDOM.VALUE)
         WHERE ROWNUM = 1;

        INSERT INTO pedido (valor_total, data_pedido, id_cliente)
        VALUES (
            0,
            SYSDATE - TRUNC(DBMS_RANDOM.VALUE(0,30)),  -- data até 30 dias atrás
            v_random_int
        );
    END LOOP;

    ----------------------------------------------------------------------------
    -- 6) Inserir itens de PEDIDO (PEDIDO_TEM_ACTION_FIGURE) - EVITANDO DUPLICADOS
    ----------------------------------------------------------------------------
    FOR ped IN (SELECT id FROM pedido) LOOP
        vNumItens := TRUNC(DBMS_RANDOM.VALUE(2,6));  -- de 2 a 5 itens
        vUsedAFIDs.DELETE;  -- limpa o array para cada pedido
        vLoopCount := 1;

        WHILE vLoopCount <= vNumItens LOOP
            -- Sorteia um action_figure
            SELECT id
              INTO vRandAF
              FROM (SELECT id FROM action_figure ORDER BY DBMS_RANDOM.VALUE)
             WHERE ROWNUM = 1;

            -- Se já escolhemos esse AF p/ este pedido, pula e tenta outro
            IF vUsedAFIDs.EXISTS(vRandAF) THEN
                CONTINUE;  -- volta ao WHILE, sorteando de novo
            END IF;

            -- Insere o item
            INSERT INTO pedido_tem_action_figure (
                id_pedido, id_action_figure, pedido_quantidade, valor_unitario
            ) VALUES (
                ped.id,
                vRandAF,
                TRUNC(DBMS_RANDOM.VALUE(1,6)),     -- qtd 1..5
                ROUND(DBMS_RANDOM.VALUE(50,500),2) -- valor_unit
            );

            -- Marca AF como usado
            vUsedAFIDs(vRandAF) := 1;
            vLoopCount := vLoopCount + 1;
        END LOOP; -- WHILE
    END LOOP; -- FOR

    ----------------------------------------------------------------------------
    -- 7) Atualizar valor_total do PEDIDO
    ----------------------------------------------------------------------------
    UPDATE pedido p
       SET p.valor_total = (
           SELECT NVL(SUM(subtotal),0)
             FROM pedido_tem_action_figure
            WHERE id_pedido = p.id
       );

    ----------------------------------------------------------------------------
    -- Confirma transação e finaliza
    ----------------------------------------------------------------------------
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Carga realizada com sucesso para fator de escala = ' || p_escala);

    DBMS_RANDOM.TERMINATE;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao realizar a carga: ' || SQLERRM);
        ROLLBACK;
END pr_carga_loja;
/
