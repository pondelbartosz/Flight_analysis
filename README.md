# Flight_analysis

## Description

The goal of the project was to analyze data about flights and delays in 2019 and 2020.
Project was divided into smaller pieces:
1. Downloading all data using dedicated API server with different endpoints.
2. Creating a Postgres database to store data
3. Populating database with data
4. Analizing data regarding delays, wheather conditions, manufacture year etc. (by joining seperate tables)
5. Creating reporting schema
6. Creating a dashboard with the results
7. 
More specific descriptions are involved in each python notebook.

## File structure
- 'data' folder - all data (raw and processed) used in the analysis
- 'notebooks' folder - python notebooks with each significant step
-  'sql' folder - files with queries needed to create database schema and reporting schema
-  'TOP_report.PNG' - screenshot of Page 1 of dashboard in a format visible in the preview
-  'Comparison_1.PNG' - screenshot of Page 2.1 of dashboard in a format visible in the preview
-  'Comparison_2.PNG' - screenshot of Page 2.2 of dashboard in a format visible in the preview
-  'Daily_reliability_analysis.PNG' - screenshot of Page 3 of dashboard in a format visible in the preview

## Technologies
- Python
- SQL
- Pandas
- Dash
