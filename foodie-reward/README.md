# FoodieReward

FoodieReward turns the existing Group G37 interface into a working full-stack application. The screens and available actions remain the same; changes are now processed by Spring Boot and saved in a local database.

## Run the application

Open PowerShell in this folder and run:

```powershell
.\mvnw.cmd spring-boot:run
```

Then open <http://localhost:8081>.

Do not run `FoodieRewardApplication.java` with the VS Code **Run Code** button. Spring Boot must be launched with the Maven command above so its libraries are included.

## Current stack

- Existing React interface, served by Spring Boot
- Java 17 and Spring Boot REST API
- File-based H2 database in Oracle compatibility mode
- Oracle JDBC profile and a PL/SQL package for the same operations
- Database transactions and row locking for safe point and stock updates
- Flyway migrations for Oracle setup
- Automated service tests

The local H2 database is free and requires no separate installation. It is the default so the project can run immediately. See [DATABASE_SETUP.md](DATABASE_SETUP.md) when an Oracle database is available.

## Reset the demonstration data

Stop the application and delete the `data` folder inside this project. The starting records will be inserted again the next time the application starts.
