import os
import sys
import psycopg2
from typing import Tuple


def get_db_credentials() -> Tuple[str, str]:
    try:
        db_username = os.environ["DB_USERNAME"]
        db_password = os.environ["DB_PASSWORD"]
    except KeyError as e:
        sys.exit(f"Error: Environment variable {e} not set.")
    else:
        return db_username, db_password


DB_NAME = "data"
DB_USERNAME, DB_PASSWORD = get_db_credentials()


def setup_database():
    """
    Sets up the database with the necessary tables.
    """

    if os.path.isfile(DB_NAME):
        print(f"Database {DB_NAME} already exists.")
        return

    conn = connect_db()
    cursor = conn.cursor()

    with open("schema.sql") as f:
        cursor.execute(f.read())

    close_db(conn)
    print(f"Database {DB_NAME} is set up with the necessary tables.")


def connect_db():
    return psycopg2.connect(
        host="localhost",
        database=DB_NAME,
        user=DB_USERNAME,
        password=DB_PASSWORD,
    )


def close_db(conn):
    conn.commit()
    conn.close()


if __name__ == "__main__":
    setup_database()
