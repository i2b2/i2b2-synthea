#!/usr/bin/perl -w

###########################################################
# Cleanup of Synthea CSV files
# Peter Rice peter.rice@i2b2transmart.org
#
# Run in each csv directory: output_1/csv ... output_12/csv
#
# Cleaned files go to fixcsv output_1/fixcsv etc.
###########################################################

# First value is a UUID somehow generated
# For mangled records, we need to find the appropriate UUIDs and remove it
# Corrupted records are 2+ consecutive patient.csv records with a new patient starting
# before the original record is completely written. All records end with an address.

# Checks for number of columns, and also checks columns match expected data values
# (in case we do get the expected number in a corrupted record)

# Patient UUID appears in:

#csv/patients.csv

#csv/immunizations.csv
#csv/procedures.csv
#csv/medications.csv
#csv/encounters.csv
#csv/careplans.csv
#csv/conditions.csv
#csv/observations.csv

mkdir ("../fixcsv/");

open(LOG, '>../fixcsv/drop_patients.log') || die "Cannot open drop_patients.log";
open(PAT, "patients.csv") || die "No patients.csv file";
open(FIXPAT, ">../fixcsv/patients.csv") || die "Cannot open 
../fixcsv/patients.csv";

$line = 1;
$head = <PAT>;
@head = split(/,/,$head);
$ncol = $#head;

$badpat = 0;
while(<PAT>){
     ++$line;
     @col = split(/,/);
     if($#col != $ncol) {
        ++$badpat;
#       print "$#col $line:$_";
        print LOG "$#col $line:$_";
        $test = $_;
        while($test =~ /([A-Z][a-z]+\d+),([A-Z][a-z]+\d+)/gos) {
            $badname{"$2\_$1"} = $line;
#           open(FIND, "find fhir -name '$2\_$1_*'|");
#           while($f = <FIND>) {
#               if($f =~ /_(\d+)[.]json/) {
#                   print " $1";
#               }
#           }
#           close FIND;
        }
        while($test =~ /([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})/gos) {
#           print "UUID: $1\n";
            $baduuid{"$1"} = $line;
        }
     } else {
        $ok = 1;
        if($col[0] !~ /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/) {print "$line: bad uuid $col[0]\n";$ok=0}
        else {$uuid{$col[0]} = $line}
        if($col[1] !~ /^[12][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/){print "$line: bad birthdate $col[1]\n";$ok=0}
        if($col[2] ne "" && $col[2] !~ /^[12][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/){print "$line: Bad deathdate $col[2]\n";$ok=0}
        if($col[3] ne "" && $col[3] !~ /^\d\d\d-\d\d-\d\d\d\d$/){print "$line: Bad SSN $col[3]\n";$ok=0}
        if($col[4] ne "" && $col[4] !~ /^S\d+$/){print "$line: Bad drivers $col[4]\n";$ok=0}
        if($col[5] ne "" && $col[5] ne "false" && $col[5] !~ /^X\d+X$/){print "$line: Bad passport $col[5]\n";$ok=0}
        if($col[6] ne "" && $col[6] !~ /^M[rs]+[.]$/){print "$line: Bad prefix $col[6]\n";$ok=0}
        if($col[7] !~ /^[A-Z]'?[a-z]+\d+$/){print "$line: Bad firstname $col[7]\n";$ok=0}
        if($col[8] !~ /^(O'|D'|Du|Von|Mc|Mac)?[A-Z][a-z]+\d+$/){print "$line: Bad lastname $col[8]\n";$ok=0}
        if($col[9] ne "" && $col[9] !~ /^[A-Z]+|PhD$/){print "$line: Bad suffix $col[9]\n";$ok=0}
        if($col[10] ne "" && $col[10] !~ /^(O'|D'|Du|Von|Mc|Mac)?[A-Z][a-z]+\d+$/){print "$line: Bad maidenname $col[10]\n";$ok=0}
        if($col[11] ne "" && $col[11] !~ /^[MS]$/){print "$line: Bad maritalstatus $col[11]\n";$ok=0}
        if($col[12] !~ /^[a-z]+$/){print "$line: Bad race $col[12]\n";$ok=0}
        if($col[13] !~ /^[a-z_]+$/){print "$line: Bad ethnicity $col[13]\n";$ok=0}
        if($col[14] !~ /^[MF]$/){print "$line: Bad gender $col[14]\n";$ok=0}
        if($col[15] !~ / US$/){print "$line: Bad birthplace $col[15]\n";$ok=0}
        if($col[16] !~ / US$/){print "$line: Bad address $col[16]\n";$ok=0}
        if($ok) {print FIXPAT $_}
     }
}
close PAT;
close FIXPAT;

$totname = 0;
foreach $p (sort {$badname{$a} <=> $badname{$b}}(keys(%badname))) {
     ++$totname;
#    print "$badname{$p}\t$p\n";
}
$totuuid = 0;
foreach $p (sort {$baduuid{$a} <=> $baduuid{$b}}(keys(%baduuid))) {
     ++$totuuid;
#    print "$baduuid{$p}\t$p\n";
}
print "Lines read: $line\n";
print "Rejected names: $totname\n";
print "Rejected UUIDs: $totuuid\n";
print "Bad records: $badpat\n";
print "Saved UUID: ".scalar (keys(%uuid))."\n";
print LOG "Lines read: $line\n";
print LOG "Rejected names: $totname\n";
print LOG "Rejected UUIDs: $totuuid\n";
print LOG "Bad records: $badpat\n";
print LOG "Saved UUID: ".scalar (keys(%uuid))."\n";

open(ALLER, "allergies.csv") || die "Cannot open allergies.csv";
open(FIXALLER, ">../fixcsv/allergies.csv") || die "Cannot open ../fixcsv/allergies.csv";
$totaller = 1;
$dropaller = 0;
$head = <ALLER>;
while(<ALLER>) {
     ++$totaller;
     @col = split(/,/);
     $uuid = $col[2];
     if(defined($baduuid{$uuid})){++$dropaller}
     else {print FIXALLER $_}
}
close ALLER;
close FIXALLER;
print "Aller lines $totaller dropped $dropaller\n";
print LOG "Aller lines $totaller dropped $dropaller\n";

open(CARE, "careplans.csv") || die "Cannot open careplans.csv";
open(FIXCARE, ">../fixcsv/careplans.csv") || die "Cannot open ../fixcsv/careplans.csv";
$totcare = 1;
$dropcare = 0;
$head = <CARE>;
while(<CARE>) {
     ++$totcare;
     @col = split(/,/);
     $uuid = $col[3];
     if(defined($baduuid{$uuid})){++$dropcare}
     else {print FIXCARE $_}
}
close CARE;
close FIXCARE;
print "Care lines $totcare dropped $dropcare\n";
print LOG "Care lines $totcare dropped $dropcare\n";

open(COND, "conditions.csv") || die "Cannot open conditions.csv";
open(FIXCOND, ">../fixcsv/conditions.csv") || die "Cannot open ../fixcsv/conditions.csv";
$totcond = 1;
$dropcond = 0;
$head = <COND>;
while(<COND>) {
     ++$totcond;
     @col = split(/,/);
     $uuid = $col[2];
     if(defined($baduuid{$uuid})){++$dropcond}
     else {print FIXCOND $_}
}
close COND;
close FIXCOND;
print "Cond lines $totcond dropped $dropcond\n";
print LOG "Cond lines $totcond dropped $dropcond\n";

open(ENC, "encounters.csv") || die "Cannot open encounters.csv";
open(FIXENC, ">../fixcsv/encounters.csv") || die "Cannot open ../fixcsv/encounters.csv";
$totenc = 1;
$dropenc = 0;
$head = <ENC>;
while(<ENC>) {
     ++$totenc;
     @col = split(/,/);
     $uuid = $col[2];
     if(defined($baduuid{$uuid})){++$dropenc}
     else {print FIXENC $_}
}
close ENC;
close FIXENC;
print "Enc lines $totenc dropped $dropenc\n";
print LOG "Enc lines $totenc dropped $dropenc\n";

open(IMM, "immunizations.csv") || die "Cannot open immunizations.csv";
open(FIXIMM, ">../fixcsv/immunizations.csv") || die "Cannot open 
../fixcsv/immunixations.csv";
$totimm = 1;
$dropimm = 0;
$head = <IMM>;
while(<IMM>) {
     ++$totimm;
     @col = split(/,/);
     $uuid = $col[1];
     if(defined($baduuid{$uuid})){++$dropimm}
     else {print FIXIMM $_}
}
close IMM;
close FIXIMM;
print "Imm lines $totimm dropped $dropimm\n";
print LOG "Imm lines $totimm dropped $dropimm\n";

open(MEDS, "medications.csv") || die "Cannot open medications.csv";
open(FIXMEDS, ">../fixcsv/medications.csv") || die "Cannot open ../fixcsv/medications.csv";
$totmeds = 1;
$dropmeds = 0;
$head = <MEDS>;
while(<MEDS>) {
     ++$totmeds;
     @col = split(/,/);
     $uuid = $col[2];
     if(defined($baduuid{$uuid})){++$dropmeds}
     else {print FIXMEDS $_}
}
close MEDS;
close FIXMEDS;
print "Meds lines $totmeds dropped $dropmeds\n";
print LOG "Meds lines $totmeds dropped $dropmeds\n";

open(OBS, "observations.csv") || die "Cannot open observations.csv";
open(FIXOBS, ">../fixcsv/observations.csv") || die "Cannot open ../fixcsv/observations.csv";
$totobs = 1;
$dropobs = 0;
$head = <OBS>;
while(<OBS>) {
     ++$totobs;
     @col = split(/,/);
     $uuid = $col[1];
     if(defined($baduuid{$uuid})){++$dropobs}
     else {print FIXOBS $_}
}
close OBS;
close FIXOBS;
print "Obs lines $totobs dropped $dropobs\n";
print LOG "Obs lines $totobs dropped $dropobs\n";

open(PROC, "procedures.csv") || die "Cannot open procedures.csv";
open(FIXPROC, ">../fixcsv/procedures.csv") || die "Cannot open ../fixcsv/procedures.csv";
$totproc = 1;
$dropproc = 0;
$head = <PROC>;
while(<PROC>) {
     ++$totproc;
     @col = split(/,/);
     $uuid = $col[1];
     if(defined($baduuid{$uuid})){++$dropproc}
     else {print FIXPROC $_}
}
close PROC;
close FIXPROC;
print "Proc lines $totproc dropped $dropproc\n";
print LOG"Proc lines $totproc dropped $dropproc\n";

close LOG;
