# FDA Adverse Event Prediction Pipeline

An end-to-end machine learning pipeline that predicts critical drug outcomes from 400,000+ FDA adverse event records, using dbt on BigQuery for transformation and XGBoost/Logistic Regression for classification.

---

## Project Overview

The FDA Adverse Event Reporting System (FAERS) collects reports of adverse drug events and medication errors. This project ingests, transforms, and models that data to predict whether a reported adverse event will result in a critical outcome (death or life-threatening).

**Business Question:** Given a reported adverse drug event, what is the likelihood it results in a critical outcome?

---

## Architecture

```
raw_data/ (FAERS Kaggle dataset)
    ↓
data_cleaning.py (preprocessing & null handling)
    ↓
BigQuery (raw tables)
    ↓
dbt (faers_pipeline/)
    ├── staging/ (stg_demo, stg_drug, stg_indi, stg_outc, stg_reac)
    └── marts/ (mart_adverse_event_features)
    ↓
model/
    ├── logistic_regression.py
    └── xgboost_model.py
```

---

## Data Source

- **Dataset:** FDA Adverse Event Reporting System (FAERS) via Kaggle
- **Size:** 400,000+ adverse event records
- **Target Variable:** `critical_outcome` (binary: 1 = critical, 0 = non-critical)
- **Class Imbalance:** 7:1 ratio (non-critical to critical)

---

## Feature Engineering

20+ features engineered across three dimensions:

| Dimension | Features |
|-----------|----------|
| Patient | age, weight, sex |
| Drug | drugname (top 20), route, dose_form, dose_freq, dechal, rechal |
| Reporter | reporter_type, reporter_country, indication (top 20) |

High-cardinality columns (drugname, indication) were bucketed to top 20 values with remaining categories grouped as `Other` to reduce noise and dimensionality.

---

## dbt Models

**Staging layer** — cleans and types raw FAERS tables:
- `stg_demo.sql` — patient demographics
- `stg_drug.sql` — drug information
- `stg_indi.sql` — drug indications
- `stg_outc.sql` — outcome classifications
- `stg_reac.sql` — adverse reactions

**Mart layer** — joins staging models into a single analytics-ready feature table:
- `mart_adverse_event_features.sql` — final feature table used for modeling

---

## Model Performance

| Model | ROC-AUC | Critical Outcome Recall |
|-------|---------|------------------------|
| Logistic Regression | 0.8730 | 0.76 |
| XGBoost | 0.9122 | 0.80 |

**Class imbalance handling:**
- Logistic Regression: `class_weight='balanced'`
- XGBoost: `scale_pos_weight=7`

ROC-AUC was chosen as the primary metric due to the 7:1 class imbalance — accuracy alone is misleading in this context. Recall on the critical outcome class was prioritized since missing a true critical case is more costly than a false alarm.

---

## Known Limitations

- **Class imbalance** — 7:1 ratio limits precision on the minority class (XGBoost class 1 precision: 0.45)
- **Static features** — model does not account for temporal patterns in reporting
- **Fuzzy matching** — string matching across drug name fields introduces some noise
- **Kaggle dataset** — not a live API feed; results may not reflect the most recent FAERS data

---

## How to Run

**1. Install dependencies:**
```bash
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

**2. Run data cleaning:**
```bash
python data_cleaning.py
```

**3. Run dbt transformations:**
```bash
cd faers_pipeline
dbt run
dbt test
```

**4. Train models:**
```bash
python model/logistic_regression.py
python model/xgboost_model.py
```

---

## Tech Stack

`Python` `XGBoost` `scikit-learn` `dbt` `BigQuery` `GCP` `pandas` `GitHub Actions`
