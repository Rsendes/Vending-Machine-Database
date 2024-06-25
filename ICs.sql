--2.(RI-1)
DROP TRIGGER IF EXISTS trigger_super_sub_categoria_iguais
	ON tem_outra;

CREATE OR REPLACE FUNCTION super_sub_categoria_iguais()
	RETURNS TRIGGER as
$$
BEGIN
	IF NEW.super = NEW.sub_categoria THEN
		RAISE NOTICE 'Super e sub categoria iguais!';
		RETURN NULL;
	END IF;
	RETURN NEW;
END;
$$LANGUAGE plpgsql;

CREATE TRIGGER trigger_super_sub_categoria_iguais
	BEFORE INSERT ON tem_outra
	FOR EACH ROW
	EXECUTE FUNCTION super_sub_categoria_iguais();

--2.(RI-4)
DROP TRIGGER IF EXISTS trigger_limite_unidades_reposicao
	ON evento_reposicao;

CREATE OR REPLACE FUNCTION excede_limite_unidades()
	RETURNS TRIGGER AS
$$
	DECLARE unidades_planograma numeric(15, 0);

BEGIN
	SELECT unidades INTO unidades_planograma
	FROM planograma
	WHERE planograma.ean = NEW.ean;

	IF NEW.unidades > unidades_planograma THEN
		RAISE NOTICE 'Unidades a repor excedem as unidades do planograma!';
		RETURN NULL;
	END IF;
	RETURN NEW;
END;
$$LANGUAGE plpgsql;

CREATE TRIGGER trigger_limite_unidades_reposicao
	BEFORE INSERT
	ON evento_reposicao
	FOR EACH ROW
	EXECUTE FUNCTION excede_limite_unidades();

--2.(RI-5)
DROP TRIGGER IF EXISTS trigger_produto_percente_prateleira
	ON evento_reposicao;

CREATE OR REPLACE FUNCTION produto_pertence_prateleira()
	RETURNS TRIGGER AS
$$
	DECLARE cat_produto varchar(80);
	DECLARE categoria_IVM varchar(80);
BEGIN
	SELECT nome INTO cat_produto
	FROM tem_categoria
	WHERE tem_categoria.ean = NEW.ean;

	IF cat_produto = NULL THEN
		RAISE NOTICE 'Nenhuma IVM contem essa categoria em uma prateleira.';
		RETURN NULL;
	END IF;

	SELECT categoria INTO categoria_IVM
	FROM responsavel_por
	WHERE responsavel_por.categoria = cat_produto;

	IF categoria_IVM = NULL THEN
		RAISE NOTICE 'O produto a tentar ser inserido nao tem categoria.';
		RETURN NULL;
	END IF;
	RETURN NEW;
END;
$$LANGUAGE plpgsql;

CREATE TRIGGER trigger_produto_pertence_prateleira
	BEFORE INSERT
	ON evento_reposicao
	FOR EACH ROW
	EXECUTE FUNCTION produto_pertence_prateleira();
