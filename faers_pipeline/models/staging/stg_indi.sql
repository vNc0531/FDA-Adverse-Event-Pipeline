{{ config(materialized='table') }}

WITH source AS (
    SELECT * 
    FROM {{ source('raw', 'indi') }}
),

max_indi AS(
    SELECT primaryid, MAX(indi_pt) as indication
    FROM source
    GROUP BY primaryid
)

SELECT *
FROM max_indi