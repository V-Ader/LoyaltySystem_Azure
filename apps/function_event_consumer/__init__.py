import azure.functions as func
import psycopg2
import os
import json
from azure.eventhub import EventHubProducerClient, EventData
import logging

# === Configuration ===
DB_HOST = os.getenv("POSTGRES_HOST")
DB_USER = os.getenv("POSTGRES_USER")
DB_PASSWORD = os.getenv("POSTGRES_PASSWORD")
DB_NAME = "mydatabase"
TABLE_NAME = "cards" 
TABLE_LOGS_NAME = "logs"


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

    if action == "update" and card_id is not None:
        cur.execute(f"""
            SELECT name, tokens FROM {TABLE_NAME} WHERE id = %s;
        """, (card_id,))
        row = cur.fetchone()
        if row:
            name, tokens = row
            new_tokens = max(tokens - 1, 0)
            cur.execute(f"""
                UPDATE {TABLE_NAME}
                SET tokens = %s
                WHERE id = %s;
            """, (new_tokens, card_id))
            logging.info(f"Updated card id={card_id}: name={name}, tokens {tokens} -> {new_tokens}")
            send_log_event({
                "action": action,
                "id": card_id,
                "user_name": event.get('user_name'),
                "log_message": f"Updated card with ID {card_id}, with name = {name}. Tokens changed from {tokens} to {new_tokens}"
            })
        else:
            logging.warning(f"Card with id={card_id} not found.")
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
            logging.info(f"Event processed: {event_json}")
        except Exception as e:
            logging.error(f"Failed to process event: {e}")
import logging