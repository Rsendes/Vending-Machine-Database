#!/usr/bin/python3
from wsgiref.handlers import CGIHandler
from flask import Flask
from flask import render_template
from flask import request
from flask import redirect
from flask import url_for

import psycopg2
import psycopg2.extras


DB_HOST="db.tecnico.ulisboa.pt"
DB_USER="ist1100721"
DB_DATABASE=DB_USER
DB_PASSWORD="antonio"
DB_CONNECTION_STRING = "host=%s dbname=%s user=%s password=%s" % (DB_HOST, DB_DATABASE, DB_USER, DB_PASSWORD,)

app = Flask(__name__)

@app.route("/cats")
def list_cats():
	dbConn=None
	cursor=None
	try:
		dbConn = psycopg2.connect(DB_CONNECTION_STRING)
		cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
		query = "SELECT * FROM categoria;"
		cursor.execute(query)
		return render_template("cats.html", cursor=cursor)
	except Exception as e:
		return str(e)
	finally:
		cursor.close()
		dbConn.close()

@app.route("/remover_cat")
def remove_cat():
	dbConn=None
	cursor=None
	try:
		dbConn = psycopg2.connect(DB_CONNECTION_STRING)
		cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
		cat_to_remove = request.args.get("nome")
		data = (cat_to_remove, cat_to_remove)

		cursor.execute("START TRANSACTION;")

		query = "DELETE FROM tem_outra WHERE tem_outra.sub_categoria=%s OR tem_outra.super=%s;"
		cursor.execute(query, data)

		data = (cat_to_remove,)
		query = "DELETE FROM categoria_simples WHERE categoria_simples.categoria_nome = %s;"
		cursor.execute(query, data)
		query = "DELETE FROM super_categoria WHERE super_categoria.categoria_nome = %s;"
		cursor.execute(query, data)
		query = "DELETE FROM responsavel_por WHERE responsavel_por.categoria = %s;"
		cursor.execute(query, data)
		query = "DELETE FROM evento_reposicao USING tem_categoria WHERE evento_reposicao.ean = tem_categoria.ean AND tem_categoria.nome=%s;"
		cursor.execute(query, data)
		query = "DELETE FROM planograma USING tem_categoria WHERE planograma.ean = tem_categoria.ean AND tem_categoria.nome=%s;"
		cursor.execute(query, data)
		query = "DELETE FROM tem_categoria WHERE nome=%s;"
		cursor.execute(query, data)
		query = "DELETE FROM produto WHERE categoria=%s;"
		cursor.execute(query, data)
		query = "DELETE FROM categoria WHERE categoria_nome=%s;"
		cursor.execute(query, data)

		cursor.execute("COMMIT;")

		return redirect("cats")
	except Exception as e:
		return str(e)
	finally:
		dbConn.commit()
		cursor.close()
		dbConn.close()


@app.route("/nova_cat")
def add_cat():
	dbConn=None
	cursor=None
	try:
		dbConn = psycopg2.connect(DB_CONNECTION_STRING)
		cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
		return render_template("nova_cat.html")
	except Exception as e:
		return str(e)
	finally:
		cursor.close()
		dbConn.close()

@app.route("/insert_cat", methods=["POST"])
def update_cats():
	dbConn=None
	cursor=None
	try:
		dbConn = psycopg2.connect(DB_CONNECTION_STRING)
		cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
		nome = request.form["nome"]

		cursor.execute("START TRANSACTION;")

		query = "INSERT INTO categoria VALUES (%s);"
		data = (nome,)
		cursor.execute(query, data)

		cursor.execute("COMMIT;")

		return redirect("cats")
	except Exception as e:
		return str(e)
	finally:
		dbConn.commit()
		cursor.close()
		dbConn.close()

@app.route("/sub_cats")
def list_sub_cats():
	dbConn=None
	cursor=None
	try:
		dbConn = psycopg2.connect(DB_CONNECTION_STRING)
		cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
		query = "SELECT sub_categoria FROM tem_outra;"
		cursor.execute(query)
		return render_template("subcats.html", cursor=cursor)
	except Exception as e:
		return str(e)
	finally:
		cursor.close()
		dbConn.close()


@app.route("/remover_sub_cat")
def remove_sub_cat():
	dbConn=None
	cursor=None
	try:
		dbConn = psycopg2.connect(DB_CONNECTION_STRING)
		cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
		cat_to_remove = request.args.get("nome")
		data = (cat_to_remove,)

		cursor.execute("START TRANSACTION;")

		query = "DELETE FROM tem_outra WHERE tem_outra.sub_categoria=%s;"
		cursor.execute(query, data)
		query = "DELETE FROM categoria_simples WHERE categoria_simples.categoria_nome = %s;"
		cursor.execute(query, data)
		query = "DELETE FROM responsavel_por WHERE responsavel_por.categoria = %s;"
		cursor.execute(query, data)
		query = "DELETE FROM evento_reposicao USING tem_categoria WHERE evento_reposicao.ean = tem_categoria.ean AND tem_categoria.nome=%s;"
		cursor.execute(query, data)
		query = "DELETE FROM planograma USING tem_categoria WHERE planograma.ean = tem_categoria.ean AND tem_categoria.nome=%s;"
		cursor.execute(query, data)
		query = "DELETE FROM tem_categoria WHERE nome=%s;"
		cursor.execute(query, data)
		query = "DELETE FROM produto WHERE categoria=%s;"
		cursor.execute(query, data)

		cursor.execute("COMMIT;")

		return redirect("sub_cats")
	except Exception as e:
		return str(e)
	finally:
		dbConn.commit()
		cursor.close()
		dbConn.close()


@app.route("/nova_sub_cat")
def add_sub_cat():
	dbConn=None
	cursor=None
	try:
		dbConn = psycopg2.connect(DB_CONNECTION_STRING)
		cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
		cursor.execute("SELECT * FROM tem_outra")
		return render_template("nova_subcat.html", cursor=cursor)
	except Exception as e:
		return str(e)
	finally:
		cursor.close()
		dbConn.close()

@app.route("/insert_sub_cat", methods=["POST"])
def insert_sub_cat():
	dbConn=None
	cursor=None
	try:
		dbConn = psycopg2.connect(DB_CONNECTION_STRING)
		cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)

		nome_sup = request.form["nome_super"]
		nome_sub = request.form["nome_sub"]
		cursor.execute("START TRANSACTION;")
		cursor.execute("INSERT INTO categoria VALUES (%s), (%s) ON CONFLICT (categoria_nome) DO NOTHING", (nome_sub, nome_sup))
		cursor.execute("INSERT INTO super_categoria VALUES (%s) ON CONFLICT DO NOTHING;", (nome_sup,))
		data = (nome_sup, nome_sub)
		query = "INSERT INTO tem_outra VALUES(%s, %s);"
		cursor.execute(query, data)
		cursor.execute("COMMIT;")
		return redirect("sub_cats")
	except Exception as e:
		return str(e)
	finally:
		dbConn.commit()
		cursor.close()
		dbConn.close()

@app.route("/retalhista")
def insert_retailer():
	dbConn=None
	cursor=None
	try:
		dbConn = psycopg2.connect(DB_CONNECTION_STRING)
		cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
		cursor.execute("SELECT * FROM retalhista;")
		return render_template("retalhista.html", cursor=cursor)
	except Exception as e:
		return str(e)
	finally:
		dbConn.close()
		cursor.close()

@app.route("/add_retalhista", methods=["POST"])
def add_retailer():
	dbConn=None
	cursor=None
	try:
		dbConn = psycopg2.connect(DB_CONNECTION_STRING)
		cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
		tin = request.form["tin"]
		nome_retalhista = request.form["nome_retalhista"]
		data = (tin, nome_retalhista)
		cursor.execute("START TRANSACTION;")
		query = "INSERT INTO retalhista VALUES (%s, %s);"
		cursor.execute(query, data)
		cursor.execute("COMMIT;")
		return redirect("retalhista")
	except Exception as e:
		return str(e)
	finally:
		dbConn.commit()
		dbConn.close()
		cursor.close()

@app.route("/remover_retalhista")
def remove_retailer():
	dbConn=None
	cursor=None
	try:
		dbConn = psycopg2.connect(DB_CONNECTION_STRING)
		cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
		tin = request.args.get("tin")
		cursor.execute("START TRANSACTION;")


		query = "DELETE FROM evento_reposicao WHERE evento_reposicao.tin=%s"
		cursor.execute(query, (tin,))

		query = "DELETE FROM evento_reposicao WHERE evento_reposicao.ean IN (SELECT ean FROM tem_categoria NATURAL JOIN responsavel_por WHERE responsavel_por.tin=%s)"
		cursor.execute(query, (tin,))
		query = "DELETE FROM planograma WHERE planograma.ean IN (SELECT ean FROM tem_categoria NATURAL JOIN responsavel_por WHERE responsavel_por.tin =%s)"
		cursor.execute(query, (tin,))

		query = "DELETE FROM tem_categoria USING responsavel_por WHERE tem_categoria.nome = responsavel_por.categoria AND responsavel_por.tin=%s"
		cursor.execute(query, (tin,))

		query = "DELETE FROM produto USING responsavel_por WHERE produto.categoria = responsavel_por.categoria AND responsavel_por.tin=%s"
		cursor.execute(query, (tin,))

		query = "DELETE FROM responsavel_por WHERE responsavel_por.tin=%s"
		cursor.execute(query, (tin,))

		query = "DELETE FROM retalhista WHERE retalhista.tin = %s"
		cursor.execute(query, (tin,))

		cursor.execute("COMMIT;")
		return redirect("retalhista")
	except Exception as e:
		return str(e)
	finally:
		dbConn.commit()
		dbConn.close()
		cursor.close()

@app.route("/id_ivm")
def query_ivm():
	dbConn=None
	cursor=None
	try:
		dbConn = psycopg2.connect(DB_CONNECTION_STRING)
		cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
		cursor.execute("SELECT * FROM IVM;")
		return render_template("id_ivm.html", cursor=cursor)
	except Exception as e:
		return str(e)

@app.route("/reposicoes_ivm", methods=["POST"])
def show_replenishment_ivm():
	dbConn=None
	cursor=None
	try:
		dbConn = psycopg2.connect(DB_CONNECTION_STRING)
		cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
		nr_serie = request.form["serie"]
		fabricante = request.form["fabricante"]
		data = (nr_serie, fabricante)
		query = '''SELECT numero_serie, fabricante, categoria, sum(unidades)
				   FROM evento_reposicao NATURAL JOIN produto
				   WHERE evento_reposicao.numero_serie=%s AND evento_reposicao.fabricante=%s
				   GROUP BY evento_reposicao.numero_serie, evento_reposicao.fabricante, produto.categoria;
				   '''
		cursor.execute(query, data)
		return render_template("show_reposicoes.html", cursor=cursor)
	except Exception as e:
		return str(e)
	finally:
		dbConn.close()
		cursor.close()

@app.route("/sub_cat_recursivo")
def mostrar_subcat_recursivo():
	dbConn=None
	cursor=None
	try:
		dbConn = psycopg2.connect(DB_CONNECTION_STRING)
		cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
		cursor.execute("SELECT * FROM tem_outra;")
		return render_template("subcat_recur.html", cursor=cursor)
	except Exception as e:
		return str(e)
	finally:
		dbConn.close()
		cursor.close()

@app.route("/resultado_pesquisa_recur", methods=["POST"])
def mostrar_results_recur():
	dbConn=None
	cursor=None
	try:
		dbConn = psycopg2.connect(DB_CONNECTION_STRING)
		cursor = dbConn.cursor(cursor_factory = psycopg2.extras.DictCursor)
		super_cat = request.form["super_cat"]
		query ='''
				WITH RECURSIVE rec_subcat AS (
					SELECT super FROM tem_outra WHERE tem_outra.super=%s
					UNION
					SELECT sub.sub_categoria FROM tem_outra sub
					WHERE sub.sub_categoria = sub.super
				)SELECT * FROM rec_subcat;
				'''
		cursor.execute(query, (super_cat,))
		return render_template("show_subcat_recur.html", cursor=cursor)
	except Exception as e:
		return str(e)
	finally:
		dbConn.close()
		cursor.close()

CGIHandler().run(app)
