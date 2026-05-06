import os
import pandas as pd

txt_files = ['DEMO20Q4.txt','DRUG20Q4.txt', 'INDI20Q4.txt', 'OUTC20Q4.txt', 'REAC20Q4.txt', 'RPSR20Q4.txt', 'THER20Q4.txt']

def convert_csv(txt_file):
    df = pd.read_csv(
        txt_file,
        sep='$',
        dtype=str,
        on_bad_lines='skip',
        encoding='latin-1'  # FAERS sometimes has latin-1 encoding
    )

    df.to_csv(
        os.path.splitext(txt_file)[0] + '_clean.csv',
        index=False, 
        encoding='utf-8',
        quoting=1
    )
    return

for file in txt_files:
    convert_csv(file)