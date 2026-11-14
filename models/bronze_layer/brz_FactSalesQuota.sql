{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='SalesQuotaKey',
    incremental_predicates=['FALSE'],

    partition_by={
        'field': 'LoadDate',
        'data_type': 'datetime',
        'granularity': 'month'
    },

    cluster_by=['StoreKey', 'ProductKey'],

    on_schema_change='append_new_columns',
    full_refresh=false,
    labels={'layer': 'bronze'},
    tags=['bronze']
) }}


SELECT
    `SalesQuotaKey`,
    `ChannelKey`,
    `StoreKey`,
    `ProductKey`,
    `DateKey`,
    `CurrencyKey`,
    `ScenarioKey`,
    `SalesQuantityQuota`,
    `SalesAmountQuota`,
    `GrossMarginQuota`,
    `ETLLoadID`,
    `LoadDate`,
    `UpdateDate`
FROM {{ source('contoso_raw', 'FactSalesQuota') }}

{% if is_incremental() %}
WHERE LoadDate > (
    SELECT COALESCE(
        MAX(LoadDate),
        DATETIME '1900-01-01 00:00:00'
    )
    FROM {{ this }}
)
{% endif %}
