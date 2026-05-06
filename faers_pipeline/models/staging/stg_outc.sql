{{ config(materialized='table') }}

WITH source AS (
    SELECT * 
    FROM {{ source('raw', 'outc') }}
),

aggregated AS (
    SELECT 
        primaryid,
        caseid,
        MAX(
            CASE 
                WHEN outc_cod IN ('DE', 'LT') THEN 1
                ELSE 0
            END
        ) AS critical_outcome
    FROM source
    WHERE primaryid IS NOT NULL
    GROUP BY primaryid, caseid
)

SELECT *
FROM aggregated