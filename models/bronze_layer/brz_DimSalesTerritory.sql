{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='SalesTerritoryKey',
    incremental_predicates=['FALSE'],

    partition_by={
        'field': 'LoadDate',
        'data_type': 'datetime',
        'granularity': 'month'
    },

    cluster_by=['SalesTerritoryCountry', 'SalesTerritoryRegion'],

    on_schema_change='append_new_columns',
    full_refresh=false,
    labels={'layer': 'bronze'},
    tags=['bronze']
) }}


SELECT
    `SalesTerritoryKey`,
    `GeographyKey`,
    `SalesTerritoryLabel`,
    `SalesTerritoryName`,
    `SalesTerritoryRegion`,
    `SalesTerritoryCountry`,
    `SalesTerritoryGroup`,
    `SalesTerritoryLevel`,
    `SalesTerritoryManager`,
    `StartDate`,
    `EndDate`,
    `Status`,
    `ETLLoadID`,
    `LoadDate`,
    `UpdateDate`
FROM {{ source('contoso_raw', 'DimSalesTerritory') }}

{% if is_incremental() %}
WHERE LoadDate > (
    SELECT COALESCE(
        MAX(LoadDate),
        DATETIME '1900-01-01 00:00:00'
    )
    FROM {{ this }}
)
{% endif %}
