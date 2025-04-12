import asyncpg
import asyncio

async def test_connection():
    # Database connection parameters
    host = 'loyalty-postgres-dev.postgres.database.azure.com'
    database = 'loyaltydb'
    user = 'pgadmin@loyalty-postgres-dev'
    password = 'SuperSuperStrongPassword!@#'

    # Connect to the database
    try:
        conn = await asyncpg.connect(
            host=host,
            database=database,
            user=user,
            password=password
        )
        print("Connection successful!")

        # You can run a test query here to verify the connection
        result = await conn.fetch('SELECT current_database();')
        print(f"Connected to database: {result[0]['current_database']}")

        # Close the connection
        await conn.close()
    except Exception as e:
        print(f"Failed to connect: {e}")

# Run the test
asyncio.run(test_connection())
