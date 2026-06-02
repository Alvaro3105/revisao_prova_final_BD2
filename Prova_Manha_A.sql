-- ------------------------------------------------------------
-- QUESTÃO a) ClassicModels
-- ------------------------------------------------------------
SELECT
    c.customerName AS cliente,
    SUM(p.amount) AS total,
    c.creditLimit AS limite_credito,
    CASE
        WHEN (c.creditLimit - SUM(p.amount)) < 0 
            THEN 'Entrar em contato com o cliente'
        ELSE 'Sugerir aumento de crédito'
    END AS analise
FROM customers c
JOIN payments p  ON c.customerNumber = p.customerNumber
JOIN employees e ON c.salesRepEmployeeNumber = e.employeeNumber
JOIN offices o   ON e.officeCode = o.officeCode
WHERE o.city IN ('London', 'Paris', 'Sydney')
  AND YEAR(p.paymentDate) = 2004
GROUP BY 
    c.customerNumber, 
    c.customerName, 
    c.creditLimit;

-- ------------------------------------------------------------
-- QUESTÃO b) ClassicModels
-- ------------------------------------------------------------
SELECT
    p.productName AS produto,
    CONCAT(ROUND(AVG(((od.priceEach / p.buyPrice) - 1) * 100), 2), '%') AS media,
    CASE
        WHEN ROUND(AVG(((od.priceEach / p.buyPrice) - 1) * 100), 2) < 40 
            THEN 'Aumentar margem de lucro'
        WHEN ROUND(AVG(((od.priceEach / p.buyPrice) - 1) * 100), 2) < 100 
            THEN 'Manter o valor'
        ELSE 'Conceder mais 10% de desconto'
    END AS analise
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
JOIN orders o        ON od.orderNumber = o.orderNumber
JOIN customers c     ON o.customerNumber = c.customerNumber
JOIN employees e     ON c.salesRepEmployeeNumber = e.employeeNumber
JOIN offices off     ON e.officeCode = off.officeCode
WHERE off.city IN ('London', 'Paris')
GROUP BY 
    p.productCode, 
    p.productName;

-- ------------------------------------------------------------
-- QUESTÃO c) Sakila
-- ------------------------------------------------------------
SELECT 'Total clientes inativos' AS observacao, COUNT(*) AS qtde
FROM customer
WHERE active = 0

UNION ALL

SELECT 'Total de filmes faltantes no estoque', COUNT(*)
FROM film
WHERE film_id NOT IN (SELECT DISTINCT film_id FROM inventory)

UNION ALL

SELECT 'Total de aluguéis sem data de retorno', COUNT(*)
FROM rental
WHERE return_date IS NULL;

-- ------------------------------------------------------------
-- QUESTÃO d) DDL
-- ------------------------------------------------------------
CREATE TABLE situacao (
    codigoSituacao INT NOT NULL AUTO_INCREMENT,
    nomeSituacao VARCHAR(100) NOT NULL,
    PRIMARY KEY (codigoSituacao)
);

CREATE TABLE aluno (
    codigoAluno INT NOT NULL AUTO_INCREMENT,
    nomeAluno VARCHAR(100) NOT NULL,
    idade INT NOT NULL,
    PRIMARY KEY (codigoAluno)
);

CREATE TABLE departamento (
    codigoDepartamento INT NOT NULL AUTO_INCREMENT,
    nomeDepartamento VARCHAR(100) NOT NULL,
    PRIMARY KEY (codigoDepartamento)
);

CREATE TABLE disciplina (
    codigoDisciplina INT NOT NULL AUTO_INCREMENT,
    nomeDisciplina VARCHAR(100) NOT NULL,
    codigoDepartamentoDisciplina INT NOT NULL,
    PRIMARY KEY (codigoDisciplina),
    CONSTRAINT fk_disciplina_departamento
        FOREIGN KEY (codigoDepartamentoDisciplina)
        REFERENCES departamento(codigoDepartamento)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
);

CREATE TABLE matricula_aluno (
    codigoAlunoMatricula INT NOT NULL,
    codigoDisciplinaMatricula INT NOT NULL,
    ano INT NOT NULL,
    situacaoMatricula INT NOT NULL,
    PRIMARY KEY (codigoAlunoMatricula, codigoDisciplinaMatricula),
    CONSTRAINT fk_matricula_aluno
        FOREIGN KEY (codigoAlunoMatricula)
        REFERENCES aluno(codigoAluno)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_matricula_disciplina
        FOREIGN KEY (codigoDisciplinaMatricula)
        REFERENCES disciplina(codigoDisciplina)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT,
    CONSTRAINT fk_matricula_situacao
        FOREIGN KEY (situacaoMatricula)
        REFERENCES situacao(codigoSituacao)
        ON DELETE RESTRICT
        ON UPDATE RESTRICT
);