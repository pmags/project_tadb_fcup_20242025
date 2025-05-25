import psycopg2

def connect_db(dbname: str = "postgres", user: str = "postgres", password: str = "postgres", host: str = "db" ) -> psycopg2.extensions.connection:
    return psycopg2.connect(
        dbname=dbname,
        user=user,
        password=password,
        host=host
    )