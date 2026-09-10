# Enunciados das provas adicionadas

Este arquivo resume os enunciados dos três PDFs utilizados como referência para os scripts SQL publicados nesta pasta.

## Prova Final 02 — Manhã B

### Questão 1

**A)** Criar uma `VIEW` com o total recebido e a quantidade de clientes por empregado, considerando compras do terceiro trimestre de 2004, escritórios de London e San Francisco, limite de crédito acima de 100 mil e resultado limitado a 5 registros. Todas as tabelas envolvidas devem ser representadas por CTEs e os filtros devem ficar dentro das respectivas CTEs.

**B)** Na base Sakila, criar uma procedure que receba o código da loja e o nome da categoria e retorne uma mensagem com a quantidade de itens em estoque para aquela loja e categoria.

**C)** Na base Sakila, criar uma procedure com parâmetro de saída para inserir cópias de um filme que ainda não esteja no estoque. A rotina deve escolher o filme com base no final da matrícula, definir a loja pela paridade da matrícula e utilizar `REPEAT` para inserir entre 10 e 20 cópias conforme a regra do número de chamada.

**D)** Na base World, criar uma tabela com nome do país, densidade demográfica e uma análise classificando países com densidade acima de 100 como "Pais Populoso" e os demais como "Dentro do Padrão", filtrando países com forma de governo República e idioma Inglês.

**E)** Criar uma procedure com pelo menos um parâmetro de entrada que demonstre uma rotina habitual em 5 passos.

## Prova Final 03 — Tarde A

### Questão 1

**A)** Criar uma `VIEW` que retorne o valor total recebido por produto para pedidos do segundo trimestre de 2003, considerando escritórios de London e Tokyo, clientes com limite de crédito acima de 100 mil e resultado limitado a 5 registros. Todas as tabelas envolvidas devem ser expressas como CTEs, com os filtros dentro das CTEs.

**B)** Na base Sakila, criar uma procedure que receba o código da loja e retorne o filme mais alugado e sua categoria, utilizando agregação, `GROUP BY`, ordenação decrescente e `LIMIT 1`.

**C)** Na base ClassicModels, criar uma procedure que receba código do cliente, código do vendedor e limite de crédito. A rotina deve validar o cliente, vincular o vendedor, atualizar o limite de crédito, gerar um novo pedido, escolher o produto com maior estoque, inserir o item do pedido e atualizar o estoque.

**D)** Na base World, criar uma tabela com nome do país, densidade e análise de densidade, filtrando a região Southern Europe e o idioma Serbo-Croatian.

**E)** Criar uma procedure com pelo menos um parâmetro de entrada que demonstre uma rotina habitual em 5 passos.

## Prova Final 06 — B

### Questão 1

**A)** Criar uma `VIEW` que retorne faturamento e quantidade de clientes por empregado quando `reportsTo = 1143` e o limite de crédito for superior a 100000.

**B)** Modificar a view anterior para incluir o código do cliente e criar uma CTE juntando a nova view com `Orders` e `OrderDetails`, retornando total recebido, total de pedidos e total de produtos vendidos por vendedor no primeiro trimestre de 2003.

**C)** Criar uma view com código do produto, margem e percentual vendido; criar a tabela `ANALISE_GIRO_MARGEM`; e criar uma procedure sem parâmetro de entrada que classifique cada produto de acordo com as regras de margem e giro definidas no enunciado.

**D)** Na base Sakila, criar uma procedure que receba uma categoria e apresente a quantidade de filmes e o valor faturado.

### Questão 2

Na base World, criar uma tabela a partir de uma consulta que retorne o total estimado de pessoas falantes por idioma para `countryCode = CHN`, utilizando o percentual do idioma e a população do país.
