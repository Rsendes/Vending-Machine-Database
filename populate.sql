DROP TABLE categoria CASCADE;
DROP TABLE categoria_simples CASCADE;
DROP TABLE super_categoria CASCADE;
DROP TABLE tem_outra CASCADE;
DROP TABLE produto CASCADE;
DROP TABLE tem_categoria CASCADE;
DROP TABLE IVM CASCADE;
DROP TABLE ponto_de_retalho CASCADE;
DROP TABLE instalada_em CASCADE;
DROP TABLE prateleira CASCADE;
DROP TABLE planograma CASCADE;
DROP TABLE retalhista CASCADE;
DROP TABLE responsavel_por CASCADE;
DROP TABLE evento_reposicao CASCADE;


----------------------------------------
-- Table Creation
----------------------------------------

CREATE TABLE categoria
	(categoria_nome varchar(80) NOT NULL,
	 CONSTRAINT pk_categoria PRIMARY KEY(categoria_nome));

CREATE TABLE categoria_simples
	(categoria_nome varchar(80) NOT NULL,
	 CONSTRAINT pk_categoria_simples PRIMARY KEY(categoria_nome),
	 CONSTRAINT fk_categoria_simples FOREIGN KEY(categoria_nome)
	 		REFERENCES categoria(categoria_nome));

CREATE TABLE super_categoria
	(categoria_nome varchar(80) NOT NULL,
	 CONSTRAINT pk_super_categoria PRIMARY KEY(categoria_nome),
	 CONSTRAINT fk_categoria FOREIGN KEY(categoria_nome)
	 	REFERENCES categoria(categoria_nome));

CREATE TABLE tem_outra
	(super varchar(80) NOT NULL,
	 sub_categoria varchar(80) NOT NULL UNIQUE,
	 CONSTRAINT pk_sub_categoria PRIMARY KEY(sub_categoria),
	 CONSTRAINT fk_super FOREIGN KEY(super)
		REFERENCES super_categoria(categoria_nome),
	 CONSTRAINT fk_sub_categoria FOREIGN KEY(sub_categoria)
	 	REFERENCES categoria(categoria_nome));

CREATE TABLE produto
	(ean numeric(13, 0) NOT NULL,
	 categoria varchar(80) NOT NULL,
	 descricao varchar(255) NOT NULL,
	 CONSTRAINT pk_ean PRIMARY KEY(ean),
	 CONSTRAINT fk_categoria FOREIGN KEY(categoria)
		REFERENCES categoria(categoria_nome));

CREATE TABLE tem_categoria
	(ean numeric(13, 0) NOT NULL,
	 nome varchar(80) NOT NULL,
	 CONSTRAINT fk_ean FOREIGN KEY(ean)
		REFERENCES produto(ean),
	 CONSTRAINT fk_nome FOREIGN KEY(nome)
		REFERENCES categoria(categoria_nome));

CREATE TABLE IVM
	(numero_serie numeric(15, 0) NOT NULL,
	 fabricante varchar(80) NOT NULL,
	 CONSTRAINT pk_ivm PRIMARY KEY(numero_serie, fabricante));

CREATE TABLE ponto_de_retalho
	(nome varchar(80) NOT NULL,
	 distrito varchar(80) NOT NULL,
	 concelho varchar(80) NOT NULL,
	 CONSTRAINT pk_nome PRIMARY KEY(nome));

CREATE TABLE instalada_em
	(numero_serie numeric(15, 0) NOT NULL,
	 fabricante varchar(80) NOT NULL,
	 local varchar(255) NOT NULL,
	 CONSTRAINT fk_ivm FOREIGN KEY(numero_serie, fabricante)
		REFERENCES IVM(numero_serie, fabricante),
	 CONSTRAINT fk_local FOREIGN KEY(local)
		REFERENCES ponto_de_retalho(nome));

CREATE TABLE prateleira
	(numero numeric(15, 0) NOT NULL,
	 numero_serie numeric(15, 0) NOT NULL,
	 fabricante varchar(80) NOT NULL,
	 altura numeric(3, 0) NOT NULL,
	 categoria varchar(80) NOT NULL,
	 CONSTRAINT pk_prateleira PRIMARY KEY(numero, numero_serie, fabricante),
	 CONSTRAINT fk_ivm FOREIGN KEY(numero_serie, fabricante)
		REFERENCES IVM(numero_serie, fabricante));


CREATE TABLE planograma
	(ean numeric(13, 0) NOT NULL,
	 numero numeric(15, 0) NOT NULL,
	 numero_serie numeric(15, 0) NOT NULL,
	 fabricante varchar(80) NOT NULL,
	 faces numeric (7, 0) NOT NULL,
	 unidades numeric (7, 0) NOT NULL,
	 localizacao varchar(255) NOT NULL,
	 CONSTRAINT pk_planograma PRIMARY KEY(ean, numero, numero_serie, fabricante),
	 CONSTRAINT fk_ean FOREIGN KEY(ean)
		REFERENCES produto(ean),
	 CONSTRAINT fk_prateleira FOREIGN KEY(numero, numero_serie, fabricante)
		REFERENCES prateleira(numero, numero_serie, fabricante));

CREATE TABLE retalhista
	(tin numeric(15, 0) NOT NULL,
	 nome varchar(80) NOT NULL,
	 CONSTRAINT pk_tin PRIMARY KEY(tin));

CREATE TABLE responsavel_por
	(categoria varchar(80) NOT NULL,
	 tin numeric(15, 0) NOT NULL,
	 numero_serie numeric(15, 0) NOT NULL,
	 fabricante varchar(80) NOT NULL,
	 CONSTRAINT pk_responsavel_por PRIMARY KEY(numero_serie, fabricante),
	 CONSTRAINT fk_ivm FOREIGN KEY(numero_serie, fabricante)
		REFERENCES IVM(numero_serie, fabricante),
	 CONSTRAINT fk_tin FOREIGN KEY(tin)
		REFERENCES retalhista(tin),
	 CONSTRAINT fk_categoria FOREIGN KEY(categoria)
		REFERENCES categoria(categoria_nome));

CREATE TABLE evento_reposicao
	(ean numeric(13, 0) NOT NULL,
	 numero numeric(15, 0) NOT NULL,
	 numero_serie numeric(15, 0) NOT NULL,
	 fabricante varchar(80) NOT NULL,
	 instante timestamp NOT NULL,
	 unidades numeric(7, 0) NOT NULL,
	 tin numeric(15, 0) NOT NULL,
	 CONSTRAINT pk_evento_reposicao PRIMARY KEY(ean, numero, numero_serie, fabricante, instante),
	 CONSTRAINT fk_planograma FOREIGN KEY(ean, numero, numero_serie, fabricante)
		REFERENCES planograma(ean, numero, numero_serie, fabricante),
	 CONSTRAINT fk_tin FOREIGN KEY(tin)
		REFERENCES retalhista(tin));

INSERT INTO categoria VALUES
	('chocolates'),
	('batatas fritas'),
	('bebidas'),
	('aguas'),
	('refrigerantes'),
	('bolachas'),
	('carne'),
	('lombo'),
	('bifanas');

INSERT INTO super_categoria VALUES
	('bebidas'),
	('carne'),
	('lombo');

INSERT INTO categoria_simples VALUES
	('aguas'),
	('refrigerantes'),
	('bifanas');

INSERT INTO tem_outra VALUES
	('bebidas', 'aguas'),
	('bebidas', 'refrigerantes'),
	('carne', 'lombo'),
	('lombo', 'bifanas');

INSERT INTO produto VALUES
	(12931996, 'chocolates', 'kit-kat'),
	(24868709, 'chocolates', 'milka'),
	(22498007, 'chocolates', 'twix'),
	(27032831, 'chocolates', 'snickers'),
	(48988780, 'chocolates', 'mars'),
	(67566327, 'chocolates', 'm&ms'),
	(53009302, 'batatas fritas', 'lays'),
	(70529081, 'batatas fritas', 'ruffles'),
	(88230627, 'aguas', 'luso'),
	(45106422, 'aguas', 'vitalis'),
	(52310256, 'refrigerantes', 'coca-cola'),
	(58747940, 'refrigerantes', 'fanta'),
	(77330956, 'refrigerantes', '7up'),
	(45658877, 'refrigerantes', 'sprite'),
	(86410151, 'refrigerantes', 'ice tea'),
	(73235217, 'bolachas', 'oreo'),
	(81366125, 'bolachas', 'belgas'),
	(08177650, 'bolachas', 'filipinos'),
	(55524759, 'bolachas', 'tuc');

INSERT INTO tem_categoria VALUES
	(12931996, 'chocolates'),
	(24868709, 'chocolates'),
	(22498007, 'chocolates'),
	(27032831, 'chocolates'),
	(48988780, 'chocolates'),
	(67566327, 'chocolates'),
	(53009302, 'batatas fritas'),
	(70529081, 'batatas fritas'),
	(88230627, 'aguas'),
	(45106422, 'aguas'),
	(52310256, 'refrigerantes'),
	(58747940, 'refrigerantes'),
	(77330956, 'refrigerantes'),
	(45658877, 'refrigerantes'),
	(86410151, 'refrigerantes'),
	(73235217, 'bolachas'),
	(81366125, 'bolachas'),
	(08177650, 'bolachas'),
	(55524759, 'bolachas');

INSERT INTO IVM VALUES
	(0885798450110, 'sol mar'),
	(5932189084524, 'fidelidade'),
	(8798967965167, 'samsung'),
	(3916861267452, 'fnac');

INSERT INTO ponto_de_retalho VALUES
	('capital', 'lisboa', 'lisboa'),
	('divino', 'santarem', 'fatima'),
	('insular', 'acores', 'ponta delgada');

INSERT INTO instalada_em VALUES
	(0885798450110, 'sol mar', 'insular'),
	(5932189084524, 'fidelidade', 'divino'),
	(8798967965167, 'samsung', 'capital'),
	(3916861267452, 'fnac', 'capital');

INSERT INTO prateleira VALUES
	(1, 0885798450110, 'sol mar', 70, 'bebidas'),
	(2, 5932189084524, 'fidelidade', 70, 'aguas'),
	(3, 8798967965167, 'samsung', 70, 'refrigerantes'),
    (4, 3916861267452, 'fnac', 50, 'bebidas');

INSERT INTO planograma VALUES
	(12931996, 1, 0885798450110, 'sol mar', 5, 15, 'cima'),
	(58747940, 2, 5932189084524, 'fidelidade', 4, 16, 'meio'),
	(70529081, 3, 8798967965167, 'samsung', 5, 10, 'baixo'),
	(27032831, 4, 3916861267452, 'fnac', 6, 24, 'meio');

INSERT INTO retalhista VALUES
	(123456789, 'Filipe'),
	(987654321, 'Antonio'),
	(998877665, 'Maria'),
	(123654789, 'Hamilton');

INSERT INTO responsavel_por VALUES
	('bolachas', 123456789, 0885798450110, 'sol mar'),
	('bebidas', 987654321, 5932189084524, 'fidelidade'),
	('batatas fritas', 998877665, 8798967965167, 'samsung'),
	('chocolates', 123654789, 3916861267452, 'fnac');

INSERT INTO evento_reposicao VALUES
	(12931996, 1, 0885798450110, 'sol mar', '2020-04-20 12:30:02', 8, 123456789),
	(58747940, 2, 5932189084524, 'fidelidade', '2021-03-23 15:12:10', 4, 987654321),
	(58747940, 2, 5932189084524, 'fidelidade', '2021-07-04 07:48:45', 10, 987654321),
    (70529081, 3, 8798967965167, 'samsung', '2022-01-01 01:01:01', 5, 123654789),
    (27032831, 4, 3916861267452, 'fnac', '2022-06-24 23:59:59', 2, 123654789);

