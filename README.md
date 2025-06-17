# 🍇 Vitibrasil Analytics - Scraper de Dados de Exportação

<p align="center">
  <img src="https://img.shields.io/badge/Python-3.10%2B-blue?style=for-the-badge&logo=python" alt="Python Version">
  <img src="https://img.shields.io/badge/Status-Concluído-green?style=for-the-badge" alt="Project Status">
</p>

## 1. 🎯 Resumo do Projeto

Este projeto consiste em um web scraper desenvolvido para o Tech Challenge da FIAP. A solução automatiza a coleta de dados públicos sobre a exportação de vinhos brasileiros, cobrindo um período de 15 anos (2008-2023). O objetivo é gerar um dataset limpo e estruturado, pronto para ser utilizado em análises de Business Intelligence e na criação de dashboards para investidores.

O scraper foi construído para extrair informações essenciais de vendas, como país de destino, quantidade em litros e valor transacionado em dólares.

[Caso não queira baixar, você pode conferir o script <a href='https://colab.research.google.com/drive/1Ud6RFogShJPEmBeGQ0tm-yJVuBJz17wv?usp=sharing'>aqui</a>]

---

## 2. 🛠️ Ferramentas e Tecnologias

-   **Linguagem de Programação:** Python
-   **Bibliotecas Principais:** Pandas, Requests, BeautifulSoup4
-   **Formato de Saída:** CSV (`.csv`)

---

## 3. ⚙️ Processo e Metodologia

O desenvolvimento do projeto seguiu uma abordagem focada em extração e tratamento de dados para garantir a qualidade e a usabilidade do dataset final.

-   **Web Scraping Automatizado:** O script navega pelas páginas de dados de exportação, identificando e extraindo sistematicamente as tabelas referentes ao período de 2008 a 2023.
-   **Extração de Dados Essenciais:** Para cada registro, são capturados os dados-chave definidos pelo desafio:
    -   País de destino
    -   Quantidade (`Kg`, convertido para Litros na proporção 1:1)
    -   Valor (`US$`)
-   **Enriquecimento de Dados:** A coluna `País de Origem` é adicionada programaticamente a todos os registros, garantindo que o dataset esteja completo para a análise. Além disso, metadados contextuais, como o título da tabela original (ex: "Exportação por país - 2023"), são capturados para facilitar a validação.
-   **Tratamento e Limpeza (ETL):** Os dados passam por um processo de limpeza para garantir a consistência. A principal transformação é a conversão da coluna de valor (`Valor (US$)`) para um formato numérico, removendo pontos e preparando-a para cálculos.
-   **Consolidação dos Dados:** Todos os dados anuais coletados são unificados em um único arquivo CSV (de acordo com o parâmetro, como por exemplo `exportacao_2008_2023.csv`), servindo como uma fonte de dados centralizada e pronta para análise.




---

## ⚙️ Bibliotecas Utilizadas

- `requests`: Requisições HTTP ao site
- `BeautifulSoup` (bs4): Parseamento de HTML e extração de dados
- `pandas`: Manipulação e estruturação dos dados em DataFrames
- `time.sleep`: Pausa entre as requisições
- `os`, `pathlib.Path`: Gerenciamento de diretórios e caminhos

---

## 📌 Configurações do Script

- Diretório de saída: `data/raw`
- Intervalo de anos: `2008 a 2023`
- Fonte dos dados: http://vitibrasil.cnpuv.embrapa.br/index.php

---

## 🧩 Estrutura do Código

### 1. Configuração das Páginas

As páginas a serem raspadas são configuradas por meio de um dicionário `config_paginas`, com as seguintes propriedades:
- `nome_arquivo`: Nome base do arquivo de saída
- `requer_ano`: Se a página exige um parâmetro de ano
- `subopcoes`: Subcategorias de dados (se aplicável)

### 2. Funções Principais

| Função                       | Descrição |
|-----------------------------|-----------|
| `scrape_tabelas()`          | Requisição e extração das tabelas HTML |
| `processar_tabela_com_itens()` | Trata tabelas com hierarquia (itens e subitens) |
| `tratar_valores_nulos()`    | Converte valores nulos ou inválidos em zero |
| `arquivo_existe()`          | Verifica se arquivo já foi criado para evitar duplicidade |

### 3. Execução Principal

- Itera por cada página configurada
- Realiza scraping por ano e subopção (se necessário)
- Processa os dados e salva os resultados como `.csv` no diretório `data/raw`

---

## 💾 Saída Esperada

Arquivos CSV com os dados estruturados por categoria:

- `producao_2008_2023.csv`
- `processamento_2008_2023.csv`
- `comercializacao_2008_2023.csv`
- `importacao_2008_2023.csv`
- `exportacao_2008_2023.csv`

Cada arquivo contém colunas padronizadas com os dados da respectiva área e o ano correspondente.

---

## ⚠️ Boas Práticas

- O script utiliza `sleep(2)` para evitar sobrecarregar o servidor da Embrapa
- Possui tratamento de erros para continuar a execução mesmo se falhar em alguma página ou tabela
- Os arquivos gerados são nomeados de forma clara para facilitar o uso em análises futuras

---

