import os
import csv

FOLDER = '/Users/1000cm3/PycharmProjects/sreal/csv'
OUTPUT = 'ruian_full.csv'
DELIMITER = ';'

first = True

with open(OUTPUT, 'w', newline='', encoding='utf-8') as fout:
    writer = None

    for filename in os.listdir(FOLDER):
        if filename.endswith('_ADR.csv'):
            path = os.path.join(FOLDER, filename)
            with open(path, 'r', encoding='cp1250') as fin:
                reader = csv.reader(fin, delimiter=DELIMITER)
                header = next(reader)

                if first:
                    writer = csv.writer(fout, delimiter=DELIMITER)
                    writer.writerow(header)
                    first = False

                for row in reader:
                    writer.writerow(row)

print(f'ready: {OUTPUT}')