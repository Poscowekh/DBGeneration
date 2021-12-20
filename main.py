import re
import sys
from typing import Dict, Callable, Union, List, Any, Tuple, Iterable
from src.random_entry_factory import RandomEntryFactory, Department
from psycopg2.extras import execute_batch
from psycopg2.extensions import connection, cursor
from psycopg2 import connect
from os import path
from argparse import ArgumentParser, Namespace
from json import load

from datetime import timedelta
current_directory = path.dirname(path.abspath(__file__))


def set_connection_values(parsed_args: Dict) -> str:
    return f"""
        host={parsed_args['host']}
        port={parsed_args['port']} 
        dbname={parsed_args['database']} 
        user={parsed_args['user']} 
        password={parsed_args['password']} 
    """

def get_connection(connection_values: str) -> connection:
    return connect(connection_values)


def execute_script(conn: connection, file_name: str) -> Any:
    """Executes whole script"""
    with conn.cursor() as cur:
        result = cur.execute(open(current_directory + "\\\\" + file_name, "r").read())
    return result

def execute_query(conn: connection, query: str) -> Any:
    """Executes SQL query"""
    with conn.cursor() as cur:
        result = cur.execute(query)
    return result

def insertmany_query(conn: connection, table: str, values: List[Tuple]) -> Any:
    """Executes SQL insert query for a big batch of values"""
    with conn.cursor() as cur:
        result = execute_batch(cur, f"insert into dryclean.{table} values ({'default, ' + '%s, ' * (len(values[0]) - 1) + '%s'}); commit;", values)
    return result


def init(conn: connection, db_name: str) -> None:
    execute_query(conn, f"create database {db_name}; commit; create schema dryclean; commit;")
    print("--Database and schema created.")

def create(conn: connection, db_dump: str) -> None:
    #if db_dump is None:
        execute_script(conn, "sql\\create_tables.sql")
        print("--Database tables created.")

    #else:


def drop(conn: connection) -> None:
    execute_script(conn, "sql\\drop_tables.sql")
    print("--Database tables dropped.")

def recreate(conn: connection) -> None:
    drop(conn)
    create(conn)


def fill(conn: connection) -> None:
    # RandomEntryFactory.create_csvs()
    print("--Generating tables and rows:")
    entries: Dict[type, List[RandomEntry]] = RandomEntryFactory.create_all_tuples()
    print("--Tables and rows generated.")

    print("--Filling database tables:")
    for entry, instances in entries.items():
        insertmany_query(conn, entry.table_name, instances)
        print(f"----filled dryclean.{entry.table_name};")
    print("--Database tables filled.")


def clear(conn: connection) -> None:
    execute_script(conn, "sql\\clear_tables.sql")
    print("--Database tables cleared (using TRUNCATE)")

def queries(conn: connection) -> Any:
    pass


def parse_args(args: List[str]) -> Dict[str, Union[None, bool, str]]:
    parser = ArgumentParser(
        prog="database_generator",
        description="Creates, clears, drops and fills database tables"
    )

    # postgresql args
    parser.add_argument("--host", nargs='?', type=str, default="localhost", action="store", help="host of database server")
    parser.add_argument("--port", nargs='?', type=str, default="5432", action="store", help="port of database server")
    parser.add_argument("--database", "--dbname", "-db", nargs='?', type=str, default="dryclean", action="store", help="database name")
    parser.add_argument("--user", "-u", nargs='?', type=str, default="any_user", action="store", help="database user")
    parser.add_argument("--password", "-p", nargs='?', type=str, default="any_user", action="store", help="password for the database")

    # program args for database
    parser.add_argument("--init", action="store_true", help="creates database and schema if it does not exist")
    parser.add_argument("--create", nargs='?', type=str, default=None, action="store_true", help="creates database tables if they don't exist")
    parser.add_argument("--drop", action="store_true", help="drops database tables if they exist")
    parser.add_argument("--recreate", action="store_true", help="drops and creates database tables")
    parser.add_argument("--fill", action="store_true", help="fills database with randomly generated values")
    parser.add_argument("--layout", nargs='?', type=str, default=None, action="store",
                        help="database layout JSON configuration file: pairs of entry name and instance count")
    parser.add_argument("--clear", action="store_true", help="truncates every table")
    parser.add_argument("--queries", "-q", action="store_true", help="executes all pre-created SQL scripts")

    # additional program args
    parser.add_argument("--execute", "-e", nargs='?', type=str, action="store", help="executes the defined SQL script")
    parser.add_argument("--interactive", "-i", action="store_true", help="enters into interactive mode allowing for executing of entered SQL queries")

    return vars(parser.parse_args())


def interactive(conn: connection) -> None:
    while True:
        saved_line: str = None
        line: str = saved_line + str(input())
        queries = line.split(";")

        if len(queries) > 1:
            for query in queries:
                result = execute_query(query, conn)
                if result:
                    print(result.fetchall())
        else:
            saved_line = line


def main(args: List[str]) -> None:
    parsed_args: Dict[str, Union[None, bool, str]] = parse_args(args)

    conn: connection = get_connection(set_connection_values(parsed_args))

    if parsed_args["init"]:
        init(conn, parsed_args["database"])

    if parsed_args["recreate"]:
        recreate(conn)

    else:
        if parsed_args["drop"]:
            if not parsed_args["init"]:
                drop(conn)
        if parsed_args["create"]:
            create(conn)#, parsed_args["create"])

    if parsed_args["clear"] and not parsed_args["drop"]:
        clear(conn)

    if parsed_args["fill"]:
        if parsed_args["layout"]:
            data: Dict[str, int] = dict()
            with open(parsed_args["layout"], "r") as f:
                data: Dict[str, int] = json.load(f)
            RandomEntryFactory.set_layout(data)

        fill(conn)


    # if "-i" in chosen_options:
    #     interactive(conn)


# entry point
if __name__ == "__main__":
    try:
        main(sys.argv[1:])

    except Exception as e:
        print("Error: ", e)
        exit(1)

    except KeyboardInterrupt:
        print("Interrupt detected")
        exit(2)

else:
    print("Not run as main, exitting")
    exit(1)
