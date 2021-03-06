-- Reasons for use of separate tracking/stats tables was two fold
-- 1 For visibility (although some of this is now integrated into status)
-- 2 As the data model was originally slightly broken, we needed
--   a way to model many to one relationships between merged input_subsets and 
--   individual records in input_subset_tracking

-- TODO
-- 1 Add support for tracking status history



DROP TABLE IF EXISTS `experiment_tracking`;

CREATE TABLE `experiment_tracking` (
  `experiment_id` int(10) unsigned NOT NULL,
  `notes` TEXT default NULL,
  PRIMARY KEY  (`experiment_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--Slight overkill for one notes field, but keep tables separate for visibility



DROP TABLE IF EXISTS `input_set_tracking`;
/* CREATE TABLE `input_set_tracking` (
  `input_set_id` int(10) unsigned NOT NULL,
  `release_version` varchar(45),
  `is_current` int(1),
  `status` enum('OK','REMOVE','REBUILD') default 'OK',
  PRIMARY KEY  (`input_set_id`),
  UNIQUE KEY `name_cell_type_feature_type_idx` (`experiment_name`,`species`,`cell_type`,`feature_type`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
*/


DROP TABLE IF EXISTS `experiment_tracking`;

CREATE TABLE `experiment_tracking` (
  `experiment_id` int(10) unsigned NOT NULL,
  `notes` TEXT default NULL,
  PRIMARY KEY  (`experiment_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


DROP TABLE IF EXISTS `result_set_tracking`;

CREATE TABLE `result_set_tracking` (
  `result_set_id`        int(10) unsigned NOT NULL,
  `idr_max_peaks`        mediumint(8) unsigned default NULL,
  `idr_peak_analysis_id` smallint(5) unsigned default NULL,
  PRIMARY KEY  (`result_set_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- idr stuff in here until we sort the IDRPeaks > DefineOutputSets config linking
-- Also add some summary alignment stats and QC
-- Also separate QC table with full txt file import (for now) and add methods to parse as required
-- this will be cs specific, so probably better to have result/feature_set specific qc tables


-- also add in feature_set_stats here!


DROP TABLE IF EXISTS `input_subset_tracking`;

CREATE TABLE `input_subset_tracking` (
  `input_subset_id` int(10) unsigned NOT NULL,
  `availability_date` date default NULL,
  `download_url` text DEFAULT NULL,
  `download_date` date default NULL,
  `md5sum` varchar(45) default NULL,
  `local_url` text DEFAULT NULL,
  `notes` TEXT default NULL,
  PRIMARY KEY  (`input_subset_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


-- add notes here as we have lost this from the input_set_tracking table?

-- Change this to current repository...
-- INSERT INTO meta (meta_key, meta_value) VALUES ('fastq_repository','/Your/species/specific/fastq/dir/');
-- INSERT INTO meta (meta_key, meta_value) VALUES ('current_coord_system','GRCh37');

-- Change this to something more appropriate tracking_only? (is_dev is ambiguous)
ALTER TABLE status_name ADD tracking_only TINYINT(1) NOT NULL default 0;

INSERT INTO status_name (name, tracking_only) values ('DOWNLOADED',              1);
INSERT INTO status_name (name, tracking_only) values ('IS_CURRENT',              1);
INSERT INTO status_name (name, tracking_only) values ('ADD_TO_REGULATORY_BUILD', 1);
INSERT INTO status_name (name, tracking_only) values ('IN_REGULATORY_BUILD',     1);
INSERT INTO status_name (name, tracking_only) values ('RELEASED',                1);
INSERT INTO status_name (name, tracking_only) values ('TO_BE_REVOKED',           1);
INSERT INTO status_name (name, tracking_only) values ('REVOKED',                 1);
INSERT INTO status_name (name, tracking_only) values ('TO_BE_REBUILD',           1);
INSERT INTO status_name (name, tracking_only) values ('REBUILT',                 1);
INSERT INTO status_name (name, tracking_only) values ('IN_RELEASE',              1);
INSERT INTO status_name (name, tracking_only) values ('ALIGNING_CONTROL',        1);
INSERT INTO status_name (name, tracking_only) values ('ALIGNED',                 1);
INSERT INTO status_name (name, tracking_only) values ('ALIGNED_CONTROL',                 1);
-- Are these last two ALIGN* states really tracking_only?



-- what about status history?
-- We need to be able to track when a set was released, and whether it was pulled and then re-release
-- Separate table?


--ALTER TABLE `data_set_tracking`     DROP `is_current`;
DROP TABLE IF EXISTS `data_set_tracking`;
CREATE TABLE `data_set_tracking` (
  `data_set_id` int(10) unsigned NOT NULL,
  `release_version` varchar(45) DEFAULT NULL,
  `is_current` int(1) DEFAULT NULL,
  PRIMARY KEY (`data_set_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;


-- Do we really need data_set_tracking
-- This probably more accruately feature_set_tracking?
-- although we may also want to release stand alone result_sets


--ALTER TABLE `input_set_tracking`    DROP `status`;



