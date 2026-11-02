import sqlite3
import os

db_path = 'calamba_prices.db'
print('DB exists:', os.path.exists(db_path))

if os.path.exists(db_path):
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    cur.execute('SELECT COUNT(DISTINCT commodity) FROM prices')
    count = cur.fetchone()[0]
    print('Commodities count:', count)
    
    cur.execute('SELECT DISTINCT commodity FROM prices ORDER BY commodity')
    commodities = cur.fetchall()
    print('Commodities:', [c[0] for c in commodities])
    
    conn.close()
else:
    print('Database not found')