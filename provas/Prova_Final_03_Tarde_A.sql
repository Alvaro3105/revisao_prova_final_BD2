USE classicmodels;

CREATE OR REPLACE VIEW view_total_recebido_produto AS
WITH
cte_escritorios AS (
    SELECT officeCode
    FROM offices
    WHERE city IN ('London', 'Tokyo')
),
cte_empregados AS (
    SELECT employeeNumber, officeCode
    FROM employees
    WHERE officeCode IN (SELECT officeCode FROM cte_escritorios)
),
cte_clientes AS (
    SELECT customerNumber, salesRepEmployeeNumber
    FROM customers
    WHERE creditLimit > 100000
      AND salesRepEmployeeNumber IS NOT NULL
),
cte_pedidos AS (
    SELECT orderNumber, customerNumber
    FROM orders
    WHERE orderDate >= '2003-04-01'
      AND orderDate < '2003-07-01'
),
cte_detalhes AS (
    SELECT orderNumber, productCode, quantityOrdered, priceEach
    FROM orderdetails
)
SELECT
    d.productCode,
    ROUND(SUM(d.quantityOrdered * d.priceEach), 2) AS valor_total_recebido
FROM cte_escritorios o
INNER JOIN cte_empregados e ON o.officeCode = e.officeCode
INNER JOIN cte_clientes c ON e.employeeNumber = c.salesRepEmployeeNumber
INNER JOIN cte_pedidos p ON c.customerNumber = p.customerNumber
INNER JOIN cte_detalhes d ON p.orderNumber = d.orderNumber
GROUP BY d.productCode
ORDER BY valor_total_recebido DESC
LIMIT 5;

SELECT * FROM view_total_recebido_produto;

USE sakila;

DROP PROCEDURE IF EXISTS proc_filme_mais_alugado_loja;

DELIMITER $$
CREATE PROCEDURE proc_filme_mais_alugado_loja(IN p_loja_id INT)
BEGIN
    SELECT CONCAT(
        'O filme mais alugado é: "',
        f.title,
        '" que do gênero: "',
        c.name,
        '"'
    ) AS Mensagem
    FROM inventory i
    INNER JOIN rental r ON i.inventory_id = r.inventory_id
    INNER JOIN film f ON i.film_id = f.film_id
    INNER JOIN film_category fc ON f.film_id = fc.film_id
    INNER JOIN category c ON fc.category_id = c.category_id
    WHERE i.store_id = p_loja_id
    GROUP BY f.film_id, f.title, c.category_id, c.name
    ORDER BY COUNT(r.rental_id) DESC, f.title
    LIMIT 1;
END $$
DELIMITER ;

USE classicmodels;

DROP PROCEDURE IF EXISTS proc_novo_pedido_cliente;

DELIMITER $$
CREATE PROCEDURE proc_novo_pedido_cliente(
    IN p_customerNumber INT,
    IN p_salesRepEmployeeNumber INT,
    IN p_creditLimit DECIMAL(10,2)
)
rotulo_principal: BEGIN
    DECLARE v_existe_cliente INT DEFAULT 0;
    DECLARE v_existe_vendedor INT DEFAULT 0;
    DECLARE v_vendedor_atual INT DEFAULT NULL;
    DECLARE v_novo_orderNumber INT;
    DECLARE v_produto_codigo VARCHAR(15);
    DECLARE v_produto_msrp DECIMAL(10,2);
    DECLARE v_produto_estoque INT;
    DECLARE v_matricula INT DEFAULT 86;

    SELECT COUNT(*)
    INTO v_existe_cliente
    FROM customers
    WHERE customerNumber = p_customerNumber;

    IF v_existe_cliente = 0 THEN
        SELECT 'O processo não foi concluído com sucesso' AS Mensagem;
        LEAVE rotulo_principal;
    END IF;

    SELECT salesRepEmployeeNumber
    INTO v_vendedor_atual
    FROM customers
    WHERE customerNumber = p_customerNumber;

    IF v_vendedor_atual IS NOT NULL THEN
        SELECT 'O processo não foi concluído com sucesso' AS Mensagem;
        LEAVE rotulo_principal;
    END IF;

    SELECT COUNT(*)
    INTO v_existe_vendedor
    FROM employees
    WHERE employeeNumber = p_salesRepEmployeeNumber;

    IF v_existe_vendedor = 0 THEN
        SELECT 'O processo não foi concluído com sucesso' AS Mensagem;
        LEAVE rotulo_principal;
    END IF;

    SELECT productCode, MSRP, quantityInStock
    INTO v_produto_codigo, v_produto_msrp, v_produto_estoque
    FROM products
    ORDER BY quantityInStock DESC, productCode
    LIMIT 1;

    IF v_produto_estoque < v_matricula THEN
        SELECT 'O processo não foi concluído com sucesso' AS Mensagem;
        LEAVE rotulo_principal;
    END IF;

    START TRANSACTION;

    UPDATE customers
    SET salesRepEmployeeNumber = p_salesRepEmployeeNumber,
        creditLimit = p_creditLimit
    WHERE customerNumber = p_customerNumber;

    SELECT COALESCE(MAX(orderNumber), 0) + 1
    INTO v_novo_orderNumber
    FROM orders;

    INSERT INTO orders (
        orderNumber,
        orderDate,
        requiredDate,
        shippedDate,
        status,
        customerNumber
    )
    VALUES (
        v_novo_orderNumber,
        CURRENT_DATE(),
        CURRENT_DATE() + INTERVAL 7 DAY,
        CURRENT_DATE() + INTERVAL 5 DAY,
        'Shipped',
        p_customerNumber
    );

    INSERT INTO orderdetails (
        orderNumber,
        productCode,
        quantityOrdered,
        priceEach,
        orderLineNumber
    )
    VALUES (
        v_novo_orderNumber,
        v_produto_codigo,
        v_matricula,
        v_produto_msrp * 0.20,
        1
    );

    UPDATE products
    SET quantityInStock = quantityInStock - v_matricula
    WHERE productCode = v_produto_codigo;

    COMMIT;

    SELECT 'Processo concluído com sucesso!' AS Mensagem;
END rotulo_principal $$
DELIMITER ;

USE world;

DROP TABLE IF EXISTS paises_servocroatas;

CREATE TABLE paises_servocroatas AS
SELECT
    c.Name AS nome_pais,
    c.Population / NULLIF(c.SurfaceArea, 0) AS densidade,
    CASE
        WHEN c.Population / NULLIF(c.SurfaceArea, 0) > 100 THEN 'Pais Populoso'
        ELSE 'Dentro do Padrão'
    END AS analise
FROM country c
INNER JOIN countrylanguage cl ON c.Code = cl.CountryCode
WHERE c.Region = 'Southern Europe'
  AND cl.Language = 'Serbo-Croatian';

DROP PROCEDURE IF EXISTS proc_rotina_diaria;

DELIMITER $$
CREATE PROCEDURE proc_rotina_diaria(IN p_nome_pessoa VARCHAR(50))
BEGIN
    SELECT p_nome_pessoa AS pessoa, 1 AS passo, 'Acordar cedo, tomar um café reforçado e ir para o trabalho' AS atividade
    UNION ALL
    SELECT p_nome_pessoa, 2, 'Trabalhar focadíssimo durante a manhã e a tarde'
    UNION ALL
    SELECT p_nome_pessoa, 3, 'Sair do trabalho e ir para a escola/faculdade'
    UNION ALL
    SELECT p_nome_pessoa, 4, 'Assistir às aulas, fazer anotações e realizar os trabalhos em grupo'
    UNION ALL
    SELECT p_nome_pessoa, 5, 'Voltar para casa, jantar, dar uma última revisada na matéria e dormir';
END $$
DELIMITER ;
