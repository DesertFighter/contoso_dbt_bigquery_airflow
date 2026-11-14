{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='MachineKey',

    partition_by={
        'field': 'LoadDate',
        'data_type': 'datetime',
        'granularity': 'month'
    },

    cluster_by=['StoreKey', 'MachineType'],

    on_schema_change='append_new_columns',
    full_refresh=false,
    labels={'layer': 'silver'},
    tags=['silver']
) }}

SELECT *
FROM {{ ref('brz_DimMachine') }} AS bronze
WHERE bronze.ValidTo IS NULL

{% if is_incremental() %}
AND NOT EXISTS (
    SELECT 1
    FROM {{ this }} AS silver
    WHERE silver.MachineKey = bronze.MachineKey
      AND silver.SnapshotSCDID = bronze.SnapshotSCDID
)
{% endif %}
