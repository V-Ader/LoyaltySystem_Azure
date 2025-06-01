import logging
import azure.functions as func
import psycopg2
import os
import json

# PostgreSQL connection details from app settings
DB_HOST = os.getenv("POSTGRES_HOST")
DB_USER = os.getenv("POSTGRES_USER")
DB_PASSWORD = os.getenv("POSTGRES_PASSWORD")
DB_NAME = "mydatabase"  # Replace with your actual DB name

# Connect to PostgreSQL Database
def get_db_connection():
    conn = psycopg2.connect(
        host='pg-azure-db-kz-db.postgres.database.azure.com',
        user='pgadminuser',
        password='password1234',
        dbname='mydatabase',
        port=5432
    )
    return conn

# POST: Insert data into PostgreSQL
def insert_data(name, value):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('INSERT INTO my_table (name, value) VALUES (%s, %s) RETURNING id;', (name, value))
    inserted_id = cur.fetchone()[0]
    conn.commit()
    cur.close()
    conn.close()
    return inserted_id

# GET: Retrieve data by ID
def get_data_by_id(record_id):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT id, name, value FROM my_table WHERE id = %s;', (record_id,))
    result = cur.fetchone()
    cur.close()
    conn.close()
    return result

# GET: Retrieve all data
def get_all_data():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT id, name, value FROM my_table;')
    rows = cur.fetchall()
    cur.close()
    conn.close()
    # Convert the rows into a list of dictionaries
    result = [{'id': row[0], 'name': row[1], 'value': row[2]} for row in rows]
    return result

# Azure Function main entry point
def main(req: func.HttpRequest) -> func.HttpResponse:
    method = req.method

    if method == "GET":
        record_id = req.params.get('id')

        if record_id:
            # Get data by ID
            result = get_data_by_id(record_id)
            if result:
                return func.HttpResponse(
                    json.dumps({'id': result[0], 'name': result[1], 'value': result[2]}),
                    status_code=200,
                    mimetype="application/json"
                )
            else:
                return func.HttpResponse(f"Record with ID {record_id} not found.", status_code=404)
        else:
            # ✅ Return all data as JSON
            all_data = get_all_data()
            return func.HttpResponse(
                json.dumps(all_data),
                status_code=200,
                mimetype="application/json"
            )

    elif method == "POST":
        try:
            req_body = req.get_json()
        except ValueError:
            return func.HttpResponse("Invalid JSON", status_code=400)

        name = req_body.get('name')
        value = req_body.get('value')

        if not name or not value:
            return func.HttpResponse("Missing 'name' or 'value' in the request body.", status_code=400)

        inserted_id = insert_data(name, value)
        return func.HttpResponse(f"Record created with ID: {inserted_id}", status_code=201)

    return func.HttpResponse("Invalid method", status_code=405)
