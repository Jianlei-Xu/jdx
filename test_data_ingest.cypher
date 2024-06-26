﻿// Test data ingested from CSV 6/12/2024
load csv with headers from 'https://amida-tech.github.io/profiles-data/test-data-generator/demographics_table.csv' as row create (a:Demographics) set a=row;
load csv with headers from 'https://amida-tech.github.io/profiles-data/test-data-generator/medication_dim.csv' as row create (a:MedicationDim) set a=row;
load csv with headers from 'https://amida-tech.github.io/profiles-data/test-data-generator/diagnosis_dim.csv' as row create (a:DiagnosisDim) set a=row;
load csv with headers from 'https://amida-tech.github.io/profiles-data/test-data-generator/benefits_dim.csv' as row create (a:BenefitDim) set a=row;
load csv with headers from 'https://amida-tech.github.io/profiles-data/test-data-generator/benefits_table.csv' as row with distinct row match (a:Demographics),(b:BenefitDim) where row.person_id=a.person_id and row.benefit_id=b.benefit_id create (a)-[r:Has_Benefit]->(b) 
load csv with headers from 'https://amida-tech.github.io/profiles-data/test-data-generator/diagnosis_table.csv' as row with distinct row match (a:Demographics),(b:DiagnosisDim) where row.person_id=a.person_id and row.diagnosis_id=b.diagnosis_id create (a)-[r:Has_Diagnosis]->(b)
load csv with headers from 'https://amida-tech.github.io/profiles-data/test-data-generator/medication_table.csv' as row with distinct row match (a:Demographics),(b:MedicationDim) where row.person_id=a.person_id and row.drug_id=b.drug_id create (a)-[r:Has_Medication]->(b)
match (d:Demographics) with distinct d.age_bracket as age_bucket create (a:AgeBucketDim{age_bucket:age_bucket})
match (d:Demographics) optional match (d),(a:AgeBucketDim) where d.age_bracket=a.age_bucket merge (d)-[r:In_AgeBucket]->(a)
match (a)-[r]-(b) with a,b,type(r),tail(collect(r)) as duplicateRels where size(duplicateRels)>0 and duplicateRels is not null unwind duplicateRels as deleteRels delete deleteRels
