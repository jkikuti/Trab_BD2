------------------------------------------------------------------------------
-- 1) Tabela CLIENTE
------------------------------------------------------------------------------
CREATE TABLE cliente (
    id           NUMBER GENERATED ALWAYS AS IDENTITY,
    cpf          VARCHAR2(14)  NOT NULL,
    nome         VARCHAR2(255),
    email        VARCHAR2(255) NOT NULL,
    senha        VARCHAR2(255) DEFAULT 'senha_temporaria' NOT NULL,

    CONSTRAINT pk_cliente PRIMARY KEY (id),
    CONSTRAINT uq_cliente_cpf UNIQUE (cpf),
    CONSTRAINT uq_cliente_email UNIQUE (email)
);

------------------------------------------------------------------------------
-- 2) Tabela ESTADO
------------------------------------------------------------------------------
CREATE TABLE estado (
    id            NUMBER GENERATED ALWAYS AS IDENTITY,
    sigla_estado  VARCHAR2(2) NOT NULL,

    CONSTRAINT pk_estado PRIMARY KEY (id),
    CONSTRAINT uq_estado_sigla UNIQUE (sigla_estado)
);

------------------------------------------------------------------------------
-- 3) Tabela CIDADE (entidade fraca em relação a ESTADO)
------------------------------------------------------------------------------
CREATE TABLE cidade (
    id         NUMBER GENERATED ALWAYS AS IDENTITY,
    nome       VARCHAR2(255) NOT NULL,
    id_estado  NUMBER NOT NULL,

    CONSTRAINT pk_cidade PRIMARY KEY (id),
    CONSTRAINT fk_estado 
        FOREIGN KEY (id_estado)
        REFERENCES estado (id)
        ON DELETE CASCADE
);

------------------------------------------------------------------------------
-- 4) Tabela BAIRRO (entidade fraca em relação a CIDADE)
------------------------------------------------------------------------------
CREATE TABLE bairro (
    id         NUMBER GENERATED ALWAYS AS IDENTITY,
    nome       VARCHAR2(255) NOT NULL,
    id_cidade  NUMBER NOT NULL,

    CONSTRAINT pk_bairro PRIMARY KEY (id),
    CONSTRAINT fk_cidade
        FOREIGN KEY (id_cidade)
        REFERENCES cidade (id)
        ON DELETE CASCADE
);

------------------------------------------------------------------------------
-- 5) Tabela LOGRADOURO (entidade fraca em relação a CIDADE)
------------------------------------------------------------------------------
CREATE TABLE logradouro (
    id         NUMBER GENERATED ALWAYS AS IDENTITY,
    nome       VARCHAR2(255) NOT NULL,
    tipo       VARCHAR2(255) NOT NULL,
    id_cidade  NUMBER NOT NULL,

    CONSTRAINT pk_logradouro PRIMARY KEY (id),
    CONSTRAINT fk_cidade_logradouro
        FOREIGN KEY (id_cidade)
        REFERENCES cidade (id)
        ON DELETE CASCADE
);

------------------------------------------------------------------------------
-- 6) Tabela CEP_END (entidade fraca em relação a LOGRADOURO e BAIRRO)
------------------------------------------------------------------------------
CREATE TABLE cep_end (
    id            NUMBER GENERATED ALWAYS AS IDENTITY,
    cep           VARCHAR2(9) NOT NULL,
    id_logradouro NUMBER NOT NULL,
    id_bairro     NUMBER NOT NULL,

    CONSTRAINT pk_cep_end PRIMARY KEY (id),
    CONSTRAINT uq_cep UNIQUE (cep),
    CONSTRAINT fk_logradouro
        FOREIGN KEY (id_logradouro)
        REFERENCES logradouro (id)
        ON DELETE CASCADE,
    CONSTRAINT fk_bairro
        FOREIGN KEY (id_bairro)
        REFERENCES bairro (id)
        ON DELETE CASCADE
);

------------------------------------------------------------------------------
-- 7) Tabela ENDERECO (entidade fraca em relação a CEP_END)
------------------------------------------------------------------------------
CREATE TABLE endereco (
    id      NUMBER GENERATED ALWAYS AS IDENTITY,
    numero  NUMBER NOT NULL,
    complemento VARCHAR2(255),
    id_cep  NUMBER NOT NULL,

    CONSTRAINT pk_endereco PRIMARY KEY (id),
    CONSTRAINT fk_cep
        FOREIGN KEY (id_cep)
        REFERENCES cep_end (id)
        ON DELETE CASCADE
);

------------------------------------------------------------------------------
-- 8) Tabela CLIENTE_ENDERECO (relacionamento N:N entre CLIENTE e ENDERECO)
------------------------------------------------------------------------------
CREATE TABLE cliente_endereco (
    id_cliente   NUMBER,
    id_endereco  NUMBER,

    CONSTRAINT pk_cliente_endereco PRIMARY KEY (id_cliente, id_endereco),
    CONSTRAINT fk_id_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES cliente (id)
        ON DELETE CASCADE,
    CONSTRAINT fk_id_endereco
        FOREIGN KEY (id_endereco)
        REFERENCES endereco (id)
        ON DELETE CASCADE
);

------------------------------------------------------------------------------
-- 9) Tabela FABRICANTE
------------------------------------------------------------------------------
CREATE TABLE fabricante (
    id               NUMBER GENERATED ALWAYS AS IDENTITY,
    nome_fabricante  VARCHAR2(255) NOT NULL,

    CONSTRAINT pk_fabricante PRIMARY KEY (id),
    CONSTRAINT uq_fabricante_nome UNIQUE (nome_fabricante)
);

------------------------------------------------------------------------------
-- 10) Tabela ACTION_FIGURE
------------------------------------------------------------------------------
CREATE TABLE action_figure (
    id            NUMBER GENERATED ALWAYS AS IDENTITY,
    personagem    VARCHAR2(255),
    universo      VARCHAR2(255),
    tamanho       NUMBER,
    preco         NUMBER(7,2),
    descricao     CLOB,                 -- substituindo TEXT por CLOB
    categoria     VARCHAR2(255),
    estoque       NUMBER,
    id_fabricante NUMBER NOT NULL,

    CONSTRAINT pk_action_figure PRIMARY KEY (id),
    CONSTRAINT fk_fabricante
        FOREIGN KEY (id_fabricante)
        REFERENCES fabricante (id)
        ON DELETE CASCADE
);

------------------------------------------------------------------------------
-- 11) Tabela PEDIDO
------------------------------------------------------------------------------
CREATE TABLE pedido (
    id          NUMBER GENERATED ALWAYS AS IDENTITY,
    valor_total NUMBER(7,2),
    data_pedido TIMESTAMP,
    id_cliente  NUMBER,

    CONSTRAINT pk_pedido PRIMARY KEY (id),
    CONSTRAINT fk_cliente_pedido
        FOREIGN KEY (id_cliente)
        REFERENCES cliente (id)
        ON DELETE CASCADE
);

------------------------------------------------------------------------------
-- 12) Tabela PEDIDO_TEM_ACTION_FIGURE (relacionamento N:N entre PEDIDO e ACTION_FIGURE)
--     Subtotal é coluna derivada (exemplo de coluna computada no Oracle).
------------------------------------------------------------------------------
CREATE TABLE pedido_tem_action_figure (
    id_pedido         NUMBER,
    id_action_figure  NUMBER,
    pedido_quantidade NUMBER,
    valor_unitario    NUMBER(7,2),
    -- Em Oracle 12c+ podemos criar colunas computadas (virtual ou stored).
    subtotal          NUMBER(7,2) GENERATED ALWAYS AS 
                      (pedido_quantidade * valor_unitario) VIRTUAL,

    CONSTRAINT pk_pedido_tem_action_figure 
        PRIMARY KEY (id_pedido, id_action_figure),
    CONSTRAINT fk_id_pedido
        FOREIGN KEY (id_pedido)
        REFERENCES pedido (id)
        ON DELETE CASCADE,
    CONSTRAINT fk_id_action_figure
        FOREIGN KEY (id_action_figure)
        REFERENCES action_figure (id)
        ON DELETE CASCADE
);

------------------------------------------------------------------------------
-- 13) Tabela MATERIAL
------------------------------------------------------------------------------
CREATE TABLE material (
    id            NUMBER GENERATED ALWAYS AS IDENTITY,
    tipo_material VARCHAR2(255),

    CONSTRAINT pk_material PRIMARY KEY (id),
    CONSTRAINT uq_material_tipo UNIQUE (tipo_material)
);

------------------------------------------------------------------------------
-- 14) Tabela ACTION_FIGURE_MATERIAL (relacionamento N:N entre ACTION_FIGURE e MATERIAL)
------------------------------------------------------------------------------
CREATE TABLE action_figure_material (
    id_action_figure NUMBER,
    id_material      NUMBER,

    CONSTRAINT pk_action_figure_material 
        PRIMARY KEY (id_action_figure, id_material),
    CONSTRAINT fk_mat_id_action_figure
        FOREIGN KEY (id_action_figure)
        REFERENCES action_figure (id)
        ON DELETE CASCADE,
    CONSTRAINT fk_mat_id_material
        FOREIGN KEY (id_material)
        REFERENCES material (id)
        ON DELETE CASCADE
);

------------------------------------------------------------------------------
-- 15) Tabela IMAGEM (associada a ACTION_FIGURE)
------------------------------------------------------------------------------
CREATE TABLE imagem (
    id               NUMBER GENERATED ALWAYS AS IDENTITY,
    imagem_url       VARCHAR2(255),
    id_action_figure NUMBER,

    CONSTRAINT pk_imagem PRIMARY KEY (id),
    CONSTRAINT fk_img_id_action_figure
        FOREIGN KEY (id_action_figure)
        REFERENCES action_figure (id)
        ON DELETE CASCADE
);