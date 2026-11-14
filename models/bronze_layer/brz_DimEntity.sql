{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='EntityKey',
    incremental_predicates=['FALSE'],

    partition_by={
        'field': 'LoadDate',
        'data_type': 'datetime',
        'granularity': 'month'
    },

    cluster_by=['EntityType', 'Status'],

    on_schema_change='append_new_columns',
    full_refresh=false,
    labels={'layer': 'bronze'},
    tags=['bronze']
) }}


SELECT
    `EntityKey`,
    `EntityLabel`,
    `ParentEntityKey`,
    `ParentEntityLabel`,
    `EntityName`,
    `EntityDescription`,
    `EntityType`,
    `StartDate`,
    `EndDate`,
    `Status`,
    `ETLLoadID`,
    `LoadDate`,
    `UpdateDate`
FROM {{ source('contoso_raw', 'DimEntity') }}

{% if is_incremental() %}
WHERE LoadDate > (
    SELECT COALESCE(
        MAX(LoadDate),
        DATETIME '1900-01-01 00:00:00'
    )
    FROM {{ this }}
)
{% endif %}
