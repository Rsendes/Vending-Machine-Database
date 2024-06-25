CREATE VIEW vendas(
	ean, categoria, ano, trimestre, mes, dia_mes,
	dia_semana, distrito, concelho, unidades)
AS
	SELECT produto.ean, categoria, EXTRACT(YEAR FROM instante),
	EXTRACT(QUARTER FROM instante), EXTRACT(MONTH FROM instante),
	EXTRACT(DAY FROM instante), EXTRACT(ISODOW FROM instante),
	distrito, concelho, unidades
	FROM evento_reposicao
		INNER JOIN produto
		ON evento_reposicao.ean = produto.ean
		INNER JOIN instalada_em
		ON evento_reposicao.numero_serie = instalada_em.numero_serie
		INNER JOIN ponto_de_retalho
		ON instalada_em.local = ponto_de_retalho.nome;