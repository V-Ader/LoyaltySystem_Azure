import logging
import azure.functions as func
import psycopg2
import os

# PostgreSQL connection details from app settings
DB_HOST = os.getenv("POSTGRES_HOST")
DB_USER = os.getenv("POSTGRES_USER")
DB_PASSWORD = os.getenv("POSTGRES_PASSWORD")
DB_NAME = "mydatabase"  # Replace with your actual DB name

# Connect to PostgreSQL Database
def get_db_connection():
    conn = psycopg2.connect(host='pg-azure-db-kz-db.postgres.database.azure.com', user='pgadminuser',
                              password='password1234', 
                              dbname='mydatabase', port=5432)
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
    conn.close()
    return result

def main(req: func.HttpRequest) -> func.HttpResponse:
    method = req.method
    if method == "GET":
        # Retrieve the ID from query parameter
        record_id = req.params.get('id')
        if not record_id:
            return func.HttpResponse("Missing 'id' parameter", status_code=400)
        
        # Get data from PostgreSQL
        result = get_data_by_id(record_id)
        if result:
            return func.HttpResponse(f"ID: {result[0]}, Name: {result[1]}, Value: {result[2]}", status_code=200)
        else:
            return func.HttpResponse(f"Record with ID {record_id} not found.", status_code=404)

    elif method == "POST":
        # Get data from request body
        req_body = req.get_json()
        name = req_body.get('name')
        value = req_body.get('value')

        if not name or not value:
            return func.HttpResponse("Missing 'name' or 'value' in the request body.", status_code=400)

        # Insert data into PostgreSQL
        inserted_id = insert_data(name, value)
        return func.HttpResponse(f"Record created with ID: {inserted_id}", status_code=201)

    return func.HttpResponse("Invalid method", status_code=405)
