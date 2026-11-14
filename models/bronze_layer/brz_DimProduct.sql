{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='ProductKey',
    incremental_predicates=['FALSE'],

    partition_by={
        'field': 'LoadDate',
        'data_type': 'datetime',
        'granularity': 'month'
    },

    cluster_by=['ProductSubcategoryKey', 'BrandName'],

    on_schema_change='append_new_columns',
    full_refresh=false,
    labels={'layer': 'bronze'},
    tags=['bronze']
) }}


SELECT
    `ProductKey`,
    `ProductLabel`,
    `ProductName`,
    `ProductDescription`,
    `ProductSubcategoryKey`,
    `Manufacturer`,
    `BrandName`,
    `ClassID`,
    `ClassName`,
    `StyleID`,
    `StyleName`,
    `ColorID`,
    `ColorName`,
    `Size`,
    `SizeRange`,
    `SizeUnitMeasureID`,
    `Weight`,
    `WeightUnitMeasureID`,
    `UnitOfMeasureID`,
    `UnitOfMeasureName`,
    `StockTypeID`,
    `StockTypeName`,
    `UnitCost`,
    `UnitPrice`,
    `AvailableForSaleDate`,
    `StopSaleDate`,
    `Status`,
    `ImageURL`,
    `ProductURL`,
    `ETLLoadID`,
    `LoadDate`,
    `UpdateDate`
FROM {{ source('contoso_raw', 'DimProduct') }}

{% if is_incremental() %}
WHERE LoadDate > (
    SELECT COALESCE(
        MAX(LoadDate),
        DATETIME '1900-01-01 00:00:00'
    )
    FROM {{ this }}
)
{% endif %}
