# AirWave Express Ticketing System – Database Design

This repository contains the SQL script for designing the database schema of **AirWave Express**, a fictional airport ticketing system.

## 📄 File

- `Task 1.sql`: SQL script to create the database and its core tables, sequences, and triggers.

## 🧱 Key Components

### Tables
- `Employee`
- `Passenger`
- `Flight`
- `Reservation`
- `Ticket`
- `AdditionalServices`
- `Baggage`

### Features
- Use of **constraints** to ensure data integrity
- **Sequences** for generating unique IDs (e.g., `EmployeeSeq`)
- **Triggers** to automate ID assignment (e.g., `trgGenerateEmployeeID`)
- Use of `CHECK`, `NOT NULL`, and `UNIQUE` constraints

## 💻 How to Use

1. Open **SQL Server Management Studio** or any compatible tool.
2. Run the script `Task 1.sql` to create and initialize the database.

## 📌 Notes

- Ensure no existing database with the same name exists before execution.
- Designed for academic and instructional purposes.

---

> Developed by Marvis Osazee Osazuwa as part of a university project.
