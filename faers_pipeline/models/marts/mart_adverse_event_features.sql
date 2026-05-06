{{ config(materialized='table') }}

WITH demo AS (
    SELECT * 
    FROM {{ ref('stg_demo') }}
),

drug AS (
    SELECT *
    FROM {{ ref('stg_drug') }}
),

outc AS (
    SELECT *
    FROM {{ ref('stg_outc')}}
),

indi AS (
    SELECT * 
    FROM {{ ref('stg_indi') }}
),

reac AS (
    SELECT *
    FROM {{ ref('stg_reac') }}
),

join_drug AS (
    SELECT 
        d.primaryid,
        d.age_years,
        d.weight_kg,
        d.sex,
        d.reporter_type,
        d.reporter_country,
        g.drugname,
        g.route,
        g.dose_form,
        g.dose_freq,
        g.dechal,
        g.rechal
    FROM demo AS d
        LEFT JOIN drug AS g 
        ON d.primaryid = g.primaryid
),

join_outc AS (
    SELECT 
        d.*,
        o.critical_outcome
    FROM join_drug AS d
        LEFT JOIN outc as o 
        ON d.primaryid = o.primaryid
),

join_indi AS (
    SELECT 
        o.*,
        i.indication
    FROM join_outc AS o
        LEFT JOIN indi AS i
        ON o.primaryid = i.primaryid
),

join_reac AS (
    SELECT 
        i.*,
        r.num_reactions
    FROM join_indi AS i
        LEFT JOIN reac AS r
        ON i.primaryid = r.primaryid
)

SELECT *
FROM join_reac