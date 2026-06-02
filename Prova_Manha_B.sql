-- ------------------------------------------------------------
-- QUESTÃO a) Sakila
-- ------------------------------------------------------------
SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS cliente,
    SUM(p.amount) AS valor_pago,
    IFNULL(
        CAST(f.rental_duration AS SIGNED) 
        - CAST(DATEDIFF(r.return_date, r.rental_date) AS SIGNED), 
        999
    ) AS analise_dia,
    CASE
        WHEN IFNULL(
                 CAST(f.rental_duration AS SIGNED) 
                 - CAST(DATEDIFF(r.return_date, r.rental_date) AS SIGNED), 
                 999) < 0
          OR IFNULL(
                 CAST(f.rental_duration AS SIGNED) 
                 - CAST(DATEDIFF(r.return_date, r.rental_date) AS SIGNED), 
                 999) = 999
        THEN CONCAT('Informar ao cliente ', c.first_name, ' ', c.last_name, ' tem restrições para alugar')
        ELSE CONCAT('Informar ao cliente ', c.first_name, ' ', c.last_name, ' que terá 10% de desconto')
    END AS analise
FROM customer c
JOIN payment p   ON c.customer_id = p.customer_id
JOIN rental r    ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f      ON i.film_id = f.film_id
WHERE MONTH(p.payment_date) IN (5, 6, 7)
  AND YEAR(p.payment_date) = 2005
GROUP BY 
    c.customer_id, 
    r.rental_id, 
    f.rental_duration,
    r.return_date, 
    r.rental_date
LIMIT 10;

-- ------------------------------------------------------------
-- QUESTÃO b) Sakila
-- ------------------------------------------------------------
SELECT
    i.store_id AS loja,
    SUM(f.replacement_cost) AS total
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f      ON i.film_id = f.film_id
WHERE r.return_date IS NULL
GROUP BY i.store_id
ORDER BY i.store_id;

-- ------------------------------------------------------------
-- QUESTÃO c) ClassicModels
-- ------------------------------------------------------------
SELECT 'produtos' AS observacao, COUNT(*) AS total
FROM (
    SELECT od.productCode
    FROM orderdetails od
    JOIN orders o ON od.orderNumber = o.orderNumber
    WHERE YEAR(o.orderDate) = 2004
    GROUP BY od.productCode
    HAVING SUM(od.quantityOrdered) > 550
) t1

UNION ALL

SELECT 'clientes', COUNT(*)
FROM (
    SELECT p.customerNumber
    FROM payments p
    JOIN customers c ON p.customerNumber = c.customerNumber
    JOIN employees e ON c.salesRepEmployeeNumber = e.employeeNumber
    JOIN offices o   ON e.officeCode = o.officeCode
    WHERE YEAR(p.paymentDate) = 2003
      AND o.city IN ('Paris', 'Tokyo')
    GROUP BY p.customerNumber
    HAVING SUM(p.amount) > 100000
) t2

UNION ALL

SELECT 'vendedores', COUNT(*)
FROM (
    SELECT e.employeeNumber
    FROM employees e
    JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
    JOIN payments p  ON c.customerNumber = p.customerNumber
    WHERE YEAR(p.paymentDate) = 2005
    GROUP BY e.employeeNumber
    HAVING SUM(p.amount) > 200000
) t3;

-- ------------------------------------------------------------
-- QUESTÃO d) DDL
-- ------------------------------------------------------------
CREATE TABLE responsavel_financeiro (
    codigoResponsavel INT NOT NULL AUTO_INCREMENT,
    nomeResponsavel VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) NOT NULL,
    PRIMARY KEY (codigoResponsavel)
);

CREATE TABLE aluno (
    codigoAluno INT NOT NULL AUTO_INCREMENT,
    nomeAluno VARCHAR(100) NOT NULL,
    dataNascimento DATE NOT NULL,
    codigoResponsavel INT NOT NULL,
    PRIMARY KEY (codigoAluno),
    CONSTRAINT fk_aluno_responsavel
        FOREIGN KEY (codigoResponsavel)
        REFERENCES responsavel_financeiro(codigoResponsavel)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);