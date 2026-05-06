{{ config(materialized='table') }}

WITH source AS (
    SELECT * 
    FROM {{ source('raw', 'drug') }}
),

primary_suspect AS (
    SELECT
        primaryid, 
        caseid, 
        drug_seq,
        drugname,
        route,
        dose_form,
        dose_freq,
        dechal,
        rechal,
        role_cod,
    FROM source
    WHERE role_cod = 'PS'
        AND primaryid IS NOT NULL
)

SELECT *
FROM primary_suspect