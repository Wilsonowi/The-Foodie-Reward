# FoodieReward

FoodieReward is a full-stack points and rewards management application based on the Group G37 project interface. It supports customer memberships, point balances, reward inventory, redemptions, and transaction records. Actions in the interface are handled by a Java backend and stored in a relational database.

## Features

- View customer, membership, points, rewards, redemption, and transaction records.
- Earn points from a purchase amount.
- Change membership and redemption statuses.
- Redeem rewards and restock reward inventory.
- Complete transactions and remove failed transactions.
- Store changes in a persistent local database.
- Run with either H2 for local development or Oracle Database with PL/SQL.

## Technology

- Java 17 and Spring Boot 4
- Spring MVC REST API and JDBC
- H2 for local development
- Oracle Database, Oracle JDBC, and the `PKG_FOODIE_REWARDS` PL/SQL package
- Flyway for Oracle schema migrations
- React interface served by Spring Boot

The interface loads React, ReactDOM, Babel, and fonts from external CDNs, so an internet connection is needed when loading the page unless those assets are made local.

## Run locally with H2

Requirements: Java 17 or later. No separate database installation is needed for H2.

Open PowerShell at the G37 project root and run:

```powershell
cd .\foodie-reward
.\mvnw.cmd spring-boot:run
```

Open <http://localhost:8081>.

Use the Maven command to run the application. The VS Code **Run Code** button does not include Spring Boot's dependencies.

The default H2 database is file-based and stored under `foodie-reward/data`. Its records persist when the application stops and starts.

### Open the H2 Console

With the app running, open <http://localhost:8081/h2-console> and connect with:

| Setting | Value |
| --- | --- |
| Driver Class | `org.h2.Driver` |
| JDBC URL | `jdbc:h2:file:./data/foodie-reward;MODE=Oracle;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH` |
| User Name | `sa` |
| Password | Leave blank |

The H2 Console is for local development. SQL changes made there affect the local H2 database only. To use SQL*Plus, run the app in Oracle mode as described below.

## Run with Oracle Database

Start an Oracle Database instance and create an application schema/user with permission to create tables, indexes, and PL/SQL packages. From PowerShell in `foodie-reward`, set the connection details for the current terminal session:

```powershell
$env:FOODIE_DB_URL = "jdbc:oracle:thin:@localhost:1521/FREEPDB1"
$env:FOODIE_DB_USERNAME = "foodie_app"
$env:FOODIE_DB_PASSWORD = "your-password"
```

Then start the application with the Oracle profile:

```powershell
.\mvnw.cmd spring-boot:run "-Dspring-boot.run.profiles=oracle"
```

Flyway applies the Oracle migrations on the first launch:

1. `src/main/resources/db/migration/oracle/V1__create_foodie_schema.sql` creates the tables and indexes.
2. `src/main/resources/db/migration/oracle/V2__create_foodie_plsql_package.sql` creates `PKG_FOODIE_REWARDS`.
3. `src/main/resources/db/migration/oracle/V3__seed_foodie_demo_data.sql` inserts demonstration records.

Later launches apply only new migrations. To add Oracle seed or schema changes, create a new versioned migration such as `V4__add_demo_records.sql`; do not edit a migration that has already been applied. SQL*Plus can connect to the same Oracle service and schema to inspect or add data.

## REST API

The UI communicates with the Spring Boot backend under `/api`.

| Method | Endpoint | Purpose |
| --- | --- | --- |
| `GET` | `/api/state` | Load customers, memberships, points, rewards, redemptions, and transactions |
| `POST` | `/api/members/{customerId}/earn` | Add points from a purchase amount |
| `PATCH` | `/api/memberships/{membershipId}` | Update membership status |
| `POST` | `/api/rewards/{rewardId}/redeem` | Redeem a reward for a customer |
| `POST` | `/api/rewards/{rewardId}/restock` | Increase reward stock |
| `PATCH` | `/api/redemptions/{redemptionId}` | Process a redemption status |
| `PATCH` | `/api/transactions/{transactionId}/complete` | Complete a transaction |
| `DELETE` | `/api/transactions/failed` | Delete failed transactions |

## Run tests

From the `foodie-reward` directory:

```powershell
.\mvnw.cmd test
```

## Project layout

```text
G37/
+-- README.md
+-- foodie-reward/
    +-- src/main/java/com/foodie/reward/        # API, services, and app entry point
    +-- src/main/resources/                     # H2 config, schema, and interface
    +-- src/main/resources/db/migration/oracle/  # Oracle schema, package, and seed migrations
    +-- src/test/                               # Automated tests
    +-- data/                                   # Persistent local H2 database files
```

## Reset local demonstration data

Stop the application, then remove the `foodie-reward/data` folder. The next H2 launch recreates the schema and seeds the demonstration records. This deletes local H2 data stored in that folder; it does not affect Oracle data.

For database configuration details, see [`foodie-reward/DATABASE_SETUP.md`](foodie-reward/DATABASE_SETUP.md).
