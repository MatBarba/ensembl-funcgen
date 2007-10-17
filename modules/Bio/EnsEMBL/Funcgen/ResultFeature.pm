#
# Ensembl module for Bio::EnsEMBL::Funcgen::ResultFeature
#
# You may distribute this module under the same terms as Perl itself

=head1 NAME

Bio::EnsEMBL::Funcgen::ResultFeature - A module to represent a lightweight ResultFeature object

=head1 SYNOPSIS

use Bio::EnsEMBL::Funcgen::ResultFeature;

my $rfeature = Bio::EnsEMBL::Funcgen::ResultFeature->new_fast([$start, $end, $score ]);

my @rfeatures = @{$rset->get_displayable_ResultFeature_by_Slice($slice)};

foreach my $rfeature (@rfeatures){
    my $score = $rfeature->score();
    my $rf_start = $rfeature->start();
    my $rf_end = $rfeature->end();
}

=head1 DESCRIPTION

This is a very sparse class designed to be as lightweight as possible to enable fast rendering in the web browser.
As such only the information absolutely required is contained.  Any a piori information is omitted e.g. seq_region_id, 
this will already be known as ResultFeatures are retrieved via a Slice method in ResultSet via the ResultSetAdaptor, 
likewise with analysis and experimental_chip information.  ResultFeatures are transient objects, in that they are not 
stored in the DB, but are a very small subset of information from the result and oligo_feature tables. ResultFeatures 
should only be generated by the ResultSetAdaptorast here is no parameter checking in place.


=head1 AUTHOR

This module was written by Nathan Johnson.

=head1 CONTACT

Post comments or questions to the Ensembl development list: ensembl-dev@ebi.ac.uk

=head1 METHODS

=cut

use strict;
use warnings;

#Could set global named vars here for element names. Would take more memory

package Bio::EnsEMBL::Funcgen::ResultFeature;



=head2 new_fast

  Args       : Arrayref with attributes start, end, score as the element of the array IN THAT ORDER.
  Example    : none
  Description: Fast and list version of new. Only works if the code is very disciplined.
  Returntype : Bio::EnsEMBL::Funcgen::ResultFeature
  Exceptions : None
  Caller     : ResultSetAdaptor
  Status     : At Risk

=cut

sub new_fast {
  #my ($class, $arrayref)  = @_;
  #return bless ($arrayref, $class);
  bless $_[1], $_[0];
}




=head2 start

  Example    : my $start = $rf->start();
  Description: Getter of the start attribute for ResultFeature
               objects.
  Returntype : int
  Exceptions : None
  Caller     : General
  Status     : At Risk

=cut

sub start {  $_[0]->[0];}


=head2 end

  Example    : my $start = $rf->end();
  Description: Getter of the end attribute for ResultFeature
               objects.
  Returntype : int
  Exceptions : None
  Caller     : General
  Status     : At Risk

=cut

sub end {  $_[0]->[1];}

=head2 score

  Example    : my $score = $rf->score();
  Description: Getter of the score attribute for ResultFeature
               objects
  Returntype : string/float/double?
  Exceptions : None
  Caller     : General
  Status     : At Risk

=cut

sub score {  $_[0]->[2];}




1;

