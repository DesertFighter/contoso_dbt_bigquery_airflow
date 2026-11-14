WITH date_dimension AS (

    {{ dbt_date.get_date_dimension(
        "2000-01-01",
        "2036-01-01"
    ) }}

)

SELECT
    CAST(FORMAT_DATE('%Y%m%d', date_day) AS INT64) AS DateKey,
    date_day AS FullDate,
    day_of_month AS DayNumber,
    day_of_week_name AS DayName,
    month_of_year AS MonthNumber,
    month_name AS MonthName,
    quarter_of_year AS QuarterNumber,
    year_number AS CalendarYear
FROM date_dimension