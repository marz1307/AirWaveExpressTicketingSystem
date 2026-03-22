# AirWave Express Ticketing System

A relational database for an airport ticketing platform built in SQL Server, covering passenger management, flight scheduling, reservations, ticketing, and ancillary services.

## Overview

This repository contains the full SQL schema including tables, sequences, and automated triggers. The design enforces data integrity through constraints and well-defined business rules.

## Database Schema

| Table                | Description                                        |
|----------------------|----------------------------------------------------|
| `Employee`           | Staff records and roles                            |
| `Passenger`          | Passenger profiles                                 |
| `Flight`             | Flight schedules and routes                        |
| `Reservation`        | Bookings linking passengers to flights             |
| `Ticket`             | Issued tickets tied to reservations                |
| `AdditionalServices` | Optional add-ons (meals, seat upgrades, etc.)      |
| `Baggage`            | Baggage allowance and tracking                     |

## Key Design Features

- Sequences for auto-generating unique IDs (e.g. `EmployeeSeq`)
- Triggers for automated ID assignment (e.g. `trgGenerateEmployeeID`)
- `CHECK`, `NOT NULL`, and `UNIQUE` constraints throughout

## Getting Started

### Prerequisites
- SQL Server Management Studio (SSMS) or compatible tool
- A running SQL Server instance

### Setup
1. Clone the repository
2. Open `schema.sql` in SSMS
3. Ensure no existing database with the same name before execution
4. Run the script to create and initialise the database

## License

Available under the [MIT License](LICENSE).

## Author

**Marvis Osazuwa** — [GitHub](https://github.com/marz1307) · [LinkedIn](https://linkedin.com/in/marvisosazuwa)
