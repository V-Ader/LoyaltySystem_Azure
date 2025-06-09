import logging
import azure.functions as func
import psycopg2
import os
import json
from azure.eventhub import EventHubProducerClient, EventData

# === Configuration ===
DB_HOST = os.getenv("POSTGRES_HOST")
DB_USER = os.getenv("POSTGRES_USER")
DB_PASSWORD = os.getenv("POSTGRES_PASSWORD")
DB_NAME = "mydatabase"
TABLE_NAME = "cards"

# Event Hub config
EVENT_HUB_CONN_STR = os.getenv("EVENT_HUB_CONN_STR")
EVENT_HUB_NAME = os.getenv("EVENT_HUB_NAME")

EVENT_HUB_LOGS_CONN_STR = os.getenv("EVENT_HUB_CONN_LOGS_STR")
EVENT_HUB_LOGS_NAME = os.getenv("EVENT_HUB_LOGS_NAME")

def send_log_event(log_data):
    if not EVENT_HUB_LOGS_CONN_STR or not EVENT_HUB_LOGS_NAME:
        logging.warning("Log Event Hub connection string or name not set.")
        return
    try:
        producer = EventHubProducerClient.from_connection_string(
            conn_str=EVENT_HUB_LOGS_CONN_STR, eventhub_name=EVENT_HUB_LOGS_NAME
        )
        event = EventData(json.dumps(log_data))
        with producer:
            producer.send_batch([event])
    except Exception as e:
        logging.error(f"Failed to send log event: {e}")

def send_event_to_eventhub(event_data):
    if not EVENT_HUB_CONN_STR or not EVENT_HUB_NAME:
        logging.warning("Event Hub connection string or name not set. Skipping event send.")
        return
    try:
        producer = EventHubProducerClient.from_connection_string(
            conn_str=EVENT_HUB_CONN_STR, eventhub_name=EVENT_HUB_NAME
        )
        event = EventData(json.dumps(event_data))
        with producer:
            producer.send_batch([event])
    except Exception as e:
        logging.error(f"Failed to send event to Event Hub: {e}")

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
    send_log_event({
        "action": "insert",
        "id": inserted_id,
        "user_name": name,
        "log_message": f"Card created with ID {inserted_id} and tokens {tokens}",
    })
    return inserted_id

def delete_card(card_id):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(f'''
        DELETE FROM {TABLE_NAME}
        WHERE id = %s
        RETURNING id;
    ''', (card_id,))
    deleted_id = cur.fetchone()[0]
    conn.commit()
    cur.close()
    conn.close()
    send_log_event({
        "action": "delete",
        "id": deleted_id,
        "user_name": "???",
        "log_message": f"Card deleted with ID {deleted_id}",
    })
    return deleted_id

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
    

    elif method == "DELETE":
        try:
            req_body = req.get_json()
        except ValueError:
            return func.HttpResponse(
                json.dumps({"error": "Invalid JSON."}),
                status_code=400,
                mimetype="application/json"
            )

        id = req_body.get('id')

        inserted_id = delete_card(id)
        return func.HttpResponse(
            json.dumps({"message": "Card deleted.", "id": inserted_id}),
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

        card_id = req_body.get('id')
        send_event_to_eventhub({"action": "update", "id": card_id})
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
