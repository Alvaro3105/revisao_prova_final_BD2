-- ============================================================
-- GABARITO - PROVA FINAL 01 - TARDE B
-- Banco de dados: sakila (a, b, c) | DDL (d)
-- ============================================================

-- ------------------------------------------------------------
-- QUESTÃO 1-A (2 pts)
-- Conferência de caixa - AGOSTO/2005
-- ------------------------------------------------------------
SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS cliente,
    SUM(p.amount) AS valor_pago,
    IFNULL(
        CAST(f.rental_duration - DATEDIFF(r.return_date, r.rental_date) AS SIGNED),
        999
    ) AS analise_dia,
    CASE
        WHEN IFNULL(
                 CAST(f.rental_duration - DATEDIFF(r.return_date, r.rental_date) AS SIGNED),
                 999
             ) < 0
          OR IFNULL(
                 CAST(f.rental_duration - DATEDIFF(r.return_date, r.rental_date) AS SIGNED),
                 999
             ) = 999
        THEN CONCAT('Informar ao cliente ', c.first_name, ' ', c.last_name, ' tem restrições para alugar')
        ELSE CONCAT('Informar ao cliente ', c.first_name, ' ', c.last_name, ' que terá 10% de desconto')
    END AS analise
FROM payment p
JOIN customer c  ON c.customer_id = p.customer_id
JOIN rental r    ON r.rental_id = p.rental_id
JOIN inventory i ON i.inventory_id = r.inventory_id
JOIN film f      ON f.film_id = i.film_id
WHERE YEAR(p.payment_date) = 2005
  AND MONTH(p.payment_date) = 8
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    f.rental_duration,
    r.return_date,
    r.rental_date
LIMIT 10;

-- ------------------------------------------------------------
-- QUESTÃO 1-B (3 pts)
-- Filmes NO estoque que NÃO FORAM alugados
-- ------------------------------------------------------------
SELECT
    f.title AS titulo,
    i.store_id AS loja,
    ca.name AS categoria,
    COUNT(i.inventory_id) AS qtde
FROM inventory i
JOIN film f           ON f.film_id = i.film_id
JOIN film_category fc ON fc.film_id = f.film_id
JOIN category ca      ON ca.category_id = fc.category_id
LEFT JOIN rental r    ON r.inventory_id = i.inventory_id
WHERE r.inventory_id IS NULL
GROUP BY f.film_id, f.title, i.store_id, ca.name
ORDER BY f.title;

-- ------------------------------------------------------------
-- QUESTÃO 1-C (3 pts)
-- Quantidade de filmes no estoque (inventory) por loja (Drama e Comedy)
-- ------------------------------------------------------------
SELECT
    ca.name AS categoria,
    i.store_id AS loja,
    COUNT(*) AS qtde
FROM inventory i
JOIN film f           ON f.film_id = i.film_id
JOIN film_category fc ON fc.film_id = f.film_id
JOIN category ca      ON ca.category_id = fc.category_id
WHERE ca.name IN ('Drama', 'Comedy')
GROUP BY ca.name, i.store_id
ORDER BY ca.name, i.store_id;

-- ------------------------------------------------------------
-- QUESTÃO 1-D (4 pts)
-- DDL - Disciplina e Professor
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Disciplina (
    disciplina_id INT NOT NULL AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    carga_horaria INT NOT NULL,
    PRIMARY KEY (disciplina_id)
);

CREATE TABLE IF NOT EXISTS Professor (
    professor_id INT NOT NULL AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    especialidade VARCHAR(100) NOT NULL,
    PRIMARY KEY (professor_id)
);

-- Tabela associativa M:N entre Disciplina e Professor
CREATE TABLE IF NOT EXISTS Disciplina_Professor (
    disciplina_id INT NOT NULL,
    professor_id INT NOT NULL,
    PRIMARY KEY (disciplina_id, professor_id),
    CONSTRAINT fk_dp_disciplina
        FOREIGN KEY (disciplina_id) REFERENCES Disciplina(disciplina_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_dp_professor
        FOREIGN KEY (professor_id) REFERENCES Professor(professor_id)
        ON DELETE RESTRICT
);