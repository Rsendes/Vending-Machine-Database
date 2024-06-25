SELECT dia_semana, concelho, COUNT(ean) AS produtos
FROM vendas
WHERE (make_date(CAST(ano AS INT), CAST(mes AS INT), CAST(dia_mes AS INT)) between make_date(2020, 01, 28)
		AND make_date(2021, 12, 30))
GROUP BY
	GROUPING SETS ((dia_semana, concelho), ())
ORDER BY dia_semana, concelho;



SELECT concelho, categoria, dia_semana, COUNT(ean) AS produtos
FROM vendas
GROUP BY
	ROLLUP (distrito, concelho, categoria, dia_semana)
HAVING distrito = 'lisboa'
ORDER BY concelho, categoria, dia_semana;