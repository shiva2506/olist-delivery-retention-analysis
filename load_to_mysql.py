import pandas as pd
from pathlib import Path
from sqlalchemy import create_engine

user = "analyst"
password = "YOUR_PASSWORD"
host = "localhost"
port = 3306
database = "olist"

engine = create_engine(f"mysql+pymysql://{user}:{password}@{host}:{port}/{database}")

data_dir = Path("data")

table_names = {
    "olist_customers_dataset.csv": "customers",
    "olist_geolocation_dataset.csv": "geolocation",
    "olist_order_items_dataset.csv": "order_items",
    "olist_order_payments_dataset.csv": "payments",
    "olist_order_reviews_dataset.csv": "order_reviews",
    "olist_orders_dataset.csv": "orders",
    "olist_products_dataset.csv": "products",
    "olist_sellers_dataset.csv": "sellers",
    "product_category_name_translation.csv": "category_translation",
}

for file, table in table_names.items():
    df = pd.read_csv(data_dir / file)
    df.to_sql(table, engine, if_exists="replace", index=False, chunksize=10000)
    print(f"{table}: {len(df)} rows")
