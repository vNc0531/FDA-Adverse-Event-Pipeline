from google.cloud import bigquery
import pandas as pd

from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report, roc_auc_score
from sklearn.preprocessing import StandardScaler

client = bigquery.Client(project='project-569fefa7-cf8b-400f-9f3')

query = """
    Select *
    FROM `project-569fefa7-cf8b-400f-9f3.staging.mart_adverse_event_features`
"""

df = client.query(query).to_dataframe()
#print(df.shape)
#print(df.head())
#print(df.dtypes)
#print(df['critical_outcome'].value_counts())

# drop identifier
df = df.drop(columns=['primaryid'])

# fill nulls
df['critical_outcome'] = df['critical_outcome'].fillna(0)
df['num_reactions'] = df['num_reactions'].fillna(0)
df['age_years'] = df['age_years'].fillna(df['age_years'].median())
df['weight_kg'] = df['weight_kg'].fillna(df['weight_kg'].median())

# fill categorical nulls
cat_cols = ['sex', 'reporter_type', 'reporter_country', 
            'drugname', 'route', 'dose_form', 'dose_freq',
            'dechal', 'rechal', 'indication']
df[cat_cols] = df[cat_cols].fillna('Unknown')

print(df.isnull().sum())

# keep only top 20 drug names
top_drugs = df['drugname'].value_counts().nlargest(20).index
df['drugname'] = df['drugname'].where(df['drugname'].isin(top_drugs), 'Other')

# keep only top 20 indications
top_indi = df['indication'].value_counts().nlargest(20).index
df['indication'] = df['indication'].where(df['indication'].isin(top_indi), 'Other')

df_encoded = pd.get_dummies(df, columns=cat_cols)

x = df_encoded.drop(columns=['critical_outcome'])
y = df_encoded['critical_outcome']

# train_test split

x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.2, random_state=42, stratify=y)

# train logistic regression
lr = LogisticRegression(
    max_iter=5000,
    class_weight='balanced',  # handles class imbalance
    random_state=42
)

#scaling
scaler = StandardScaler()
x_train_scaled = scaler.fit_transform(x_train)
x_test_scaled = scaler.transform(x_test)

lr.fit(x_train_scaled, y_train)

# evaluate
y_pred = lr.predict(x_test_scaled)
y_prob = lr.predict_proba(x_test_scaled)[:, 1]

print(classification_report(y_test, y_pred))
print(f"ROC-AUC: {roc_auc_score(y_test, y_prob):.4f}")
