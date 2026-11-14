{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='AccountKey',
    incremental_predicates=['FALSE'],

    partition_by={
        'field': 'LoadDate',
        'data_type': 'datetime',
        'granularity': 'month'
    },

    cluster_by=['AccountType', 'ParentAccountKey'],

    on_schema_change='append_new_columns',
    full_refresh=false,
    labels={'layer': 'bronze'},
    tags=['bronze']
) }}

SELECT
    `AccountKey`,
    `AccountLabel`,
    `AccountName`,
    `AccountDescription`,
    `AccountType`,
    `Operator`,
    `CustomMembers`,
    `ValueType`,
    `CustomMemberOptions`,
    `ETLLoadID`,
    `LoadDate`,
    `UpdateDate`,
    `ParentAccountKey`
FROM {{ source('contoso_raw', 'DimAccount') }}

{% if is_incremental() %}
WHERE LoadDate > (
    SELECT COALESCE(
        MAX(LoadDate),
        DATETIME '1900-01-01 00:00:00'
    )
    FROM {{ this }}
)
{% endif %}
