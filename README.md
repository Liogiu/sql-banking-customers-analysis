# Banking Customers SQL Analysis

This project performs a complete SQL analysis of banking customers, account types and financial transactions.  
The objective is to generate a denormalized table containing customer-level indicators useful for analytical models, reporting or business intelligence.

## Overview

The database includes the following tables:

- `cliente` – personal information about clients
- `conto` – accounts owned by each client
- `tipo_conto` – account type information
- `transazioni` – financial transactions
- `tipo_transazione` – description of transaction types (credit/debit)

The goal is to build a consolidated table with KPIs derived from all these sources, integrating demographic information, account details and aggregated transaction metrics.

## Main Steps

### 1. Initial Exploration
The project starts with a structural inspection of all tables to understand available fields, data types and relationships between entities.

### 2. Base Indicators
A first temporary table is created to compute customer-level attributes, such as dynamic age based on date of birth.

### 3. Transaction Indicators
Aggregated metrics are computed at the client level, including:
- Number of incoming and outgoing transactions
- Total incoming and outgoing amounts
- Separation by transaction sign

These metrics are stored in a second temporary table.

### 4. Account Indicators
A temporary table summarises:
- Total number of accounts per client
- Number of accounts by account type (e.g. Base, Business, Privati, Famiglie)

### 5. Indicators by Account Type and Transaction Sign
For each account type, the following metrics are computed:
- Number of debit and credit transactions
- Total amounts of debit and credit transactions

This produces 16 additional indicators, structured by account type and transaction direction.

### 6. Final Denormalized Table
All temporary tables are joined to create the final dataset:

- Demographic attributes  
- Transaction behaviour  
- Account ownership metrics  
- Transaction metrics by account type  

The result is a fully denormalized table ready for downstream analysis or modelling.

### 7. Final Output
The script ends by selecting all rows from the final table:

```sql
SELECT * 
FROM tabella_denormalizzata;
