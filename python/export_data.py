import pandas as pd
from pathlib import Path
from sqlalchemy import create_engine

engine = create_engine("mysql+pymysql://analyst:YOUR_PASSWORD@localhost:3306/olist")

Path("exports").mkdir(exist_ok=True)

for table in ["orders_clean", "customer_value"]:
    df = pd.read_sql(f"SELECT * FROM {table}", engine)
    df.to_csv(f"exports/{table}.csv", index=False)
    print(table, ":", len(df), "rows")
