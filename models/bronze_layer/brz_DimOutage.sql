{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='OutageKey',
    incremental_predicates=['FALSE'],

    partition_by={
        'field': 'LoadDate',
        'data_type': 'datetime',
        'granularity': 'month'
    },

    cluster_by=['OutageType', 'OutageSubType'],

    on_schema_change='append_new_columns',
    full_refresh=false,
    labels={'layer': 'bronze'},
    tags=['bronze']
) }}


SELECT
    `OutageKey`,
    `OutageLabel`,
    `OutageName`,
    `OutageDescription`,
    `OutageType`,
    `OutageTypeDescription`,
    `OutageSubType`,
    `OutageSubTypeDescription`,
    `ETLLoadID`,
    `LoadDate`,
    `UpdateDate`
FROM {{ source('contoso_raw', 'DimOutage') }}

{% if is_incremental() %}
WHERE LoadDate > (
    SELECT COALESCE(
        MAX(LoadDate),
        DATETIME '1900-01-01 00:00:00'
    )
    FROM {{ this }}
)
{% endif %}
