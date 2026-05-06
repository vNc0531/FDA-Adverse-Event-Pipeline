import pandas as pd

df = pd.read_csv(
    'DRUG20Q4.txt',
    sep='$',
    dtype=str,
    on_bad_lines='skip',
    encoding='latin-1'
)

third = len(df) // 3

df1 = df.iloc[:third]
df2 = df.iloc[third:third*2]
df3 = df.iloc[third*2:]

df1.to_csv('DRUG20Q4_part1.csv', index=False, encoding='utf-8', quoting=1)
df2.to_csv('DRUG20Q4_part2.csv', index=False, encoding='utf-8', quoting=1)
df3.to_csv('DRUG20Q4_part3.csv', index=False, encoding='utf-8', quoting=1)

print(f"Part 1: {len(df1)} rows")
print(f"Part 2: {len(df2)} rows")
print(f"Part 3: {len(df3)} rows")