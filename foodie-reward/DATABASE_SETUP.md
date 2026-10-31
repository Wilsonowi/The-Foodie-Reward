# FoodieReward database setup

FoodieReward supports two database modes without changing the interface.

## Local mode — available now

The default mode uses a free, file-based H2 database. It is configured in `src/main/resources/application.properties` and stores its files in the project `data` folder.

Start it with:

```powershell
.\mvnw.cmd spring-boot:run
```

Open <http://localhost:8081>.

## Oracle mode

Oracle mode uses:

- Oracle JDBC for the application connection
- Flyway to create and version the schema
- `PKG_FOODIE_REWARDS` for all existing write operations
- Spring transactions, so the Java service controls commit and rollback

The Oracle migrations are applied in this order:

1. `V1__create_foodie_schema.sql`
2. `V2__create_foodie_plsql_package.sql`
3. `V3__seed_foodie_demo_data.sql`

Create an empty Oracle user/schema with permission to create tables, procedures, and indexes. Then configure the connection in PowerShell:

```powershell
$env:FOODIE_DB_URL = "jdbc:oracle:thin:@localhost:1521/FREEPDB1"
$env:FOODIE_DB_USERNAME = "foodie_app"
$env:FOODIE_DB_PASSWORD = "your-password"
.\mvnw.cmd spring-boot:run "-Dspring-boot.run.profiles=oracle"
```

Flyway will create the tables, compile the package, and insert the demonstration records on the first Oracle launch. Later launches apply only new migrations.

## Application flow

```text
React interface
      |
      v
Spring Boot REST controller
      |
      v
FoodieOperations
  |               |
  v               v
Local JDBC     Oracle PL/SQL package
  |               |
  v               v
H2 database    Oracle database
```

Both implementations return the same data shape, so the interface and its existing features do not change when switching databases.
