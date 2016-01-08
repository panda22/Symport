Chef::Log.info("Ensuring that uuid extension is available...")

sql_code = "'create extension if not exists \"uuid-ossp\";'"
db_node = node["deploy"]["symport"]["database"]
password = db_node["password"]
host = db_node["host"]
db = db_node["database"]
user = db_node["username"]

ENV["PGPASSWORD"] = password
execute "psql #{db} #{user} -h #{host} -c #{sql_code}"

