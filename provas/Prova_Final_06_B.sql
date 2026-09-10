USE classicmodels;

CREATE OR REPLACE VIEW vw_faturamento_clientes_emp AS
SELECT
    e.employeeNumber,
    e.firstName,
    e.lastName,
    COUNT(DISTINCT c.customerNumber) AS qtd_clientes,
    COALESCE(SUM(p.amount), 0) AS total_recebido
FROM employees e
INNER JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
LEFT JOIN payments p ON c.customerNumber = p.customerNumber
WHERE e.reportsTo = 1143
  AND c.creditLimit > 100000
GROUP BY e.employeeNumber, e.firstName, e.lastName;

CREATE OR REPLACE VIEW vw_faturamento_clientes_emp_v2 AS
SELECT
    e.employeeNumber,
    e.firstName,
    e.lastName,
    c.customerNumber,
    COALESCE(SUM(p.amount), 0) AS total_recebido
FROM employees e
INNER JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
LEFT JOIN payments p ON c.customerNumber = p.customerNumber
WHERE e.reportsTo = 1143
  AND c.creditLimit > 100000
GROUP BY e.employeeNumber, e.firstName, e.lastName, c.customerNumber;

WITH cte_vendas AS (
    SELECT
        v.employeeNumber,
        v.firstName,
        v.lastName,
        v.customerNumber,
        v.total_recebido,
        COUNT(DISTINCT o.orderNumber) AS total_pedidos_cliente,
        COALESCE(SUM(od.quantityOrdered), 0) AS total_produtos_cliente
    FROM vw_faturamento_clientes_emp_v2 v
    INNER JOIN orders o ON v.customerNumber = o.customerNumber
    INNER JOIN orderdetails od ON o.orderNumber = od.orderNumber
    WHERE o.orderDate >= '2003-01-01'
      AND o.orderDate < '2003-04-01'
    GROUP BY
        v.employeeNumber,
        v.firstName,
        v.lastName,
        v.customerNumber,
        v.total_recebido
)
SELECT
    employeeNumber,
    firstName,
    lastName,
    SUM(total_recebido) AS total_recebido,
    SUM(total_pedidos_cliente) AS total_pedidos,
    SUM(total_produtos_cliente) AS total_produtos_vendidos
FROM cte_vendas
GROUP BY employeeNumber, firstName, lastName;

CREATE OR REPLACE VIEW vw_analise_produtos AS
SELECT
    p.productCode,
    FORMAT(((p.MSRP / p.buyPrice) - 1) * 100, 2) AS margem,
    FORMAT((SUM(od.quantityOrdered) / (SUM(od.quantityOrdered) + p.quantityInStock)) * 100, 2) AS percentualVendido,
    ((p.MSRP / p.buyPrice) - 1) * 100 AS margem_num,
    (SUM(od.quantityOrdered) / (SUM(od.quantityOrdered) + p.quantityInStock)) * 100 AS percentualVendido_num
FROM products p
INNER JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode, p.MSRP, p.buyPrice, p.quantityInStock;

DROP TABLE IF EXISTS analise_giro_margem;

CREATE TABLE analise_giro_margem (
    produto VARCHAR(15),
    observacao VARCHAR(200)
);

DROP PROCEDURE IF EXISTS sp_analise_giro_margem;

DELIMITER //
CREATE PROCEDURE sp_analise_giro_margem()
BEGIN
    TRUNCATE TABLE analise_giro_margem;

    INSERT INTO analise_giro_margem (produto, observacao)
    SELECT
        productCode,
        CASE
            WHEN margem_num >= 100 AND percentualVendido_num > 20 THEN 'Produto alto GIRO e excelente Margem. Manter preço'
            WHEN margem_num >= 100 AND percentualVendido_num < 10 THEN 'Produto baixo GIRO e excelente Margem. Reduzir o preço de venda'
            WHEN margem_num < 100 AND percentualVendido_num > 20 THEN 'Produto alto GIRO e baixa Margem. Aumentar o preço de venda'
            ELSE 'Manter os valores praticados'
        END
    FROM vw_analise_produtos;
END //
DELIMITER ;

USE sakila;

DROP PROCEDURE IF EXISTS sp_resumo_categoria;

DELIMITER //
CREATE PROCEDURE sp_resumo_categoria(IN p_categoria VARCHAR(25))
BEGIN
    SELECT
        c.name AS categoria,
        COUNT(DISTINCT f.film_id) AS quantidade_filmes,
        COALESCE(SUM(p.amount), 0) AS valor_faturado
    FROM category c
    INNER JOIN film_category fc ON c.category_id = fc.category_id
    INNER JOIN film f ON fc.film_id = f.film_id
    LEFT JOIN inventory i ON f.film_id = i.film_id
    LEFT JOIN rental r ON i.inventory_id = r.inventory_id
    LEFT JOIN payment p ON r.rental_id = p.rental_id
    WHERE c.name = p_categoria
    GROUP BY c.category_id, c.name;
END //
DELIMITER ;

USE world;

DROP TABLE IF EXISTS falantes_china;

CREATE TABLE falantes_china AS
SELECT
    cl.Language AS idioma,
    SUM(cl.Percentage * c.Population) / 100 AS total_pessoas_falantes
FROM countrylanguage cl
INNER JOIN country c ON cl.CountryCode = c.Code
WHERE cl.CountryCode = 'CHN'
GROUP BY cl.Language;
