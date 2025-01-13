-------------------------------------------------------------------------
-- Consulta não recursiva com WITH
-------------------------------------------------------------------------

WITH fabricantes_populares AS (
    SELECT f.id, f.nome_fabricante, COUNT(a.id) AS qtd_af
    FROM fabricante f
    JOIN action_figure a ON a.id_fabricante = f.id
    GROUP BY f.id, f.nome_fabricante
    HAVING COUNT(a.id) > 3
)
SELECT fp.nome_fabricante, a.personagem, a.universo
FROM fabricantes_populares fp
JOIN action_figure a ON a.id_fabricante = fp.id
ORDER BY fp.nome_fabricante, a.personagem;

-------------------------------------------------------------------------
-- Consulta recursiva usando WITH
-------------------------------------------------------------------------

WITH local_hierarchy (id, entity, nome_local, parent_id) AS (
    ---------------------------------------------------------------------
    -- Nível 0: ESTADOS
    ---------------------------------------------------------------------
    SELECT 
        e.id                     AS id,
        'ESTADO'                AS entity,
        e.sigla_estado          AS nome_local,
        CAST(NULL AS NUMBER)    AS parent_id
    FROM estado e

    UNION ALL

    ---------------------------------------------------------------------
    -- Nível 1: CIDADES que pertencem ao ESTADO
    ---------------------------------------------------------------------
    SELECT 
        c.id                    AS id,
        'CIDADE'               AS entity,
        c.nome                  AS nome_local,
        c.id_estado            AS parent_id
    FROM local_hierarchy lh
    JOIN cidade c ON c.id_estado = lh.id
    WHERE lh.entity = 'ESTADO'

    UNION ALL

    ---------------------------------------------------------------------
    -- Nível 2: BAIRROS que pertencem à CIDADE
    ---------------------------------------------------------------------
    SELECT
        b.id                    AS id,
        'BAIRRO'               AS entity,
        b.nome                  AS nome_local,
        b.id_cidade            AS parent_id
    FROM local_hierarchy lh
    JOIN bairro b ON b.id_cidade = lh.id
    WHERE lh.entity = 'CIDADE'

    UNION ALL

    ---------------------------------------------------------------------
    -- Nível 2 (alternativo): LOGRADOUROS que pertencem à CIDADE
    ---------------------------------------------------------------------
    SELECT
        lgr.id                 AS id,
        'LOGRADOURO'          AS entity,
        lgr.nome               AS nome_local,
        lgr.id_cidade          AS parent_id
    FROM local_hierarchy lh
    JOIN logradouro lgr ON lgr.id_cidade = lh.id
    WHERE lh.entity = 'CIDADE'
)
SELECT *
FROM local_hierarchy
ORDER BY entity, id;

