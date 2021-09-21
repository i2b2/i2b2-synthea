# i2b2-synthea
## Work in progress
### ONLY WORKS IN MSSQL AT PRESENT (9-15-21)

1) Download [SyntheticMass Data, Version 2 (24 May, 2017)](https://synthea.mitre.org/downloads)
2) Set up an [i2b2 project with the ACT ontology](https://community.i2b2.org/wiki/display/RM/1.7.12a+Release+Notes#id-1.7.12aReleaseNotes-act-ontolog). 
3) Load the Synthea data in your project.
4) Load the i2b2-to-SNOMED table in this repository into your project. https://www.nlm.nih.gov/healthit/snomedct/us_edition.html
7) Run the script in this repository to convert synthea data into i2b2 tables (this will truncate your existing fact and dimension tables!)

