{{ config(materialized='table') }}

WITH source AS (
    SELECT * 
    FROM {{ source('raw', 'demo') }}
),

renamed AS (
    SELECT
        primaryid,
        caseid,
        caseversion,
        i_f_code,
        
        -- age normalized to years
        CASE
            WHEN age_cod = 'YR'  THEN SAFE_CAST(age AS float64)
            WHEN age_cod = 'DEC' THEN SAFE_CAST(age AS float64) * 10
            WHEN age_cod = 'MON' THEN SAFE_CAST(age AS float64) / 12
            WHEN age_cod = 'WK'  THEN SAFE_CAST(age AS float64) / 52
            WHEN age_cod = 'DY'  THEN SAFE_CAST(age AS float64) / 365
            else null
        END AS age_years,

        -- weight normalized to kg
        CASE
            WHEN wt_cod = 'KG'  THEN SAFE_CAST(wt AS float64)
            WHEN wt_cod = 'LBS' THEN SAFE_CAST(wt AS float64) * 0.453592
            WHEN wt_cod = 'GMS' THEN SAFE_CAST(wt AS float64) / 1000
            else null
        END AS weight_kg,

        sex,
        occp_cod AS reporter_type,
        reporter_country,
        fda_dt AS fda_date

    FROM source
    WHERE caseversion = (
        SELECT MAX(caseversion) 
        FROM source AS s2
        WHERE s2.caseid = source.caseid
        )
        AND primaryid IS NOT NULL
        
)

SELECT * FROM renamed