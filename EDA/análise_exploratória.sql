-- Define o banco de dados 'teste' como o contexto para as consultas seguintes.
-- Em SSMS, você também pode selecionar o banco de dados no menu dropdown.
USE teste;
GO

--================================================================
-- FASE 1: EXPLORAÇÃO E VALIDAÇÃO DE DADOS
--================================================================

-- Lista todos os nomes de países únicos e corrigidos da tabela de exportação.
SELECT DISTINCT(País_corrigido) FROM exportacao ORDER BY País_corrigido;
GO

-- Verifica quais países da exportação existem na tabela de referência 'paises'.
SELECT * FROM paises WHERE country_name IN (SELECT DISTINCT(País_corrigido) FROM exportacao);
GO

-- Junta dados de uvas e países.
SELECT * FROM uvas INNER JOIN paises ON uvas.País_corrigido = paises.country_name WHERE Valor_US > 0;
GO

-- Exploração geral das tabelas principais.
SELECT * FROM uvas;
GO
SELECT * FROM paises WHERE country_name LIKE '%b%' ORDER BY country_name; -- Exemplo de filtro
GO
SELECT * FROM cambio_media_anual;
GO
SELECT * FROM exportacao_2008_2025;
GO
SELECT * FROM dados_globais_oiv;
GO
SELECT DISTINCT(unit) FROM dados_globais_oiv;
GO
SELECT DISTINCT(REGION_COUNTRY) FROM dados_globais_oiv;
GO

--================================================================
-- FASE 2: INVESTIGAÇÃO E LIMPEZA DE DADOS
--================================================================

-- Investiga um país específico para checar consistência.
SELECT * FROM exportacao WHERE País_corrigido LIKE '%Moçambique%';
GO
SELECT * FROM paises WHERE country_name LIKE '%Moçambique%';
GO

/*
 Comentário de investigação do autor original:
 --paises que não aparecem em https://github.com/AndiDittrich/GeoIP-Country-Lists/blob/master/GeoLite2/GeoLite2-Country-CSV_20150407/GeoLite2-Country-Locations-pt-BR.csv
 --, Antilhas Holandesas, Barein, Bósnia-Herzegovina, Cabo Verde, Cayman, Ilhas, Cocos (Keeling), Ilhas, Comores, Coveite (Kuweit), 
 --Falkland (Malvinas), Guiné-Bissau, Macau, Malavi, Marshall, Ilhas, Moçambique, Países Baixos (Holanda), São Tomé e Príncipe,
 --São Vicente e Granadinas, Singapura, Taiwan (Formosa), Tcheca, República, Toquelau, Trinidad e Tobago, Virgens, Ilhas (Britânicas)
*/

-- Padronização de unidades na tabela de dados globais.
UPDATE dados_globais_oiv SET unit = '1000 hectolitros' WHERE unit = '1.000 hectolitros';
GO
UPDATE dados_globais_oiv SET unit = 'toneladas' WHERE unit = 'tonnes';
GO

--================================================================
-- FASE 3: CONSULTAS DE AGREGAÇÃO E ANÁLISE
--================================================================

-- Vendas e quantidade por continente e ano.
SELECT 
    ano, 
    continente,
    COUNT(continente) AS vendas_por_continente, 
    SUM(quantidade) AS Qtd_vendida, 
    SUM(valor) AS valor_vendido  
FROM exportacao 
WHERE quantidade > 0 AND valor > 0 
GROUP BY continente, ano 
ORDER BY continente, ano;
GO

-- Vendas e quantidade totais por continente.
SELECT 
    continente,
    COUNT(continente) AS vendas_por_continente, 
    SUM(quantidade) AS Qtd_vendida, 
    SUM(valor) AS valor_vendido  
FROM exportacao 
WHERE quantidade > 0 AND valor > 0 
GROUP BY continente 
ORDER BY Qtd_vendida, valor_vendido;
GO

-- Valor total de exportação (US$) por ano para um continente específico.
SELECT 
    continent_name, 
    ano, 
    SUM(valor_us) AS total_valor_us
FROM exportacao_2008_2025
LEFT JOIN paises ON paises.country_name = exportacao_2008_2025.País_corrigido 
WHERE valor_us > 0 AND continent_name = 'África'
GROUP BY continent_name, ano
ORDER BY ano;
GO

--================================================================
-- FASE 4: CONSULTAS DE INTEGRAÇÃO (JOINS)
--================================================================

-- Junção de tabelas para enriquecer os dados de exportação (exemplo simples).
SELECT * FROM exportacao 
LEFT JOIN paises ON paises.country_name = exportacao.País_corrigido 
INNER JOIN cambio_media_anual ON cambio_media_anual.ano = exportacao.ano;
GO

-- Junção complexa para um relatório detalhado filtrado por 'Rússia'.
SELECT * FROM exportacao 
LEFT JOIN paises AS p1 ON p1.country_name = exportacao.País_corrigido 
INNER JOIN cambio_media_anual ON cambio_media_anual.ano = exportacao.ano
INNER JOIN paises_pt_eng ON paises_pt_eng.NO_PAIS = exportacao.pais
LEFT JOIN dados_globais_oiv ON dados_globais_oiv.REGION_COUNTRY = paises_pt_eng.NO_PAIS_ing AND dados_globais_oiv.YEAR = exportacao.ano
WHERE Valor_us > 0 AND país_corrigido = 'Rússia';
GO

-- Junção detalhada para um registro específico (Angola, 2012).
SELECT * FROM exportacao_2008_2025 
LEFT JOIN paises ON paises.country_name = exportacao_2008_2025.País_corrigido 
INNER JOIN paises_pt_eng ON paises_pt_eng.NO_PAIS = exportacao_2008_2025.Pais
INNER JOIN cambio_media_anual ON cambio_media_anual.ano = exportacao_2008_2025.ano
LEFT JOIN dados_globais_oiv ON dados_globais_oiv.REGION_COUNTRY = paises_pt_eng.NO_PAIS_ing AND dados_globais_oiv.YEAR = exportacao_2008_2025.ano
WHERE Valor_us > 0
  AND Pais LIKE 'Angola%'
  AND exportacao_2008_2025.ano = 2012;
GO

-- Consulta final para criar um dataset consolidado.
SELECT 
    exportacao.pais, 
    exportacao.continente, 
    exportacao.origem, 
    exportacao.ano,
    exportacao.quantidade, 
    exportacao.valor, 
    exportacao.contexto, 
    paises_pt_eng.NO_PAIS_ING,
    -- dados_globais_oiv
    dados_globais_oiv.product AS produto_oiv, 
    dados_globais_oiv.variable AS variavel_oiv, 
    dados_globais_oiv.unit AS unidade_oiv, 
    dados_globais_oiv.quantity AS quantidade_oiv,
    -- Cambio_Media_Anual
    Cambio_Media_Anual.Media_Anual AS Dolar_anual
FROM exportacao 
INNER JOIN paises_pt_eng ON paises_pt_eng.NO_PAIS = exportacao.pais
LEFT JOIN dados_globais_oiv ON dados_globais_oiv.REGION_COUNTRY = paises_pt_eng.NO_PAIS_ing AND dados_globais_oiv.YEAR = exportacao.ano
INNER JOIN Cambio_Media_Anual ON Cambio_Media_Anual.ano = exportacao.ano
WHERE exportacao.valor > 0;
GO

--================================================================
-- EXEMPLOS DE CONSULTAS RÁPIDAS (USANDO TOP)
--================================================================
SELECT TOP 5 * FROM paises_pt_eng;
GO
SELECT TOP 5 * FROM dados_globais_oiv;
GO
SELECT TOP 5 * FROM exportacao 
INNER JOIN paises_pt_eng ON paises_pt_eng.NO_PAIS = exportacao.pais;
GO
