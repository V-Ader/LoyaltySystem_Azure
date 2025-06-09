import logging
import azure.functions as func
import psycopg2
import os
import json

# === Configuration ===
DB_HOST = os.getenv("POSTGRES_HOST")
DB_USER = os.getenv("POSTGRES_USER")
DB_PASSWORD = os.getenv("POSTGRES_PASSWORD")
DB_NAME = "mydatabase"
TABLE_NAME = "logs" 

def get_db_connection():
    return psycopg2.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        dbname=DB_NAME,
        port=5432
    )

def process_event_to_db(event):
    conn = get_db_connection()
    cur = conn.cursor()
    action = event.get('action')
    card_id = event.get('id')
    user_name = event.get('user_name')
    log_message = event.get('log_message') or json.dumps(event)
    cur.execute(f"""
        INSERT INTO {TABLE_NAME} (action, card_id, user_name, log_message)
        VALUES (%s, %s, %s, %s);
    """, (action, card_id, user_name, log_message))
    conn.commit()
    cur.close()
    conn.close()

def main(events: func.EventHubEvent):
    if not isinstance(events, list):
        events = [events]
    for event in events:
        try:
            event_body = event.get_body().decode('utf-8')
            event_json = json.loads(event_body)
            process_event_to_db(event_json)
            logging.info(f"Log event saved: {event_json}")
        except Exception as e:
            logging.error(f"Failed to process log event: {e}")
