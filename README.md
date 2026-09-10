# Banco de Dados II — Provas Finais e Revisão

Repositório com exercícios, revisões e provas práticas da disciplina de **Banco de Dados II**, desenvolvidos em **MySQL** com as bases **ClassicModels**, **Sakila** e **World**.

## Conteúdos praticados

- Views e CTEs (`WITH`)
- Stored Procedures
- Parâmetros de entrada e saída
- `JOIN`, `GROUP BY`, `ORDER BY` e funções de agregação
- Estruturas condicionais com `CASE` e `IF`
- Manipulação de datas
- `REPEAT`
- Criação e atualização de tabelas
- Consultas de estoque, vendas, clientes e faturamento

## Provas

A pasta `provas/` contém:

- `Prova_Final_02_Manha_B.sql`
- `Prova_Final_03_Tarde_A.sql`
- `Prova_Final_06_B.sql`
- `ENUNCIADOS.md`

Os três scripts foram revisados, tiveram os comentários removidos e receberam correções de sintaxe, organização e lógica para ficarem mais seguros de executar e mais próximos do que os enunciados pedem.

## Principais correções realizadas

Na prova `Prova_Final_02_Manha_B.sql` foram corrigidos o nome da CTE de empregados, a escrita de `San Francisco`, a troca correta entre os schemas e a duplicação de valores provocada pelo relacionamento entre pedidos e pagamentos. Os pagamentos também passaram a ser agregados antes da consulta principal.

Na prova `Prova_Final_03_Tarde_A.sql`, o cálculo por produto foi ajustado para utilizar o valor dos itens vendidos (`quantityOrdered * priceEach`). Isso evita repetir o valor integral dos pagamentos de um cliente para cada produto, já que a tabela `payments` do ClassicModels não possui ligação direta com um pedido específico. Também foram adicionadas validações na procedure responsável pela criação do pedido.

Na prova `Prova_Final_06_B.sql`, a CTE da questão B foi reorganizada para impedir que o faturamento do cliente fosse somado novamente para cada item de pedido. O campo de produto da tabela `analise_giro_margem` foi definido como `VARCHAR(15)`, acompanhando o tamanho real de `productCode` no ClassicModels. A procedure da categoria no Sakila também foi ajustada para contar os filmes mesmo quando não possuem aluguel.

## Execução

Os scripts já utilizam `USE classicmodels`, `USE sakila` e `USE world` nos pontos necessários. Também foram adicionados `DROP PROCEDURE IF EXISTS` e `DROP TABLE IF EXISTS` onde necessário para facilitar novas execuções sem conflitos de objetos já existentes.

As chamadas de teste que alteravam dados foram retiradas dos arquivos principais. Algumas procedures criadas nas provas fazem `INSERT` ou `UPDATE`, portanto devem ser chamadas conscientemente em uma base de testes.

## Outros arquivos de revisão

O repositório também mantém materiais anteriores:

- `Prova_Manha_A.sql`
- `Prova_Manha_B.sql`
- `Prova_Tarde_B_Gabarito.sql`

## Objetivo

Registrar minha evolução em Banco de Dados II e reunir exemplos práticos de consultas SQL, views, CTEs, procedures, agregações e manipulação de dados em bancos relacionais.
