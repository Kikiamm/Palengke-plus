#!/usr/bin/env python3
import sqlite3
import os
from pathlib import Path

# Use the database path
BASE_DIR = Path(__file__).resolve().parent.parent / "backend"
DB_PATH = str(BASE_DIR / "calamba_prices.db")

# Check if the database exists and has all 23 commodities
if os.path.exists(DB_PATH):
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()
    
    # Check if all 23 commodities are present
    all_commodities = [
        "well-milled rice", "regular milled rice", "premium 5% broken rice", "yellow corn",
        "ampalaya", "kamatis", "talong", "repolyo", "sitaw", "kalabasa", "carrots",
        "red onion", "white onion", "bawang", "luya", "pork liempo", "pork kasim", "beef rump",
        "chicken (whole)", "eggs (medium)", "bangus", "tilapia", "galunggong"
    ]
    
    # Query for existing commodities
    cur.execute("SELECT DISTINCT commodity FROM prices")
    existing_commodities = [row[0] for row in cur.fetchall()]
    
    missing_commodities = [commodity for commodity in all_commodities if commodity not in existing_commodities]
    
    print("All 23 commodities in the database:")
    print(f"Total commodities in DB: {len(existing_commodities)}")
    print(f"Missing commodities: {missing_commodities}")
    
    if missing_commodities:
        print("Some commodities are missing from the database!")
    else:
        print("All 23 commodities are present in the database.")
    
    conn.close()
else:
    print(f"Database file not found: {DB_PATH}")