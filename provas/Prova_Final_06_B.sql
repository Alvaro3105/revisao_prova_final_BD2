create or replace view vw_faturamento_clientes_emp as
select
    e.employeenumber,
    e.firstname,
    e.lastname,
    count(distinct c.customernumber) as qtd_clientes,
    coalesce(sum(p.amount), 0) as total_recebido
from employees e
inner join customers c
    on e.employeenumber = c.salesrepemployeenumber
left join payments p
    on c.customernumber = p.customernumber
where e.reportsto = 1143
  and c.creditlimit > 100000
group by
    e.employeenumber,
    e.firstname,
    e.lastname;


create or replace view vw_faturamento_clientes_emp_v2 as
select
    e.employeenumber,
    e.firstname,
    e.lastname,
    c.customernumber,
    coalesce(sum(p.amount), 0) as total_recebido
from employees e
inner join customers c
    on e.employeenumber = c.salesrepemployeenumber
left join payments p
    on c.customernumber = p.customernumber
where e.reportsto = 1143
  and c.creditlimit > 100000
group by
    e.employeenumber,
    e.firstname,
    e.lastname,
    c.customernumber;

with cte_vendedores as (
    select
        employeenumber,
        firstname,
        lastname,
        customernumber,
        total_recebido
    from vw_faturamento_clientes_emp_v2
)
select
    v.employeenumber,
    v.firstname,
    v.lastname,
    sum(v.total_recebido) as total_recebido,
    count(distinct o.ordernumber) as total_pedidos,
    coalesce(sum(od.quantityordered), 0) as total_produtos_vendidos
from cte_vendedores v
inner join orders o
    on v.customernumber = o.customernumber
inner join orderdetails od
    on o.ordernumber = od.ordernumber
where o.orderdate between '2003-01-01' and '2003-03-31'
group by
    v.employeenumber,
    v.firstname,
    v.lastname;


create or replace view vw_analise_produtos as
select
    p.productcode,
    format(((p.msrp / p.buyprice) - 1) * 100, 2) as margem,
    format((sum(od.quantityordered) / (sum(od.quantityordered) + p.quantityinstock) * 100), 2) as percentualvendido,
    ((p.msrp / p.buyprice) - 1) * 100 as margem_num,
    (sum(od.quantityordered) / (sum(od.quantityordered) + p.quantityinstock) * 100) as percentualvendido_num
from products p
inner join orderdetails od
    on p.productcode = od.productcode
group by
    p.productcode,
    p.msrp,
    p.buyprice,
    p.quantityinstock;

create table if not exists analise_giro_margem (
    produto varchar(10),
    observacao varchar(200)
);

delimiter //
create procedure sp_analise_giro_margem()
begin
    truncate table analise_giro_margem;

    insert into analise_giro_margem (produto, observacao)
    select
        productcode as produto,
        case
            when margem_num >= 100 and percentualvendido_num > 20 then
                'produto alto giro e excelente margem. manter preço'
            when margem_num >= 100 and percentualvendido_num < 10 then
                'produto baixo giro e excelente margem. reduzir o preço de venda'
            when margem_num < 100 and percentualvendido_num > 20 then
                'produto alto giro e baixa margem. aumentar o preço de venda'
            else
                'manter os valores praticados'
        end as observacao
    from vw_analise_produtos;
end //
delimiter ;


delimiter //
create procedure sp_resumo_categoria(in p_categoria varchar(25))
begin
    select
        c.name as categoria,
        count(distinct f.film_id) as quantidade_filmes,
        coalesce(sum(p.amount), 0) as valor_faturado
    from category c
    inner join film_category fc
        on c.category_id = fc.category_id
    inner join film f
        on fc.film_id = f.film_id
    inner join inventory i
        on f.film_id = i.film_id
    inner join rental r
        on i.inventory_id = r.inventory_id
    inner join payment p
        on r.rental_id = p.rental_id
    where c.name = p_categoria
    group by c.name;
end //
delimiter ;


create table if not exists falantes_china as
select
    cl.language as idioma,
    sum(cl.percentage * c.population) / 100 as total_pessoas_falantes
from countrylanguage cl
inner join country c
    on cl.countrycode = c.code
where cl.countrycode = 'chn'
group by cl.language;
