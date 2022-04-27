# i2b2-synthea
## 04-2022

1) Download [SyntheticMass Data, Version 2 (24 May, 2017)](https://synthea.mitre.org/downloads)
  * All data sets (1k, COVID 10k, COVID 100k) have been verified to work EXCEPT the 100k patients in the large SyntheticMass Version 2 download. This version needs an extra step to delete invalid records before import. (Details coming soon.)
3) Set up an [i2b2 project with the ACT ontology](https://community.i2b2.org/wiki/display/RM/1.7.12a+Release+Notes#id-1.7.12aReleaseNotes-act-ontolog). 
4) Run `create_synthea_table_[dbtype].sql` in your project to create the Synthea tables, for your database platform.
5) Import the Synthea data you downloaded in step one into the Synthea tables in your project.
6) Load the i2b2-to-SNOMED table in this repository into your project. https://www.nlm.nih.gov/healthit/snomedct/us_edition.html
   * Click on the "Download SNOMED-CT to ICD-10-CM Mapping Resources" link to download. (You will need a UMLS account.) 
   * Unzip the file
   * Import the TSV file into a table called SNOMED_to_ICD10 in your database.
7) In Postgres and Oracle, follow the additional instructions in the comments at the top of `synthea_to_i2b2_[dbtype].sql` to clean up the date formatting.
8) Run `synthea_to_i2b2_[dbtype].sql` to convert synthea data into i2b2 tables (this will truncate your existing fact and dimension tables!)
   * In MSSQL, replace references to `i2b2metadata.dbo` in the script. Use the database and schema where your ACT ontology tables are.


