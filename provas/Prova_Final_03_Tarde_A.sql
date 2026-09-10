create or replace view view_total_recebido_produto as (
with
cte_escritorios(officeCode) as (
select officeCode from offices
where city in ('London', 'Tokyo')),
cte_empregados(employeeNumber, officeCode) as (
select employeeNumber, officeCode from employees),
cte_clientes(customerNumber, salesRepEmployeeNumber) as (
select customerNumber, salesRepEmployeeNumber from customers
where creditLimit > 100000
),
cte_pedidos(orderNumber, customerNumber) as (
select orderNumber, customerNumber from orders
where year(orderDate) = 2003 and month(orderDate) in (04, 05, 06)
),
cte_detalhes(orderNumber, productCode) as (
select orderNumber, productCode from orderdetails
),
cte_pagamentos(customerNumber, amount) as (
select customerNumber, amount from payments
)
select
cte_detalhes.productCode,
sum(cte_pagamentos.amount) as valor_total_recebido
from cte_escritorios
inner join cte_empregados on cte_escritorios.officeCode = cte_empregados.officeCode
inner join cte_clientes on cte_empregados.employeeNumber = cte_clientes.salesRepEmployeeNumber
inner join cte_pedidos on cte_clientes.customerNumber = cte_pedidos.customerNumber
inner join cte_detalhes on cte_pedidos.orderNumber = cte_detalhes.orderNumber
inner join cte_pagamentos on cte_clientes.customerNumber = cte_pagamentos.customerNumber
group by cte_detalhes.productCode
limit 5
);
select * from view_total_recebido_produto;


delimiter $$
create procedure proc_filme_mais_alugado_loja(in p_loja_id int)
begin
select
concat('O filme mais alugado é: "', film.title, '" que do gênero: "', category.name, '"') as Mensagem
from inventory

inner join rental using(inventory_id)

inner join film using(film_id)

inner join film_category using(film_id)

inner join category using(category_id)


where inventory.store_id = p_loja_id


group by film.title, category.name


order by count(rental.rental_id) desc

limit 1;

end $$

delimiter ;


call proc_filme_mais_alugado_loja(1);


call proc_filme_mais_alugado_loja(2);


delimiter $$

create procedure proc_novo_pedido_cliente(
    in p_customerNumber int,
    in p_salesRepEmployeeNumber int,
    in p_creditLimit decimal(10,2)
)
rotulo_principal: begin
    declare v_existe_cliente int default 0;
    declare v_vendedor_atual int;
    declare v_novo_orderNumber int;
    declare v_produto_codigo varchar(15);
    declare v_produto_msrp decimal(10,2);


    declare v_matricula int default 086;


    select count(*) into v_existe_cliente
    from customers
    where customerNumber = p_customerNumber;

    if v_existe_cliente = 0 then
        select 'O processo não foi concluído com sucesso' as Mensagem;
        leave rotulo_principal;
    end if;


    select salesRepEmployeeNumber into v_vendedor_atual
    from customers
    where customerNumber = p_customerNumber;

    if v_vendedor_atual is not null then
        select 'O processo não foi concluído com sucesso' as Mensagem;
        leave rotulo_principal;
    end if;


    update customers
    set salesRepEmployeeNumber = p_salesRepEmployeeNumber,
        creditLimit = p_creditLimit
    where customerNumber = p_customerNumber;


    select max(orderNumber) + 1 into v_novo_orderNumber
    from orders;


    insert into orders (orderNumber, orderDate, requiredDate, shippedDate, status, customerNumber)
    values (
        v_novo_orderNumber,
        current_date(),
        current_date() + interval 7 day,
        current_date() + interval 5 day,
        'Shipped',
        p_customerNumber
    );


    select productCode, MSRP into v_produto_codigo, v_produto_msrp
    from products
    order by quantityInStock desc
    limit 1;


    insert into orderdetails (orderNumber, productCode, quantityOrdered, priceEach, orderLineNumber)
    values (
        v_novo_orderNumber,
        v_produto_codigo,
        v_matricula,
        v_produto_msrp * 0.20,
        1
    );


    update products
    set quantityInStock = quantityInStock - v_matricula
    where productCode = v_produto_codigo;


    select 'Processo concluído com sucesso!' as Mensagem;

end rotulo_principal $$

delimiter ;


create table paises_servocroatas as (
select
c.Name as nome_pais,
(c.Population / c.SurfaceArea) as densidade,
case
when (c.Population / c.SurfaceArea) > 100 then 'Pais Populoso'
else 'Dentro do Padrão'
end as analise
from country c
inner join countrylanguage cl on c.Code = cl.CountryCode
where c.Region = 'Southern Europe'
and cl.Language = 'Serbo-Croatian'
);


delimiter $$

create procedure proc_rotina_diaria(in p_nome_pessoa varchar(50))
begin
select
p_nome_pessoa as pessoa,
1 as passo,
'Acordar cedo, tomar um café reforçado e ir para o trabalho' as atividade

union all


    select
        p_nome_pessoa,
        2,
        'Trabalhar focadíssimo durante a manhã e a tarde'

    union all


    select
        p_nome_pessoa,
        3,
        'Sair do trabalho e ir correndo para a escola/faculdade'

    union all


    select
        p_nome_pessoa,
        4,
        'Assistir às aulas, fazer anotações e realizar os trabalhos em grupo'

    union all


    select
        p_nome_pessoa,
        5,
        'Voltar para casa, jantar, dar uma última revisada na matéria e dormir';

end $$


delimiter ;

call proc_rotina_diaria('Ana');
