{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='StrategyPlanKey',

    partition_by={
        'field': 'LoadDate',
        'data_type': 'datetime',
        'granularity': 'month'
    },

    cluster_by=['EntityKey', 'AccountKey'],

    on_schema_change='append_new_columns',
    full_refresh=false,
    labels={'layer': 'silver'},
    tags=['silver']
) }}

SELECT *
FROM {{ ref('brz_FactStrategyPlan') }} AS bronze
WHERE bronze.ValidTo IS NULL

{% if is_incremental() %}
AND NOT EXISTS (
    SELECT 1
    FROM {{ this }} AS silver
    WHERE silver.StrategyPlanKey = bronze.StrategyPlanKey
      AND silver.SnapshotSCDID = bronze.SnapshotSCDID
)
{% endif %}
