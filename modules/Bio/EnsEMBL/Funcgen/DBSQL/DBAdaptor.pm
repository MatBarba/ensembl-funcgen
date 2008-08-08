
=head1 NAME

Bio::EnsEMBL::Funcgen::DBSQL::DBAdaptor
  
=head1 SYNOPSIS

my $db = Bio::EnsEMBL::Funcgen::DBSQL::DBAdaptor->new
  (
   -host => "ensembldb.ensembl.org",
   -dbname => "mus_musculus_funcgen_41_36b",
   -species => "Mus_musculus",
   -user => "anonymous",
   -dnadb => $mouse_core_db,
   -port => '3307',
  );

my $experiment_adaptor = $db->get_ExperimentAdaptor();

=back

=head1 DESCRIPTION

This is a wrapper method for Bio::EnsEMBL::DBAdaptor, providing Funcgen
specific methods.

=head1 CONTACT

Post questions to the EnsEMBL development list <ensembl-dev@ebi.ac.uk>

=head1 METHODS

The rest of the documentation details each of the object methods. Internal
methods are usually preceded with a _

=head1 AUTHOR(S)

Nathan Johnson, njohnson@ebi.ac.uk


=cut

################################################################################

package Bio::EnsEMBL::Funcgen::DBSQL::DBAdaptor;

use strict;

use vars qw(@ISA);

@ISA = qw(Bio::EnsEMBL::DBSQL::DBAdaptor);# Bio::EnsEMBL::Funcgen::Helper);

use DBI;

use Bio::EnsEMBL::Utils::Exception qw(warning throw deprecate stack_trace_dump);
use Bio::EnsEMBL::DBSQL::DBAdaptor;
use Bio::EnsEMBL::DBSQL::DBConnection;
use Bio::EnsEMBL::Registry;
my $reg = "Bio::EnsEMBL::Registry";




=head2 is_stored_and_valid

  Arg [1]    : string - class namespace
  Arg [1]    : Bio::EnsEMBL::Funcgen::Storable e.g. ResultSet etc.
  Example    : $db->is_stored_and_valid('Bio::EnsEMBL::Funcgen::ResultSet', $rset);
  DESCRIPTION: Validates object class and stored status
  Returntype : none
  Exceptions : Throws if Storable is not valid or stored
  Caller     : general - Adaptors, objects will probably be better off implementing in situ.
               This is to avoid having to test for the adaptor for every object which could slow things down
  Status     : At risk

=cut


#This has to be in the DBAdaptor rather than Storable as we're 
#calling isa on self otherwise which we don't know whether we can

sub is_stored_and_valid{
  my ($self, $class, $obj) = @_;

  if(! (ref($obj) && $obj->isa($class) && $obj->is_stored($self))){
	#throw or warn and return boolean?
	throw('Must provide a valid stored '.$class."\nParameter provided was:\t$obj");
  }

  return;
}





#Move these to Helper.pm! Check method dependencies first!

=head2 load_table_data

  Arg [1]    : string - table name
  Arg [1]    : string - file path for file to load
  Example    : $db->load_table_data("result",  $self->get_dir($results_dir)."/result.txt");
  DESCRIPTION: Generic method to load a file into a specified table
  Returntype : none
  Exceptions : Throws if argument not supplied
  Caller     : general
  Status     : At risk - only used by for results at present, to be removed

=cut

sub load_table_data{
  my ($self, $table, $file, $ssh) = @_;

  chmod 0755, $file;

  #  warn("Importing $table data from $file");
  #if this gives an Errcode: 2, then your mysql instance cannot see the file.
  #This could be due to a soft link on a visible directory to an unmounted filesystem
  #change this to use the mysqlimport?



  #This is failing as ssh is not set up to login silently without password prompt
  #Need to defined ssh keys?

  #(my $tmp_file = $file) =~ s/.*\///;
  #$tmp_file = '/tmp/'.$tmp_file;

  #my $scp = 'scp $(hostname):'.$file." ".$self->dbc->host().":${tmp_file}";
  #my $sql = "load data infile '$tmp_file' into table $table";
  #$self->dbc->do($sql);
  #remove tmp file via ssh if load successful

  my $cmd = 'mysqlimport -L '.$self->connect_string().' '.$file;
  system($cmd) == 0 || throw("Failed to load data from $file\nExit code:\t".($?>>8)."\n$!");
  
  return;
}



=head2 get_available_adaptors

  Example    : my %pairs = %{$dba->get_available_adaptors()};
  Description: gets a hash of the available adaptors
  ReturnType : reference to a hash
  Exceptions : none
  Caller     : Bio::EnsEMBL::Utils::ConfigRegistry
  Status     : Stable

=cut


#will adding SliceAdaptor here use the dna DB? i.e. the core DB rather than the efg DB?

sub get_available_adaptors{
  my ($self) = shift;
  
  my %pairs = (
			   'Channel'            => 'Bio::EnsEMBL::Funcgen::DBSQL::ChannelAdaptor',
			   'ExperimentalChip'   => 'Bio::EnsEMBL::Funcgen::DBSQL::ExperimentalChipAdaptor',
			   'ArrayChip'          => 'Bio::EnsEMBL::Funcgen::DBSQL::ArrayChipAdaptor',
			   'Array'              => 'Bio::EnsEMBL::Funcgen::DBSQL::ArrayAdaptor',
			   'ProbeSet'           => 'Bio::EnsEMBL::Funcgen::DBSQL::ProbeSetAdaptor',
			   'Probe'              => 'Bio::EnsEMBL::Funcgen::DBSQL::ProbeAdaptor',
			   'ProbeFeature'       => 'Bio::EnsEMBL::Funcgen::DBSQL::ProbeFeatureAdaptor',
			   'AnnotatedFeature'   => 'Bio::EnsEMBL::Funcgen::DBSQL::AnnotatedFeatureAdaptor',
			   'RegulatoryFeature'  => 'Bio::EnsEMBL::Funcgen::DBSQL::RegulatoryFeatureAdaptor',
			   'Experiment'         => 'Bio::EnsEMBL::Funcgen::DBSQL::ExperimentAdaptor',
			   'DataSet'            => 'Bio::EnsEMBL::Funcgen::DBSQL::DataSetAdaptor',
			   'FeatureType'        => 'Bio::EnsEMBL::Funcgen::DBSQL::FeatureTypeAdaptor',
			   'FGCoordSystem'      => 'Bio::EnsEMBL::Funcgen::DBSQL::CoordSystemAdaptor',#prepended FG o override core  adaptor
			   'MetaCoordContainer' => 'Bio::EnsEMBL::Funcgen::DBSQL::MetaCoordContainer',
			   'FeatureSet'         => 'Bio::EnsEMBL::Funcgen::DBSQL::FeatureSetAdaptor',
			   'ResultSet'          => 'Bio::EnsEMBL::Funcgen::DBSQL::ResultSetAdaptor',
			   'DataSet'            => 'Bio::EnsEMBL::Funcgen::DBSQL::DataSetAdaptor',
			   'ExperimentalSet'    => 'Bio::EnsEMBL::Funcgen::DBSQL::ExperimentalSetAdaptor',
			   'ExternalFeature'    => 'Bio::EnsEMBL::Funcgen::DBSQL::ExternalFeatureAdaptor',
			   'CellType'           => 'Bio::EnsEMBL::Funcgen::DBSQL::CellTypeAdaptor',
			   'DBEntry'            => 'Bio::EnsEMBL::Funcgen::DBSQL::DBEntryAdaptor',
			   'Slice'              => 'Bio::EnsEMBL::Funcgen::DBSQL::SliceAdaptor',
			   'ResultFeature'      => 'Bio::EnsEMBL::Funcgen::DBSQL::ResultFeatureAdaptor',
			   
			   #New collections
			   'ResultFeatureCollection' => 'Bio::EnsEMBL::Funcgen::Collection::ResultFeature',

	 	       
	       #add required EnsEMBL(core) adaptors here
	       #Should write/retrieve from efg not dna db
	       'Analysis'           => 'Bio::EnsEMBL::DBSQL::AnalysisAdaptor',
	       "MetaContainer"      => "Bio::EnsEMBL::DBSQL::MetaContainer",
	      );
  
  return (\%pairs);
}

=head2 _get_schema_build

  Arg [1]    : Bio::EnsEMBL::Funcgen::DBSQL::DBAdaptor or Bio::EnsEMBL::DBSQL::DBAdaptor
  Example    : my $shema_build = $db->_get_schema_build($slice->adaptor->db());
  DESCRIPTION: 
  Returntype : string
  Exceptions : Throws if argument not supplied
  Caller     : general
  Status     : At risk - replace with MetaContainer method

=cut


#Slightly hacky convinience method to get the data/schema.version/build from a feature slice

sub _get_schema_build{
  my ($self, $db) = @_;

  #Have to explicitly pass self->db to this method if required, this highlights which db is being tested 
  throw("Need to define a DBAdaptor to retrieve the schema_build from") if (! $db);
  #avoided using dnadb by default to avoid obfuscation of behaviour
  
  my @dbname = split/_/, $db->dbc->dbname();

  #warn "dbname is $schema_build";

  my $schema_build = pop @dbname;
  $schema_build = pop(@dbname).'_'.$schema_build;


  return $schema_build;
}

=head2 get_SliceAdaptor

  Arg [1]    : (optional) int - coord_system_id
  Example    : my $slice_adaptor = $db->get_SliceAdaptor($cs->dbID());
  DESCRIPTION: Retrieves a slice adaptor from the dnadb corresponding 
               to the coord_system_id, or retrieves from the default dnadb
  Returntype : Bio::EnsEMBL::DBSQL::SLiceAdaptor
  Exceptions : Throws if arguments not supplied
  Caller     : general
  Status     : At risk - remove and add this to BaseFeatureAdaptor->fetch_all_by_Slice_constraint

=cut

#Funcgen specific, get's Adaptor from dnadb, or validates/autogenerates from coord_system_id
#Only imlpmented in _obj_from_sth, rely on feature_slice elsewhere

#Not in registry as get_adaptor will not take $cs_id arg

#Move all this dnadb specif stuff to dnadb, to ensure all dnadb derived object are from correct DB
#All dnadb centric methods should then either use the default or pass a new coordsysid to redefine the dnadb
#Should we make this mandatory to ensure dnadb is redefined, this would avoid getting data from wrong db, but maybe a pain in the butt
#also, changing dnadb would work, which isn't pretty

#Are all dnadb(feature) data retrievals mediated by a Slice?
#ProbeFeatureADaptor has by probe/probeset queries which would retrieve for all DBs/coord systems,
#any further dnadb derived methods on the objects would have to resolve coord system issue and use correct dnadb
#or should we only retrieve for current dnadb?

#rename this DNADB|FGSliceAdaptor?
#as this works differently to normal method
#the problem arises when we get features from the DB by none Slice methods, these may not refer to the current dnadb
#so we have to implement checks in non slice based feature calls to make sure we nest the correct dnadb adaptor

#sub get_SliceAdaptor{
#  my ($self, $cs_id) = @_;

  #$cs_id is only used in ProbeFeatureAdaptor, no longer used
  #but is this correct?


  #Need to add check if current cs_id refers to current dnadb
  
  #extract this to a "validate_dnadb" method
  #This will be called for each noon Slice based fetch method for each feature returned
  #or should we group the fetch statements by coord system id and try and do it more efficiently
  
  #is this "validate_coordsystem"?
  
  #Can we cache the DNA DBAdaptors against the FG csis rather than doing this everytime?
  #will this be too much memory overhead? Registry is already a cache, can we just reference the registry?
 


 
#  if($cs_id){
#    my $csa = $self->get_FGCoordSystemAdaptor();
#    my $fg_cs = $csa->fetch_by_dbID($cs_id);
    #my $schema_build = $fg_cs->schema_build();
    #Get species here too
    
#	if(! $fg_cs->contains_schema_build($self->_get_schema_build($self->dnadb()))){
    #if($schema_build ne $self->_get_schema_build($self->dnadb())){
#	  my $lspecies = $reg->get_alias($self->species());
      #warn "Generating dnadb schema_build is $schema_build and dnadb is ".$self->_get_schema_build($self->dnadb())."\n";

      #get from cs_id
      #can we return direct from registry for older versions?
      #best to generate directl as we may have only loaded the current DBs
      #set dnadb here and return after block

	  #should we really permanently set this here
	  #what is we were on ens-livemirror?
	  #we would then lose that association
	  #should we change dnadb to be totally dynamic anyway and only set it for the current default?

#	  my $dnadb = Bio::EnsEMBL::DBSQL::DBAdaptor->new
#		(						
#		 -host => "ensembldb.ensembl.org",
#		 -user => "anonymous",
#		 -species => $lspecies,
#		 -dbname => $lspecies.'_core_'.$fg_cs->get_latest_schema_build(),
#		 -group => 'core',
#		 #-port  => 5306,
#		);


	  #This new port only has from 48 onwards!!!
  
      
#      $self->dnadb($dnadb);
      
#    }
#  }
  
#  return $self->dnadb->get_SliceAdaptor();#this causes circular reference if dnadb not set i.e if this is generated from scratch without a dnadb rather than from the reg?????
#}




#Redefine dbadb here to add coordsystem

=head2 dnadb

  Arg [1]:     Bio::EnsEMBL::DBSQL::DBAdaptor
  Arg [2]:     string - coord_system name e.g. chromosome
  Usage :      my $dnadb = $db->dnadb(); 
  Description: returns the database adaptor where the dna lives i.e. the core db for a given species
               There are at least 2 cases where you need to set this explicitly
               1.  If you want to retrieve features on an assembly which is not the default in 
               the correspeonding core DB with matching schema_build
               2.  If the corresponding core DB is not available on the default ensembl DB 
               server(ensembldb/ens-livemirror) i.e. before a new release.
  Status :     At risk. - Might remove validation of CS

=cut

#This is not taking account of the registry which may have already been loaded
#So we may be setting the dnadb correctly here
#But it won't be the default core db in the registry, it will be cached as species1 or something?

sub dnadb { 
  my ($self, $dnadb, $cs_name) = @_; 

  #super dnadb automatically sets the current DBAdaptor as the dnadb
  #this is the only way of checking whether it has been defined properly.
 
  if($dnadb || $self->SUPER::dnadb->group() ne 'core'){

	if(! $dnadb){

	  my $lspecies = $reg->get_alias($self->species());

	  throw('Must provide a species to automatically set dnadb') if $lspecies eq 'default';
	
	  
	  my $schema_build = $self->_get_schema_build($self);
	  my $dbname = $lspecies.'_core_'.$schema_build;
	  my ($schema, $assembly_build) = split/_/, $schema_build;
	  my @assm_build = split//,$assembly_build;
	  my $build = pop @assm_build;#This assumes gene build is only ever a single character
	  my $assembly = join('', @assm_build);

	  my $count = 0;
	  my $connection_error = 'FIRST_TRY';
	  my $cnt = 0;
	  my @az = ('a'..'z');
	  my (%az, $port);
	  map $az{$_} = $cnt++, @az;
	  

	  #while($@ && $count <2){
	  while($connection_error && $count <3){
		#Create and test the DB
		$port = ($schema <48) ? 3306 : 5306;
		


		$dnadb = Bio::EnsEMBL::DBSQL::DBAdaptor->new
		  (						
		   -host    => 'ensembldb.ensembl.org',
		   -user    => "anonymous",
		   -species => $lspecies,
		   -dbname  => $dbname,
		   -group   => 'core',
		   -port    => $port,
		  );
		  
		#do not trap this time as we're not going to guess anymore
		if($count >0){
		  warn "Attempting to connect to:\t$dbname\n";
		}

		#This is not suppressing the error output.
		eval { $dnadb->dbc()->db_handle(); };

		$connection_error = $@;

		if($connection_error){
		  $count++;
		  #First try same assembly/build on old schema
		  #Then try decremented build on same old schema before trying 
		  #start with 49_36k which matches current schema_build
		  #then       48_36k(incase we're dealing with a dev db or a gene build which hasn't been incremented)
		  #then try   48_36j

		  #we could do these alternately with a modus operator? 3 times is enough
		  $schema-- if $count == 1;

		  if($count > 1){
			$build = $az[($az{$build} - 1)];
			#no build if z
			$build = '' if $build eq 'z';
		  }
		  #else try same build first
		  $dbname = $lspecies.'_core_'.$schema.'_'.$assembly.$build;
		  
		}
	  }

	  #Will this be true, as we will have evaluated another while?
	  throw("Could not auto-determine the dnadb, please pass a -dnadb parameter\n$connection_error") if $connection_error;
	}
	
	
	$self->SUPER::dnadb($dnadb); 

	#set default coordsystem here, do we need to handle non-chromosome here
	$cs_name ||= 'chromosome';
	my $cs = $dnadb->get_CoordSystemAdaptor->fetch_by_name($cs_name);
    #this will only add the default assembly for this DB, if we're generating on another we need to add it separately.
    #or shall we fetch/add all by name?
   
	#This is a non-obious store behaviour!!!!!!!!!!!!!!!!!
	#This can result in coord_system entries being written
	#unknowingly if you are using the efg DB with a write user/pass
    $self->get_FGCoordSystemAdaptor->validate_and_store_coord_system($cs);
  }

  return $self->SUPER::dnadb();#never pass @_ here!
} 


=head2 set_dnadb_by_assembly_version

  Arg [1]:     string - Assembly version e.g. for homo_sapiens_core_49_36k it would be 36
  Usage :      $efgdb->set_dnadb_by_assembly_version('36'); 
  Description: Sets the dnadb to the latest version given the assembly version
  Exceptions:  Throws if no assembly version provided or cannot for appropriate dnadb on ensembldb
  Status :     At risk

=cut



sub set_dnadb_by_assembly_version{
  my ($self, $assm_ver) = @_;

  throw('Must provide and assembly version to set the dnadb') if ! defined $assm_ver;

  #We should probably allow for non-ensembldb core DBs here too
  #Do we need to account for other ports, staging etc for release?
  #These should run fine on 3306.
  my $current_port = $self->dnadb->dbc->port;
  #This is assuming dnadb port will only ever be one or the other
  #This assumption is restricted to ensembldb in the port loop
  my $tmp_port = ($current_port == 3306) ? 5306 : 3306;
  my @ports = ($current_port, $tmp_port);


  my $sql = 'show databases like "'.$self->species.'_core_%_'.$assm_ver.'%"';
  my ($dbh, @dbnames, $new_port);

  foreach my $port(@ports){
	
	if($port == $current_port){
	  $dbh = $self->dnadb->dbc->db_handle;
	}
	elsif($self->dnadb->dbc->host eq 'ensembldb.ensembl.org'){
	
	  $dbh = DBI->connect("DBI:mysql:host=ensembldb.ensembl.org;port=${port}",
						  'anonymous', 
						  '', 
						  {'RaiseError' => 1});
	  #should we eval this?
	}
	

	@dbnames = map {$_ = "@$_"} @{$dbh->selectall_arrayref($sql)};

	#sort and filter out non-core DBs
	@dbnames = grep(/core_[0-9]/, sort @dbnames);
  
	if(scalar(@dbnames)==0){
	  warn('Failed to find '.$self->species.' funcgen DB for assembly version '.$assm_ver.' using '.$self->dnadb->dbc->host.':'.$self->dnadb->dbc->port);
	}
	else{
	  $new_port = $port;
	  last;
	}
  }

  throw("Failed to find dnadb with assembly version $assm_ver") if(scalar(@dbnames)==0);
  
   
  #Need to delete core DB from registry before creating new one
  my $db = $reg->reset_DBAdaptor($self->species, 'core', $dbnames[$#dbnames], undef, $new_port);
    
  $self->dnadb($db);

  return $db;
}


#Group methods, as not adaptor/class for Group(used in ExperimentAdaptor at present)
#will disppear when Group and GroupAdaptor written

=head2 fetch_group_details

  Args       : string - group name
  Example    : my $group =  $db->fetch_group_details('EBI');
  Description: Gets group information for a given name
  Returntype : ARRAYREF
  Exceptions : Throws if no group name defined
  Caller     : general
  Status     : At risk - Move to GroupAdaptor

=cut

sub fetch_group_details{
	my ($self, $gname) = @_;

	throw("Need to specify a group name") if ! $gname;
	my $sql = "SELECT * from experimental_group where name=\"$gname\"";
	return $self->dbc->db_handle->selectrow_array($sql);
}

=head2 import_group

  Arg [1]    : string - group name
  Arg [2]    : string - group location
  Arg [3]    : string - group contact (email or address)
  Example    : $db->import_group('EBI', 'Hinxton', 'njohnson@ebi.ac.uk');
  Description: Imports group information to the database
  Returntype : none
  Exceptions : Throws if arguments not supplied
  Caller     : general
  Status     : At risk - Move to GroupAdaptor

=cut

sub import_group{
	my ($self, $gname, $loc, $contact) = @_;

	throw("Need to supply a group name, location and contact") if (!($gname && $loc && $contact));

	my $sql = "INSERT INTO experimental_group(name, location, contact) VALUES(\"$gname\", \"$loc\", \"$contact\")";
	$self->dbc->do($sql);

	#$self->dbc->db_handle->last_insert_id(undef, undef, undef, undef);	
	return;#return last insert id here?
}


#General Status methods
#will Move to Bio::EnsEMBL::Funcgen::DBSQL::Status

=head2 fetch_all_states

  Arg [1]    : string - table name
  Arg [2]    : int - table id
  Example    : my @states = @{$db->fetch_all_states('channel', 1)};
  Description: Retrieves all states associated with the given table record
  Returntype : Listref
  Exceptions : Throws if arguments not supplied
  Caller     : general
  Status     : At risk - Move to Status

=cut

sub fetch_all_states{
	my ($self, $table, $id) = @_;


	throw("DBAdaptor::fetch_all_states is deprecated");


	throw("Need to specifiy a table and an id to retrieve status") if (! $table || ! $id);


	my $sql = "SELECT state FROM status WHERE table_name=\"$table\" AND table_id=\"$id\"";

	my @states = map $_ = "@$_", @{$self->dbc->db_handle->selectall_arrayref($sql)};

	return \@states;
}


=head2 fetch_status_by_name

  Arg [1]    : string - table name
  Arg [2]    : int - table id
  Arg [3]    : string - status
  Example    : if($db->fetch_status_by_name('channel', 1, 'IMPORTED'){ ... };
  Description: Retrieves given state associated with the table record
  Returntype : ARRAYREF
  Exceptions : Throws if arguments not supplied
  Caller     : general
  Status     : At risk - Move to Stasus

=cut



sub fetch_status_by_name{
	my ($self, $table, $id, $state) = @_;

	throw("DBAdaptor::fetch_status_by_name is deprecated");

	throw("Need to specify a table and an id to retrieve status") if (! $table || ! $id || ! $state);

	#should we enum the state?


	my $sql = "SELECT state FROM status WHERE table_name=\"$table\" AND table_id=\"$id\" AND state=\"$state\"";
	return $self->dbc->db_handle->selectrow_array($sql);
}


=head2 set_status

  Arg [1]    : string - table name
  Arg [2]    : int - table id
  Arg [3]    : string - status
  Example    : $db->set_status('channel', 1, 'IMPORTED');
  DESCRIPTION: RETRIEVES GIVEN STATE ASSOCIATED WITH THE table record
  Returntype : ARRAYREF
  Exceptions : Throws if arguments not supplied
  Caller     : general
  Status     : At risk - Move to Status

=cut


sub set_status{
	my ($self, $table, $id, $state) = @_;

	throw("DBAdaptor::set_status is deprecated");

	throw("Need to supply a table, dbid and a valid status") if (!($table && $id && $state));

	my $sql = "INSERT INTO status(table_id, table_name, state) VALUES(\"$id\", \"$table\", \"$state\")";
	$self->dbc->do($sql);

	return;
}





=head2 connect_string

  Example    : my $import_cmd = 'mysqlimport '.$db->connect_string()." $table_file";
  Description: Retrieves the mysql cmdline connection string
  Returntype : String
  Exceptions : none
  Caller     : general
  Status     : At risk

=cut

sub connect_string{
  my $self = shift;

  return '-h'.$self->dbc->host().' -u'.$self->dbc->username().' -p'.$self->dbc->password()
	.' -P'.$self->dbc->port().' '.$self->dbc->dbname();
}

1;

