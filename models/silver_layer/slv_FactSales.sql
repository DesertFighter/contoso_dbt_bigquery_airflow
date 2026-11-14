{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='SalesKey',

    partition_by={
        'field': 'LoadDate',
        'data_type': 'datetime',
        'granularity': 'month'
    },

    cluster_by=['StoreKey', 'ProductKey'],

    on_schema_change='append_new_columns',
    full_refresh=false,
    labels={'layer': 'silver'},
    tags=['silver']
) }}

SELECT *
FROM {{ ref('brz_FactSales') }} AS bronze
WHERE bronze.ValidTo IS NULL

{% if is_incremental() %}
AND NOT EXISTS (
    SELECT 1
    FROM {{ this }} AS silver
    WHERE silver.SalesKey = bronze.SalesKey
      AND silver.SnapshotSCDID = bronze.SnapshotSCDID
)
{% endif %}
