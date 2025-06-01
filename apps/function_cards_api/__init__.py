import logging
import azure.functions as func
import psycopg2
import os
import json

# === Configuration ===
DB_HOST = os.getenv("POSTGRES_HOST", "pg-azure-db-kz-db.postgres.database.azure.com")
DB_USER = os.getenv("POSTGRES_USER", "pgadminuser")
DB_PASSWORD = os.getenv("POSTGRES_PASSWORD", "password1234")
DB_NAME = "mydatabase"
TABLE_NAME = "cards"

# === Database Connection ===
def get_db_connection():
    return psycopg2.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        dbname=DB_NAME,
        port=5432
    )

# === Database Operations ===

def insert_card(name, tokens):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(f'''
        INSERT INTO {TABLE_NAME} (name, tokens)
        VALUES (%s, %s)
        RETURNING id;
    ''', (name, tokens))
    inserted_id = cur.fetchone()[0]
    conn.commit()
    cur.close()
    conn.close()
    return inserted_id

def update_card(card_id, name, tokens):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(f'''
        UPDATE {TABLE_NAME}
        SET name = %s, tokens = %s
        WHERE id = %s;
    ''', (name, tokens, card_id))
    conn.commit()
    cur.close()
    conn.close()

def get_card_by_id(card_id):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(f'''
        SELECT id, name, tokens
        FROM {TABLE_NAME}
        WHERE id = %s;
    ''', (card_id,))
    result = cur.fetchone()
    cur.close()
    conn.close()
    return result

def get_all_cards():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(f'''
        SELECT id, name, tokens
        FROM {TABLE_NAME};
    ''')
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return [{'id': row[0], 'name': row[1], 'tokens': row[2]} for row in rows]

# === Azure Function Entry Point ===
def main(req: func.HttpRequest) -> func.HttpResponse:
    method = req.method.upper()

    if method == "GET":
        card_id = req.params.get('id')

        if card_id:
            result = get_card_by_id(card_id)
            if result:
                return func.HttpResponse(
                    json.dumps({'id': result[0], 'name': result[1], 'tokens': result[2]}),
                    status_code=200,
                    mimetype="application/json"
                )
            else:
                return func.HttpResponse(
                    json.dumps({"error": f"Card with ID {card_id} not found."}),
                    status_code=404,
                    mimetype="application/json"
                )
        else:
            all_cards = get_all_cards()
            return func.HttpResponse(
                json.dumps(all_cards),
                status_code=200,
                mimetype="application/json"
            )

    elif method == "POST":
        try:
            req_body = req.get_json()
        except ValueError:
            return func.HttpResponse(
                json.dumps({"error": "Invalid JSON."}),
                status_code=400,
                mimetype="application/json"
            )

        name = req_body.get('name')
        tokens = req_body.get('tokens')

        if not name or tokens is None:
            return func.HttpResponse(
                json.dumps({"error": "Missing 'name' or 'tokens' in the request body."}),
                status_code=400,
                mimetype="application/json"
            )

        inserted_id = insert_card(name, tokens)
        return func.HttpResponse(
            json.dumps({"message": "Card created.", "id": inserted_id}),
            status_code=201,
            mimetype="application/json"
        )
    
    elif method == "PUT":
        try:
            req_body = req.get_json()
        except ValueError:
            return func.HttpResponse(
                json.dumps({"error": "Invalid JSON."}),
                status_code=400,
                mimetype="application/json"
            )

        card_id = req.params.get('id')
        name = req_body.get('name')
        tokens = req_body.get('tokens')

        if not card_id or not name or tokens is None:
            return func.HttpResponse(
                json.dumps({"error": "Missing 'id', 'name', or 'tokens' in the request body."}),
                status_code=400,
                mimetype="application/json"
            )

        # Update logic would go here (not implemented in this example)
        update_card(card_id, name, tokens)
        # Assuming update_card function is defined to handle the update
        return func.HttpResponse(
            json.dumps({"message": "Card updated.", "id": card_id}),
            status_code=200,
            mimetype="application/json"
        )

    return func.HttpResponse(
        json.dumps({"error": "Invalid HTTP method."}),
        status_code=405,
        mimetype="application/json"
    )
