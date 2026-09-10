use classicmodels;
use sakila;


 create or replace view vw_resumo_vendas_escritorio as
 with cte_offices as (select officeCode,city  from offices
 where city in ('London','San Franscisco')
 ), cte_employess as (select employeeNumber,officeCode,firstName,lastName from employees
 where officeCode in (select officeCode from cte_offices)
 ), cte_customers as (select customerNumber,salesRepEmployeeNumber,creditLimit from customers
 where creditLimit > 100000.00 and salesRepEmployeeNumber is not null
 ),cte_orders as (select orderNumber,customerNumber,orderDate from orders
 where orderDate between '2004-07-01' and '2004-09-30'
 ),cte_payments as (select customerNumber,amount from payments)
 select e.employeeNumber,concat(e.firstName, ' ',e.lastName) as nome_empregado,
 count(distinct c.customerNumber) as qtd_clientes,
 coalesce(sum(p.amount),0.00) as total_recibido
 from cte_employees e
 join cte_customers c on e.employeeNumber = c.salesRepEmployeeNumber
 join cte_orders o on c.customerNumber = o.customerNumber
 join cte_payments p on c.customerNumber = p.customerNumber
 group by e.employeeNumber,e.firstName,e.lastName
 limit 5;


DELIMITER //
CREATE PROCEDURE sp_total_estoque_loja_categoria(
IN p_store_id INT,
IN p_category_name VARCHAR(25),
OUT p_mensagem VARCHAR(255))
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
' tem o total de: ', v_quantidade,
' no estoque'
    );
END //
DELIMITER ;
CALL sp_total_estoque_loja_categoria(1, 'Comedy', @resultado);
SELECT @resultado;


DELIMITER //
CREATE PROCEDURE sp_inserir_copias_estoque(
OUT p_mensagem VARCHAR(255))
BEGIN
DECLARE v_film_id INT DEFAULT 0;
DECLARE v_film_title VARCHAR(255);
DECLARE v_num_chamada INT DEFAULT 25;
DECLARE v_final_matricula INT DEFAULT 123;
DECLARE v_num_copias INT;
DECLARE v_store_id INT;
DECLARE v_contador INT DEFAULT 0;

    IF v_num_chamada < 10 OR v_num_chamada > 20 THEN
        SET v_num_copias = (v_num_chamada MOD 11) + 10;
    ELSE
        SET v_num_copias = v_num_chamada;
    END IF;


    IF (v_final_matricula % 2) <> 0 THEN
        SET v_store_id = 1;
    ELSE
        SET v_store_id = 2;
    END IF;


    SELECT f.film_id, f.title
    INTO v_film_id, v_film_title
    FROM film f
    LEFT JOIN inventory i ON f.film_id = i.film_id
    WHERE i.inventory_id IS NULL AND f.film_id > v_final_matricula
    ORDER BY f.film_id ASC LIMIT 1;


    IF v_film_id IS NOT NULL AND v_film_id > 0 THEN

        REPEAT
            INSERT INTO inventory (film_id, store_id, last_update)
            VALUES (v_film_id, v_store_id, CURRENT_TIMESTAMP());
            SET v_contador = v_contador + 1;
        UNTIL v_contador >= v_num_copias
        END REPEAT;


        SET p_mensagem = CONCAT('O filme: "', v_film_title, '" agora tem ', v_num_copias, ' copias no estoque.');

    ELSE
        SET p_mensagem = 'Nenhum filme elegível encontrado.';
    END IF;

END //
DELIMITER ;

CALL sp_inserir_copias_estoque(@msg);
SELECT @msg;


CREATE TABLE paises_analise_densidade AS
SELECT c.Name AS nome_pais,
(c.Population / c.SurfaceArea) AS densidade_demografica,
CASE WHEN (c.Population / c.SurfaceArea) > 100 THEN 'Pais Populoso'
ELSE 'Dentro do Padrao'
END AS analise
FROM country c
INNER JOIN countrylanguage cl
ON c.Code = cl.CountryCode
WHERE c.GovernmentForm LIKE '%Republic%'
AND cl.Language = 'English';


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

CALL sp_rotina_estudos_tecnicos('Raphael');
