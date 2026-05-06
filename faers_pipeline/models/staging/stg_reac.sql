{{ config(materialized='table') }}

WITH source AS (
    SELECT * 
    FROM {{ source('raw', 'reac') }}
),

aggregated AS (
    SELECT primaryid, COUNT(pt) AS num_reactions
    FROM source
    WHERE primaryid IS NOT NULL
    GROUP BY primaryid
)

SELECT *
FROM aggregated