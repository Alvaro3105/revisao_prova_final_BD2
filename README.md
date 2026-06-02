# 🗄️ Estudos e Resolução de Provas - Banco de Dados II (BD2)

Este repositório reúne scripts SQL com resoluções de provas práticas e simulados utilizados como material de revisão aprofundada para a disciplina de **Banco de Dados II**. 

O objetivo deste laboratório foi exercitar a escrita de consultas analíticas complexas (DML), funções nativas de SGBDs relacionais (MySQL) e a criação estruturada de esquemas de tabelas (DDL) com foco em integridade referencial.

## 🛠️ Competências Praticadas

### 1. Consultas Avançadas & Business Intelligence (DML)
* **Junções Complexas (Multi-Joins):** Cruzamento de dados conectando múltiplas tabelas simultaneamente sobre os schemas universais *Sakila* e *ClassicModels*.
* **Lógica Condicional Dinâmica:** Implementação da estrutura `CASE WHEN ... THEN ... ELSE` para gerar relatórios preditivos e análises de status diretamente via banco de dados.
* **Manipulação Temporal e de Tipos:** Uso avançado de funções matemáticas e de data como `DATEDIFF()`, `YEAR()`, `MONTH()`, além de conversões explícitas de tipos de dados usando `CAST()`.
* **Agrupamentos e Operações de Conjunto:** Agregações complexas com `GROUP BY`, filtros em grupos via `HAVING` e unificação de fluxos de dados distintos com `UNION ALL`.

### 2. Modelagem Relacional & Arquitetura (DDL)
* **Integridade Referencial Estrita:** Definição manual de chaves primárias, chaves estrangeiras (`FOREIGN KEY`) e índices.
* **Regras de Negócio em Cascata:** Configuração precisa de comportamentos de deleção e atualização utilizando `ON DELETE CASCADE` e `ON DELETE RESTRICT`.
* **Relacionamentos Complexos:** Estruturação de tabelas associativas/junção para representação de relacionamentos N:M (Muitos-para-Muitos), incluindo Chaves Primárias Compostas.

## 📁 Estrutura do Repositório

O repositório está organizado por turnos e gabaritos de exames práticos:

* `Prova_Manha_A.sql`: Foco em relatórios de margem de lucro, limites de crédito utilizando o banco *ClassicModels* e modelagem DDL acadêmica (Alunos/Disciplinas).
* `Prova_Manha_B.sql`: Resoluções envolvendo o banco *Sakila*, cálculos de atraso de locação e queries consolidadas com múltiplos blocos de `UNION ALL`.
* `Prova_Tarde_B_Gabarito.sql`: Scripts contendo conferência de caixas, agrupamento de inventário por categorias de filmes e modelagem de tabelas associativas N:M (Professores/Disciplinas).
