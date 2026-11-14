{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='MachineKey',
    incremental_predicates=['FALSE'],

    partition_by={
        'field': 'LoadDate',
        'data_type': 'datetime',
        'granularity': 'month'
    },

    cluster_by=['StoreKey', 'MachineType'],

    on_schema_change='append_new_columns',
    full_refresh=false,
    labels={'layer': 'bronze'},
    tags=['bronze']
) }}


SELECT
    `MachineKey`,
    `MachineLabel`,
    `StoreKey`,
    `MachineType`,
    `MachineName`,
    `MachineDescription`,
    `VendorName`,
    `MachineOS`,
    `MachineSource`,
    `MachineHardware`,
    `MachineSoftware`,
    `Status`,
    `ServiceStartDate`,
    `DecommissionDate`,
    `LastModifiedDate`,
    `ETLLoadID`,
    `LoadDate`,
    `UpdateDate`
FROM {{ source('contoso_raw', 'DimMachine') }}

{% if is_incremental() %}
WHERE LoadDate > (
    SELECT COALESCE(
        MAX(LoadDate),
        DATETIME '1900-01-01 00:00:00'
    )
    FROM {{ this }}
)
{% endif %}
