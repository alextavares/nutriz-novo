import json

def clean_value(val):
    if val is None:
        return 0.0
    if isinstance(val, str):
        val = val.strip().upper()
        if val in ["NA", "TR", "", "*"]:
            return 0.0
    try:
        return float(val)
    except:
        return 0.0

def main():
    try:
        with open('taco_full.json', 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception as e:
        print(f"Error loading JSON: {e}")
        return

    sql_statements = []
    
    # Create Table Statement
    sql_statements.append("DROP TABLE IF EXISTS foods;")
    sql_statements.append("""
CREATE TABLE foods (
    id TEXT PRIMARY KEY,
    name TEXT,
    brand TEXT,
    calories REAL,
    protein REAL,
    carbs REAL,
    fat REAL,
    fiber REAL,
    servingSize TEXT
);""")

    # Index for search performance
    sql_statements.append("CREATE INDEX idx_foods_name ON foods(name);")

    for item in data:
        # Map TACO keys to our schema
        # TACO keys: description, energy_kcal, protein_g, carbohydrate_g, lipid_g, fiber_g
        food_id = f"taco_{item.get('id')}"
        name = item.get('description', '').replace("'", "''")
        brand = "TACO"
        calories = clean_value(item.get('energy_kcal'))
        protein = clean_value(item.get('protein_g'))
        carbs = clean_value(item.get('carbohydrate_g'))
        fat = clean_value(item.get('lipid_g'))
        fiber = clean_value(item.get('fiber_g'))
        servingSize = "100g"

        sql = f"INSERT INTO foods (id, name, brand, calories, protein, carbs, fat, fiber, servingSize) VALUES ('{food_id}', '{name}', '{brand}', {calories}, {protein}, {carbs}, {fat}, {fiber}, '{servingSize}');"
        sql_statements.append(sql)

    with open('taco_migration.sql', 'w', encoding='utf-8') as f:
        f.write('\n'.join(sql_statements))

    print(f"Successfully generated taco_migration.sql with {len(data)} items.")

if __name__ == "__main__":
    main()
