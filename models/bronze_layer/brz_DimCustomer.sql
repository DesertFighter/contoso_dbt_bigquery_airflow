{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='CustomerKey',
    incremental_predicates=['FALSE'],

    partition_by={
        'field': 'LoadDate',
        'data_type': 'datetime',
        'granularity': 'month'
    },

    cluster_by=['GeographyKey', 'CustomerType'],

    on_schema_change='append_new_columns',
    full_refresh=false,
    labels={'layer': 'bronze'},
    tags=['bronze']
) }}


SELECT
    `CustomerKey`,
    `GeographyKey`,
    `CustomerLabel`,
    `Title`,
    `FirstName`,
    `MiddleName`,
    `LastName`,
    `NameStyle`,
    `BirthDate`,
    `MaritalStatus`,
    `Suffix`,
    `Gender`,
    `EmailAddress`,
    `YearlyIncome`,
    `TotalChildren`,
    `NumberChildrenAtHome`,
    `Education`,
    `Occupation`,
    `HouseOwnerFlag`,
    `NumberCarsOwned`,
    `AddressLine1`,
    `AddressLine2`,
    `Phone`,
    `DateFirstPurchase`,
    `CustomerType`,
    `CompanyName`,
    `ETLLoadID`,
    `LoadDate`,
    `UpdateDate`
FROM {{ source('contoso_raw', 'DimCustomer') }}

{% if is_incremental() %}
WHERE LoadDate > (
    SELECT COALESCE(
        MAX(LoadDate),
        DATETIME '1900-01-01 00:00:00'
    )
    FROM {{ this }}
)
{% endif %}
