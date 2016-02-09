=head1 LICENSE

Copyright [1999-2016] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=head1 CONTACT

  Please email comments or questions to the public Ensembl
  developers list at <http://lists.ensembl.org/mailman/listinfo/dev>.

  Questions may also be sent to the Ensembl help desk at
  <http://www.ensembl.org/Help/Contact>.

=head1 NAME

    Bio::EnsEMBL::Funcgen::Hive::Config::Base;

=head1 CONTACT

    Please contact http://lists.ensembl.org/mailman/listinfo/dev mailing list with questions/suggestions.

=cut
package Bio::EnsEMBL::Funcgen::Hive::Config::Base;

use strict;
use warnings;
use base qw(Bio::EnsEMBL::Hive::PipeConfig::HiveGeneric_conf);

sub default_options {
  my $self = $_[0];  
  
  return {
      %{$self->SUPER::default_options},
      
	dnadb_pass          => $self->o('ENV', 'DNADB_PASS'),
	pass                => $self->o('ENV', 'DB_PASS'),
	dnadb_port          => undef,
	port                => undef,

	# These can probably go:
	#
	ssh                 => undef, #Connect to DBs using ssh(use in Importer)
	result_set_only    => 0, #why is this 0 rather than undef?

      use_tracking_db     => 1,
      species             => undef,

      assembly            => undef,
      work_root_dir     => $self->o('data_root_dir').'/output/'.$self->o('pipeline_name'),
      hive_output_dir   => $self->o('data_root_dir').'/output/'.$self->o('pipeline_name').'/hive_debug',
      alt_data_root_dir => undef,
      verbose => undef,
      archive_root     => undef,
      allow_no_archive => 0,
   };
}

sub pipeline_wide_parameters {
  my ($self) = @_;

  return {
    %{$self->SUPER::pipeline_wide_parameters}, 
    pipeline_name => $self->o('pipeline_name'),

    species        => $self->o('species'),
    default_gender => 'male',
    assembly     => $self->o('assembly'),

    data_root_dir     => $self->o('data_root_dir'),
    work_root_dir     => $self->o('work_root_dir'),
    alt_data_root_dir => $self->o('alt_data_root_dir'), 
    
    archive_root     => $self->o('archive_root'),
    allow_no_archive => $self->o('allow_no_archive'),

    hive_output_dir => $self->o('hive_output_dir'),
    use_tracking_db => $self->o('use_tracking_db'),

      dnadb   => {
         -dnadb_host   => $self->o('dnadb_host'),
         -dnadb_pass   => $self->o('dnadb_pass'),
         -dnadb_port   => $self->o('dnadb_port'),
         -dnadb_user   => $self->o('dnadb_user'),
         -dnadb_name   => $self->o('dnadb_name'),
        },
      out_db  => {
         -host   => $self->o('host'),
         -port   => $self->o('port'),
         -user   => $self->o('user'),
         -pass   => $self->o('pass'),
         -dbname => $self->o('dbname'),
        },
  };
}

sub resource_classes {
  my $self = shift;
  return {
     default                 => { 'LSF' => '' },    
     normal_2GB              => { 'LSF' => ' -M2000 -R"select[mem>2000] rusage[mem=2000]"' },
     normal_monitored        => { 'LSF' => "" },
     normal_high_mem         => { 'LSF' => ' -M5000 -R"select[mem>5000] rusage[mem=5000]"' },
     normal_high_mem_2cpu    => { 'LSF' => ' -n2 -M5000 -R"select[mem>5000] rusage[mem=5000] span[hosts=1]"' },
     normal_monitored_2GB    => {'LSF' => " -M2000 -R\"select[mem>2000]".
                                                " rusage[mem=2000]\"" },
     normal_monitored_4GB    => {'LSF' => " -M4000 -R\"select[mem>4000] rusage[mem=4000]\"" },  
     normal_monitored_8GB    => {'LSF' => " -M8000 -R\"select[mem>8000] rusage[mem=8000]\"" },   
     normal_monitored_16GB   => {'LSF' => " -M16000 -R\"select[mem>16000] rusage[mem=16000]\"" }, 
     normal_16GB_2cpu        => {'LSF' => ' -n2 -M16000 -R"select[mem>16000] rusage[mem=16000] span[hosts=1]"' },
     normal_20GB_2cpu        => {'LSF' => ' -n2 -M20000 -R"select[mem>20000] rusage[mem=20000] span[hosts=1]"' }, 
     normal_25GB_2cpu        => {'LSF' => ' -n2 -M25000 -R"select[mem>25000] rusage[mem=25000] span[hosts=1]"' }, 
     normal_30GB_2cpu        => {'LSF' => ' -n2 -M30000 -R"select[mem>30000] rusage[mem=30000] span[hosts=1]"' },      
     normal_10gb_monitored   => {'LSF' => " -M10000 -R\"select[mem>10000] rusage[mem=10000]\"" },
     normal_5GB_2cpu_monitored => {'LSF' => " -n2 -M5000 -R\"select[mem>5000] rusage[mem=5000] span[hosts=1]\"" },
     normal_10gb             => { 'LSF' => ' -M10000 -R"select[mem>10000] rusage[mem=10000]"' },
     long_monitored          => { 'LSF' => "-q long " },
     long_high_mem           => { 'LSF' => '-q long -M4000 -R"select[mem>4000] rusage[mem=4000]"' },
     long_monitored_high_mem => { 'LSF' => "-q long -M4000 -R\"select[mem>4000] rusage[mem=4000]\"" },
    };
}

1;

