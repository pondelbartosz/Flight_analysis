/*
Defining `reporting` schema
*/

CREATE SCHEMA IF NOT EXISTS reporting;

/*
VIEW reporting.flight:
- deleting cancelled flights
- creating 'is_delayed' column
*/

CREATE OR REPLACE VIEW reporting.flight as
SELECT 
    *,
    CASE 
        WHEN dep_delay_new > 0 THEN 1
        ELSE 0
    END AS is_delayed
FROM 
    airlines.public.flight
WHERE 
    cancelled = 0
;

/*
VIEW reporting.top_reliability_roads with columns:
- 'origin_airport_id',
- 'origin_airport_name',
- 'dest_airport_id',
- 'dest_airport_name',
- 'year',
- 'cnt' - number of flights on certain route,
- 'reliability' - percentage of delayed flights on certain route,
- 'nb' - numbering from 1, 2, 3 according to the 'reliability' column
*/

CREATE OR REPLACE VIEW reporting.top_reliability_roads AS
SELECT 
    origin_airport_id,
    origin_airport_name,
    dest_airport_id,
    dest_airport_name,
    year,
    route_description,
    cnt,
    reliability,
    DENSE_RANK() OVER (ORDER BY reliability ASC) AS nb
FROM 
    (SELECT 
        f.origin_airport_id,
        o.display_airport_name AS origin_airport_name,
        f.dest_airport_id,
        d.display_airport_name AS dest_airport_name,
        f.year,
        CONCAT(o.display_airport_name, ' - ', d.display_airport_name) AS route_description,
        COUNT(*) AS cnt,
        ROUND(100.0 * SUM(CASE WHEN f.dep_delay_new > 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS reliability
    FROM 
        airlines.public.flight f
    JOIN 
        airlines.public.airport_list o ON f.origin_airport_id = o.origin_airport_id
    JOIN 
        airlines.public.airport_list d ON f.dest_airport_id = d.origin_airport_id
    GROUP BY 
        f.origin_airport_id, 
        o.display_airport_name, 
        f.dest_airport_id, 
        d.display_airport_name,
        f.year,
        CONCAT(o.display_airport_name, ' - ', d.display_airport_name)
    HAVING 
        COUNT(*) > 10000
    ) AS subquery
ORDER BY 
    reliability DESC;
    
/*
VIEW reporting.year_to_year_comparision with columns:
- 'year'
- 'month'
- 'flights_amount'
- 'reliability'
*/

CREATE OR REPLACE VIEW reporting.year_to_year_comparision AS
SELECT 
    a.month,
    2019 AS year_2019,
    2020 AS year_2020,
    a.flights_amount AS flights_2019,
    b.flights_amount AS flights_2020,
    a.reliability AS reliability_2019,
    b.reliability AS reliability_2020
FROM
    (SELECT 
         month,
         COUNT(*) AS flights_amount,
         ROUND(100.0 * SUM(CASE WHEN dep_delay_new > 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS reliability
     FROM 
         airlines.public.flight
     WHERE 
         year = 2019
     GROUP BY 
         month) AS a
JOIN 
    (SELECT 
         month,
         COUNT(*) AS flights_amount,
         ROUND(100.0 * SUM(CASE WHEN dep_delay_new > 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS reliability
     FROM 
         airlines.public.flight
     WHERE 
         year = 2020
     GROUP BY 
         month) AS b ON a.month = b.month
ORDER BY 
    a.month;
    
/*
VIEW reporting.day_to_day_comparision with columns:
- 'year'
- 'day_of_week'
- 'flights_amount'
*/

CREATE OR REPLACE VIEW reporting.day_to_day_comparision AS
SELECT 
    year,
    month,
    day_of_month,
    EXTRACT(DOW FROM to_date(year || '-' || LPAD(month::text, 2, '0') || '-' || LPAD(day_of_month::text, 2, '0'), 'YYYY-MM-DD')) AS day_of_week,
    COUNT(*) AS flights_amount,
    ROUND(100.0 * SUM(CASE WHEN dep_delay_new > 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS reliability
FROM 
    airlines.public.flight
GROUP BY 
    year,
    month,
    day_of_month,
    EXTRACT(DOW FROM to_date(year || '-' || LPAD(month::text, 2, '0') || '-' || LPAD(day_of_month::text, 2, '0'), 'YYYY-MM-DD'))
ORDER BY 
    year,
    month,
    day_of_month;
    
/*
VIEW reporting.day_by_day_reliability with columns:
- 'date' - as a combination of `year`, `month`, `day` columns
- 'reliability' - percentage of delayed flights on a certain day
*/

CREATE OR REPLACE VIEW reporting.day_by_day_reliability AS
SELECT 
    to_date(year || '-' || LPAD(month::text, 2, '0') || '-' || LPAD(day_of_month::text, 2, '0'), 'YYYY-MM-DD') AS date,
    ROUND(100.0 * SUM(CASE WHEN dep_delay_new > 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS reliability
FROM 
    airlines.public.flight
GROUP BY 
    year, month, day_of_month