USE classicmodels;

CREATE OR REPLACE VIEW vw_resumo_vendas_escritorio AS
WITH
cte_offices AS (
    SELECT officeCode, city
    FROM offices
    WHERE city IN ('London', 'San Francisco')
),
cte_employees AS (
    SELECT employeeNumber, officeCode, firstName, lastName
    FROM employees
    WHERE officeCode IN (SELECT officeCode FROM cte_offices)
),
cte_customers AS (
    SELECT customerNumber, salesRepEmployeeNumber
    FROM customers
    WHERE creditLimit > 100000
      AND salesRepEmployeeNumber IS NOT NULL
),
cte_orders AS (
    SELECT DISTINCT customerNumber
    FROM orders
    WHERE orderDate >= '2004-07-01'
      AND orderDate < '2004-10-01'
),
cte_payments AS (
    SELECT customerNumber, SUM(amount) AS total_recebido
    FROM payments
    WHERE paymentDate >= '2004-07-01'
      AND paymentDate < '2004-10-01'
    GROUP BY customerNumber
)
SELECT
    e.employeeNumber,
    CONCAT(e.firstName, ' ', e.lastName) AS nome_empregado,
    COUNT(DISTINCT c.customerNumber) AS qtd_clientes,
    COALESCE(SUM(p.total_recebido), 0.00) AS total_recebido
FROM cte_employees e
INNER JOIN cte_customers c ON e.employeeNumber = c.salesRepEmployeeNumber
INNER JOIN cte_orders o ON c.customerNumber = o.customerNumber
LEFT JOIN cte_payments p ON c.customerNumber = p.customerNumber
GROUP BY e.employeeNumber, e.firstName, e.lastName
ORDER BY total_recebido DESC
LIMIT 5;

SELECT * FROM vw_resumo_vendas_escritorio;

USE sakila;

DROP PROCEDURE IF EXISTS sp_total_estoque_loja_categoria;

DELIMITER //
CREATE PROCEDURE sp_total_estoque_loja_categoria(
    IN p_store_id INT,
    IN p_category_name VARCHAR(25),
    OUT p_mensagem VARCHAR(255)
)
BEGIN
    DECLARE v_quantidade INT DEFAULT 0;

    SELECT COUNT(i.inventory_id)
    INTO v_quantidade
    FROM inventory i
    INNER JOIN film_category fc ON i.film_id = fc.film_id
    INNER JOIN category c ON fc.category_id = c.category_id
    WHERE i.store_id = p_store_id
      AND c.name = p_category_name;

    SET p_mensagem = CONCAT(
        'A loja: ', p_store_id,
        ' para a categoria: ', p_category_name,
        ' tem o total de : ', v_quantidade,
        ' no estoque'
    );
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_inserir_copias_estoque;

DELIMITER //
CREATE PROCEDURE sp_inserir_copias_estoque(OUT p_mensagem VARCHAR(255))
BEGIN
    DECLARE v_film_id INT DEFAULT NULL;
    DECLARE v_film_title VARCHAR(255) DEFAULT NULL;
    DECLARE v_num_chamada INT DEFAULT 25;
    DECLARE v_final_matricula INT DEFAULT 123;
    DECLARE v_num_copias INT;
    DECLARE v_store_id INT;
    DECLARE v_contador INT DEFAULT 0;

    IF v_num_chamada < 10 OR v_num_chamada > 20 THEN
        SET v_num_copias = MOD(v_num_chamada, 11) + 10;
    ELSE
        SET v_num_copias = v_num_chamada;
    END IF;

    IF MOD(v_final_matricula, 2) <> 0 THEN
        SET v_store_id = 1;
    ELSE
        SET v_store_id = 2;
    END IF;

    SELECT f.film_id, f.title
    INTO v_film_id, v_film_title
    FROM film f
    LEFT JOIN inventory i ON f.film_id = i.film_id
    WHERE i.inventory_id IS NULL
      AND f.film_id > v_final_matricula
    ORDER BY f.film_id
    LIMIT 1;

    IF v_film_id IS NOT NULL THEN
        REPEAT
            INSERT INTO inventory (film_id, store_id, last_update)
            VALUES (v_film_id, v_store_id, CURRENT_TIMESTAMP());
            SET v_contador = v_contador + 1;
        UNTIL v_contador >= v_num_copias
        END REPEAT;

        SET p_mensagem = CONCAT(
            'O filme: "', v_film_title,
            '" agora tem ', v_num_copias,
            ' copias no estoque.'
        );
    ELSE
        SET p_mensagem = 'Nenhum filme elegível encontrado.';
    END IF;
END //
DELIMITER ;

USE world;

DROP TABLE IF EXISTS paises_analise_densidade;

CREATE TABLE paises_analise_densidade AS
SELECT
    c.Name AS nome_pais,
    c.Population / NULLIF(c.SurfaceArea, 0) AS densidade_demografica,
    CASE
        WHEN c.Population / NULLIF(c.SurfaceArea, 0) > 100 THEN 'Pais Populoso'
        ELSE 'Dentro do Padrão'
    END AS analise
FROM country c
INNER JOIN countrylanguage cl ON c.Code = cl.CountryCode
WHERE c.GovernmentForm = 'Republic'
  AND cl.Language = 'English';

DROP PROCEDURE IF EXISTS sp_rotina_estudos_tecnicos;

DELIMITER //
CREATE PROCEDURE sp_rotina_estudos_tecnicos(IN p_nome_aluno VARCHAR(100))
BEGIN
    SELECT p_nome_aluno AS aluno, 1 AS passo, 'Revisar o diagrama ER e o esquema do banco' AS descricao
    UNION ALL
    SELECT p_nome_aluno, 2, 'Elaborar as rotinas SQL (CTEs, Views e Procedures)'
    UNION ALL
    SELECT p_nome_aluno, 3, 'Executar os testes no MySQL Workbench'
    UNION ALL
    SELECT p_nome_aluno, 4, 'Analisar integridade dos dados e desempenho'
    UNION ALL
    SELECT p_nome_aluno, 5, 'Realizar commit final e submeter a atividade';
END //
DELIMITER ;
