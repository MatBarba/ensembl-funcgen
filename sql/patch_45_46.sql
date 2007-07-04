-- add feature_type and cell_type columns result_set
alter table result_set add  `cell_type_id` int(10) unsigned default NULL;
alter table result_set add  `feature_type_id` int(10) unsigned default NULL;
drop index `name_analysis_idx` on result_set;
create unique index `unique_idx` on result_set (name, analysis_id, feature_type_id, cell_type_id);

-- now patch all cell_type and feature_type entries in result_set
--chip sets first
update result_set rs, chip_channel cc, experimental_chip ec set rs.feature_type_id=ec.feature_type_id where rs.result_set_id=cc.result_set_id and cc.table_name='experimental_chip' and cc.table_id=ec.experimental_chip_id;
update result_set rs, chip_channel cc, experimental_chip ec set rs.cell_type_id=ec.cell_type_id where rs.result_set_id=cc.result_set_id and cc.table_name='experimental_chip' and cc.table_id=ec.experimental_chip_id; 
-- now channel sets
update result_set rs, chip_channel cc, channel c, experimental_chip ec set rs.feature_type_id=ec.feature_type_id where rs.result_set_id=cc.result_set_id and cc.table_name='channel' and cc.table_id=c.channel_id and c.experimental_chip_id=ec.experimental_chip_id; 
update result_set rs, chip_channel cc, channel c, experimental_chip ec set rs.cell_type_id=ec.cell_type_id where rs.result_set_id=cc.result_set_id and cc.table_name='channel' and cc.table_id=c.channel_id and c.experimental_chip_id=ec.experimental_chip_id; 


-- change all ids to int(10), 
-- add UNIQUE KEY `name_idx` (name) on data_set
-- alter key on array_chip  UNIQUE KEY `array_design_idx` (`array_id`, `design_id`)
-- recreate predicted_feature as annotated_feature

-- add enum on channel type TOTAL, EXPERIMENTAL & psuedo channels

-- patch feature set for ctcf, re-add new nessie analysis 14



-- add core regulatory tables as supporting_feature tables
-- regulatory_factor_coding is empty and unused?


-- supporting feature table or import directly into annotated feature
-- where do we draw the line between what goes in supporting rather than annotated?
-- what do we do about the overloading of the feature_type table?
-- supporting features must have multiple insatnces of feature_type with unique ids
-- i.e. high volume e.g. individual miRNAs

CREATE TABLE `supporting_feature` (
 `supporting_feature_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(255) NOT NULL default '',
  `seq_region_id` int(10) unsigned NOT NULL default '0',
  `seq_region_start` int(10) unsigned NOT NULL default '0',
  `seq_region_end` int(10) unsigned NOT NULL default '0',
  `seq_region_strand` tinyint(4) NOT NULL default '0',
  `analysis_id` smallint(5) unsigned NOT NULL default '0',
  `regulatory_factor_id` int(10) unsigned default NULL,
  `coord_system_id` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`supporting_feature_id`),
  KEY `seq_region_idx` (`seq_region_id`,`analysis_id`,`seq_region_start`),
  KEY `seq_region_idx_2` (`seq_region_id`,`seq_region_start`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


-- imported core regulatory_feature/factor/search_region here
--insert into supporting_feature(select *, 1 from regulatory_feature);

--strip off ENST prefixes for names??


-- add feature_type_id column to replace type
alter table regulatory_factor add feature_type_id int(10) unsigned NOT NULL default '0';
insert into feature_type(name, class, description) values('miRNA Target', 'RNA', 'miRNA target motif');
insert into feature_type(name, class, description) values('Transcription Factor', 'TRANSCRIPTION FACTOR', 'Transcription factor motif');
insert into feature_type(name, class, description) values('Transcription Factor Complex', 'TRANSCRIPTION FACTOR', 'Transcription complex factor motif');

update regulatory_factor rf, feature_type ft set rf.feature_type_id=ft.feature_type_id where rf.type='miRNA_target' and ft.name='miRNA Target';

--don't need to update other as they are all NULL

-- remove old type column

alter table regulatory_factor drop type;


--we need to split the regulatory_search_region table to extract the xrefs


-- add regulatory factor types to feature_type


-- need to finish off the reg feature stuff, but doing cs stuff first


-- Remove spurious cs
delete from coord_system where coord_system_id =2459;

-- change schema_build to take 10
alter table coord_system change `schema_build` `schema_build` varchar(10) default NULL;



-- add new table

CREATE TABLE `seq_region` (
  `seq_region_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(40) NOT NULL default '',
  `coord_system_id` int(10) unsigned NOT NULL default '0',
  `core_seq_region_id` int(10) unsigned NOT NULL default '0',
  `schema_build` varchar(10) default NULL,
  PRIMARY KEY  (`seq_region_id`, `core_seq_region_id`, `coord_system_id`),
  KEY `name` (`name`, `coord_system_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1; 

-- it maybe possible to have 2 seq_regions on different levels with the same name
-- there fore have to use core cs id in primary key
-- order of extra primary key members doesn't really matter as we'll never query on them?
-- swapped order of ke to name coord_system_id, as we will probably want to query on name primarily
-- why does core table have cs id key?

-- populate new seq_regions (takes a while)
 insert into seq_region(core_seq_region_id, coord_system_id, schema_build) select distinct(pf.seq_region_id), pf.coord_system_id, cs.schema_build from probe_feature pf, coord_system cs where pf.coord_system_id = cs.coord_system_id;
-- !!!!!!!!!!!!!!!!!!! need to do this on probe_feature, to make sure everything is captured
-- then we need to update the names from the core DB

-- we need to do this for 25_34e cs_id 2458 which is only on predicted_features too.
insert into seq_region(core_seq_region_id, coord_system_id, schema_build) select distinct(pf.seq_region_id), pf.coord_system_id, cs.schema_build from predicted_feature pf, coord_system cs where pf.coord_system_id = cs.coord_system_id and pf.coord_system_id=2458;

select "You need to walk through the rest of this patch manually!";
exit;

-- can we do a system call from within mysql?
-- to do the name update we need to query the archive for each schema build in coord_system to generate some temp table thus:
-- e.g. mysql -hensembldb.ensembl.org -uanonymous -e "select seq_region_id, name from seq_region;" homo_sapiens_core_36_35i > ~/homo_sapiens_core_36_35i.seq_regions.txt

create table `45_36g`(
	`seq_region_id` int(10) unsigned NOT NULL auto_increment,
	`name` varchar(40) NOT NULL default '',
    PRIMARY KEY  (`seq_region_id`),
    KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

create table `44_36f`(
	`seq_region_id` int(10) unsigned NOT NULL auto_increment,
	`name` varchar(40) NOT NULL default '',
    PRIMARY KEY  (`seq_region_id`),
    KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

create table `43_36e`(
	`seq_region_id` int(10) unsigned NOT NULL auto_increment,
	`name` varchar(40) NOT NULL default '',
    PRIMARY KEY  (`seq_region_id`),
    KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

create table `42_36d`(
	`seq_region_id` int(10) unsigned NOT NULL auto_increment,
	`name` varchar(40) NOT NULL default '',
    PRIMARY KEY  (`seq_region_id`),
    KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


create table `36_35i`(
	`seq_region_id` int(10) unsigned NOT NULL auto_increment,
	`name` varchar(40) NOT NULL default '',
    PRIMARY KEY  (`seq_region_id`),
    KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

create table `25_34e`(
	`seq_region_id` int(10) unsigned NOT NULL auto_increment,
	`name` varchar(40) NOT NULL default '',
    PRIMARY KEY  (`seq_region_id`),
    KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;



-- Then import each of these files as temp table 
-- e.g.
    
LOAD DATA LOCAL INFILE '~/homo_sapiens_core_25_34e.seq_regions.txt' into table 25_34e;
LOAD DATA LOCAL INFILE '~/homo_sapiens_core_36_35i.seq_regions.txt' into table 36_35i;
LOAD DATA LOCAL INFILE '~/homo_sapiens_core_45_36g.seq_regions.txt' into table 45_36g;
LOAD DATA LOCAL INFILE '~/homo_sapiens_core_43_36e.seq_regions.txt' into table 43_36e;
LOAD DATA LOCAL INFILE '~/homo_sapiens_core_44_36f.seq_regions.txt' into table 44_36f;
LOAD DATA LOCAL INFILE '~/homo_sapiens_core_42_36d.seq_regions.txt' into table 42_36d;

-- now update the names in seq_region for each schema_build

update seq_region sr, 25_34e osr set sr.name=osr.name where sr.core_seq_region_id=osr.seq_region_id and sr.schema_build='25_34e';
update seq_region sr, 36_35i osr set sr.name=osr.name where sr.core_seq_region_id=osr.seq_region_id and sr.schema_build='36_35i';
update seq_region sr, 45_36g osr set sr.name=osr.name where sr.core_seq_region_id=osr.seq_region_id and sr.schema_build='45_36g';
update seq_region sr, 43_36e osr set sr.name=osr.name where sr.core_seq_region_id=osr.seq_region_id and sr.schema_build='43_36e';
update seq_region sr, 44_36f osr set sr.name=osr.name where sr.core_seq_region_id=osr.seq_region_id and sr.schema_build='44_36f';
update seq_region sr, 42_36d osr set sr.name=osr.name where sr.core_seq_region_id=osr.seq_region_id and sr.schema_build='42_36d';

-- now drop the tmp tables
drop table 25_34e;
drop table 36_35i;
drop table 45_36g;
drop table 43_36e;
drop table 44_36f;
drop table 42_36d;


-- now create tmp of seq_region to generate valid seq_region_ids
drop table if exists tmp_seq_region;
CREATE TABLE `tmp_seq_region` (
  `seq_region_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(40) NOT NULL default '',
  `coord_system_id` int(10) unsigned NOT NULL default '0',
  `core_seq_region_id` int(10) unsigned NOT NULL default '0',
  `schema_build` varchar(10) default NULL,
  PRIMARY KEY  (`seq_region_id`, `core_seq_region_id`, `coord_system_id`),
  KEY `name` (`name`, `coord_system_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1; 

-- populate tmp table
insert into tmp_seq_region select * from seq_region;

drop table seq_region;

-- new primary key still not working!!!

CREATE TABLE `seq_region` (
  `seq_region_id` int(10) unsigned NOT NULL auto_increment,
  `name` varchar(40) NOT NULL default '',
  `coord_system_id` int(10) unsigned NOT NULL default '0',
  `core_seq_region_id` int(10) unsigned NOT NULL default '0',
  `schema_build` varchar(10) default NULL,
  PRIMARY KEY  (`seq_region_id`, `name`, `schema_build`),
  KEY `coord_system_id` (`coord_system_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1; 

insert into seq_region (select * from tmp_seq_region);

-- update on self nest select work around isn't wrking any more????
--select sr.name, sr.seq_region_id as new_id, sr1.seq_region_id as old_id, sr.coord_system_id from (select seq_region_id, name, coord_system_id from seq_region group by coord_system_id) sr, seq_region sr1 where sr.coord_system_id=sr1.coord_system_id;

-- have to create tmp table

drop table if exists tmp1_seq_region;
CREATE TABLE `tmp1_seq_region` (
   `old_seq_region_id` int(10) unsigned NOT NULL auto_increment,
   `new_seq_region_id` int(10) unsigned NOT NULL default '0',
   `coord_system_id` int(10) unsigned NOT NULL default '0',
   PRIMARY KEY  (`old_seq_region_id`),
   KEY (`coord_system_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1; 


insert into tmp1_seq_region (select sr1.seq_region_id as old_id, sr.seq_region_id as new_id, sr.coord_system_id from (select seq_region_id, name, coord_system_id from tmp_seq_region group by name) sr, tmp_seq_region sr1 where sr.coord_system_id=sr1.coord_system_id and sr.name=sr1.name);


update seq_region sr, tmp1_seq_region tsr set sr.seq_region_id=tsr.new_seq_region_id where sr.coord_system_id=tsr.coord_system_id and sr.seq_region_id=.tsr.old_seq_region_id;


--finally clean up the tables
drop table tmp_seq_region;
drop table tmp1_seq_region;



--- Rename predicted_feature to annotated_feature ---

CREATE TABLE `annotated_feature` (
  `annotated_feature_id` int(10) unsigned NOT NULL auto_increment,
  `seq_region_id` int(10) unsigned NOT NULL default '0',
  `seq_region_start` int(10) unsigned NOT NULL default '0',
  `seq_region_end` int(10) unsigned NOT NULL default '0',
  `seq_region_strand` tinyint(1) NOT NULL default '0',
  `coord_system_id` int(10) unsigned NOT NULL default '0',	
  `display_label` varchar(60) default NULL,
  `score` double default NULL,
  `feature_set_id` int(10) unsigned NOT NULL default '0',
  PRIMARY KEY  (`anotated_feature_id`),
  KEY `seq_region_idx` (`seq_region_id`,`seq_region_start`),
  KEY `feature_set_idx` (`feature_set_id`)	  
) ENGINE=MyISAM DEFAULT CHARSET=latin1 MAX_ROWS=100000000 AVG_ROW_LENGTH=80;


insert into annotated_feature (select * from predicted_feature);

update meta_coord set table_name='annotated_feature' where table_name='predicted_feature';

drop table predicted_feature;
