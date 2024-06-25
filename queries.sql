----------------------------------------
-- SQL
----------------------------------------

-- Qual o nome do retalhista (ou retalhistas) responsáveis
-- pela reposição do maior número de categorias?

SELECT distinct nome
FROM retalhista
WHERE tin IN (
	SELECT tin
	FROM responsavel_por
	GROUP BY tin
	ORDER BY count(categoria) DESC)
FETCH FIRST 1 ROWS ONLY;


-- Qual o nome do ou dos retalhistas que são
-- responsáveis por todas as categorias simples?

SELECT distinct nome
FROM retalhista
	NATURAL JOIN responsavel_por
	INNER JOIN categoria_simples
	ON categoria = categoria_nome;


-- Quais os produtos (ean) que nunca foram repostos?

SELECT ean
FROM produto
EXCEPT
SELECT ean
FROM evento_reposicao;


-- Quais os produtos (ean) que foram repostos
-- sempre pelo mesmo retalhista?

SELECT ean
FROM produto
NATURAL JOIN evento_reposicao
GROUP BY ean
HAVING COUNT(tin) = 1;
