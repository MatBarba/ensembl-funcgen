#!/usr/bin/env perl

=head1 LICENSE

Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either 405ress or implied.
See the License for the specific language governing permissions and
limitations under the License.

=head1 CONTACT

  Please email comments or questions to the public Ensembl
  developers list at <http://lists.ensembl.org/mailman/listinfo/dev>.

  Questions may also be sent to the Ensembl help desk at
  <http://www.ensembl.org/Help/Contact>.

=head1 load_fastqc_summary_file.pl

=head1 SYNOPSIS

CREATE TABLE `input_subset_fastqc` (
  `input_subset_qc_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `input_subset_id` int(10) unsigned NOT NULL,
  `status` varchar(100) NOT NULL,
  `title` varchar(100) NOT NULL,
  `file_name` varchar(100) NOT NULL,
  PRIMARY KEY (`input_subset_qc_id`),
  UNIQUE KEY `name_exp_idx` (`input_subset_id`,`title`)
) ENGINE=MyISAM

INPUT_SUBSET_ID=3436

TEMP_DIR=/lustre/scratch109/ensembl/funcgen/mn1/qc/${INPUT_SUBSET_ID}
mkdir -p $TEMP_DIR
GZIPPED_FASTQ_FILE=$(mysql -N -B $DB_MYSQL_ARGS -e "select local_url from input_subset_tracking where input_subset_id = ${INPUT_SUBSET_ID}")

echo $GZIPPED_FASTQ_FILE

fastqc -o $TEMP_DIR $GZIPPED_FASTQ_FILE

FASTQC_DIR=$(find $TEMP_DIR -maxdepth 1 -mindepth 1 -type d)

SUMMARY_FILE=$FASTQC_DIR/summary.txt

echo $SUMMARY_FILE

./scripts/sequencing/load_fastqc_summary_file.pl --input_subset_id $INPUT_SUBSET_ID --summary_file $SUMMARY_FILE | mysql $DB_MYSQL_ARGS

./scripts/sequencing/load_fastqc_summary_file.pl --input_subset_id 3 --summary_file /lustre/scratch109/ensembl/funcgen/mn1/ersa/faang/alignments/homo_sapiens/GRCh38/3526/histone_control_fastqc/summary.txt | mysql $DB_MYSQL_ARGS

=head1 DESCRIPTION

=cut

use strict;
use Data::Dumper;
use Getopt::Long;

my $summary_file;
my $input_subset_id;

my %config_hash = (
  "summary_file"    => \$summary_file,
  "input_subset_id" => \$input_subset_id,
);

my $result = GetOptions(
  \%config_hash,
  'input_subset_id=s',
  'summary_file=s',
);

die unless(-e $summary_file);
die unless($input_subset_id);

open IN, $summary_file;

while (my $current_line = <IN>) {
  chomp $current_line;
  #print " - $current_line\n";
  my @f = split "\t", $current_line;
  #print Dumper(\@f);
  my $sql = "INSERT INTO input_subset_fastqc (input_subset_id,status,title,file_name) VALUES (".$input_subset_id.", '".$f[0]."', '".$f[1]."', '".$f[2]."')";
  
  print "$sql;\n";
}

