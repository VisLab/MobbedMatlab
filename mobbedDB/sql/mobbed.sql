-- execute
CREATE TABLE attributes
(
  attribute_uuid uuid,
  attribute_entity_uuid uuid,
  attribute_entity_class character varying, 
  attribute_organizational_uuid uuid, 
  attribute_path character varying,
  attribute_numeric_value double precision, 
  attribute_value character varying,
  PRIMARY KEY (attribute_uuid)
)
WITH (
  OIDS=FALSE
);

-- execute
CREATE TABLE collections
(
  collection_uuid uuid,
  collection_entity_uuid uuid,
  collection_entity_class character varying, 
  PRIMARY KEY (collection_uuid, collection_entity_uuid)
)
WITH (
  OIDS=FALSE
);

-- execute
CREATE TABLE comments
(
  comment_uuid uuid,
  comment_entity_uuid uuid,
  comment_entity_class character varying,
  comment_contact_uuid uuid DEFAULT '591df7dd-ce3e-47f8-bea5-6a632c6fcccb',
  comment_time timestamp without time zone DEFAULT LOCALTIMESTAMP,
  comment_value character varying,
  PRIMARY KEY (comment_uuid)
)
WITH (
  OIDS=FALSE
);

-- execute
CREATE TABLE contacts
(
  contact_uuid uuid,
  contact_first_name character varying,
  contact_last_name character varying,
  contact_middle_initial character varying,
  contact_address_line_1 character varying,
  contact_address_line_2 character varying,
  contact_city character varying,
  contact_state character varying,
  contact_country character varying,
  contact_postal_code character varying,
  contact_telephone character varying,
  contact_email character varying,
  PRIMARY KEY (contact_uuid)
)
WITH (
  OIDS=FALSE
);

-- execute
 CREATE TABLE datadefs
(
  datadef_uuid uuid,
  datadef_format character varying CHECK (upper(datadef_format) = 'NUMERIC_VALUE' OR upper(datadef_format) = 'NUMERIC_STREAM' OR upper(datadef_format) = 'XML_VALUE' OR upper(datadef_format) = 'XML_STREAM' OR upper(datadef_format) = 'EXTERNAL' ),
  datadef_sampling_rate double precision CHECK (datadef_sampling_rate = -1 OR datadef_sampling_rate > 0),
  datadef_oid oid,
  datadef_description character varying, 
  PRIMARY KEY (datadef_uuid)
)
WITH (
  OIDS=FALSE
);

-- execute 
 CREATE TABLE datamaps
(
  datamap_def_uuid uuid,
  datamap_entity_uuid uuid,
  datamap_entity_class character varying, 
  datamap_path character varying, 
  PRIMARY KEY (datamap_def_uuid, datamap_entity_uuid)
)
WITH (
  OIDS=FALSE
);

-- execute  
  CREATE TABLE datasets
(
  dataset_uuid uuid,
  dataset_session_uuid uuid,  
  dataset_namespace character varying DEFAULT 'mobbed',
  dataset_name character varying NOT NULL,
  dataset_version integer CHECK (dataset_version > 0) DEFAULT 1,
  dataset_contact_uuid uuid DEFAULT '591df7dd-ce3e-47f8-bea5-6a632c6fcccb',
  dataset_creation_date timestamp without time zone DEFAULT LOCALTIMESTAMP,
  dataset_description character varying,
  dataset_parent_uuid uuid DEFAULT '491df7dd-ce3e-47f8-bea5-6a632c6fcccb',
  dataset_modality_uuid uuid  DEFAULT '791df7dd-ce3e-47f8-bea5-6a632c6fcccb',
  dataset_oid oid,
  PRIMARY KEY (dataset_uuid),
  UNIQUE (dataset_namespace, dataset_name, dataset_version)
)
WITH (
  OIDS=FALSE
);
 
-- execute 
  CREATE TABLE devices
(
  device_uuid uuid,
  device_contact_uuid uuid DEFAULT '591df7dd-ce3e-47f8-bea5-6a632c6fcccb',
  device_description character varying,
  PRIMARY KEY (device_uuid)
)
WITH (
  OIDS=FALSE
);

-- execute 
CREATE TABLE elements
(
  element_uuid uuid,
  element_label character varying,
  element_dataset_uuid uuid,
  element_parent_uuid uuid DEFAULT '491df7dd-ce3e-47f8-bea5-6a632c6fcccb',  
  element_position bigint CHECK (element_position = -1 OR element_position > 0),
  element_description character varying,
  PRIMARY KEY (element_uuid)
)
	WITH (
	  OIDS=FALSE
	);  

-- execute	
CREATE TABLE events
(
  event_uuid uuid,
  event_dataset_uuid uuid,
  event_type_uuid uuid,
  event_start_time double precision CHECK (event_start_time >= 0),
  event_end_time double precision CHECK (event_end_time >= 0),
  event_parent_uuid uuid DEFAULT '491df7dd-ce3e-47f8-bea5-6a632c6fcccb',
  event_position bigint CHECK (event_position > 0),
  event_certainty double precision CHECK (event_certainty >= 0 AND event_certainty <= 1), 
  PRIMARY KEY (event_uuid)
)
WITH (
  OIDS=FALSE
);

-- execute 
CREATE TABLE event_types
(
  event_type_uuid uuid,
  event_type character varying,
  event_type_description character varying,
  PRIMARY KEY (event_type_uuid )
)
WITH (
  OIDS=FALSE
);

-- execute  
CREATE TABLE modalities
(
  modality_uuid uuid,
  modality_name character varying,
  modality_platform character varying,
  modality_description character varying,
  PRIMARY KEY (modality_uuid),
  UNIQUE (modality_name)
)
WITH (
  OIDS=FALSE
);

-- execute 
CREATE TABLE numeric_values
(
  numeric_value_datadef_uuid uuid,  
  numeric_value double precision[],
  PRIMARY KEY (numeric_value_datadef_uuid)
)
WITH (
  OIDS=FALSE
);

-- execute
CREATE TABLE numeric_streams
(
  numeric_stream_datadef_uuid uuid,  
  numeric_stream_record_position bigint CHECK (numeric_stream_record_position > 0),
  numeric_stream_record_time double precision CHECK (numeric_stream_record_time >= 0),
  numeric_stream double precision[],
  PRIMARY KEY (numeric_stream_datadef_uuid, numeric_stream_record_position)
)
WITH (
  OIDS=FALSE
);

-- execute
CREATE TABLE subjects
(
  subject_uuid uuid,
  subject_description character varying,
  PRIMARY KEY (subject_uuid)
)
WITH (
  OIDS=FALSE
);

-- execute
CREATE TABLE tags
(
  tag_uuid uuid, 
  tag_name varchar UNIQUE NOT NULL,
  CONSTRAINT tags_pkey PRIMARY KEY (tag_uuid)
)
WITH (
  OIDS=FALSE
);

-- execute
CREATE TABLE tag_entities
(
  tag_entity_uuid uuid,
  tag_entity_tag_uuid uuid, 
  tag_entity_class varchar NOT NULL,
  CONSTRAINT tag_entities_pkey PRIMARY KEY (tag_entity_uuid, tag_entity_tag_uuid)
)
WITH (
  OIDS=FALSE
);

-- execute
CREATE TABLE tag_groups
(
  tag_group_uuid uuid,
  tag_group_tag_uuid uuid, 
  tag_group varchar,
  CONSTRAINT tag_groups_pkey PRIMARY KEY (tag_group_uuid, tag_group_tag_uuid)
)
WITH (
  OIDS=FALSE
);

-- execute
CREATE TABLE transforms
(
  transform_uuid uuid,
  transform_string character varying NOT NULL,
  transform_md5_hash character varying,
  transform_description character varying,
  PRIMARY KEY (transform_uuid )
)
WITH (
  OIDS=FALSE
); 

-- execute
CREATE TABLE xml_values
(
  xml_value_datadef_uuid uuid,
  xml_value character varying,
  PRIMARY KEY (xml_value_datadef_uuid)
)
WITH (
  OIDS=FALSE
); 

-- execute
CREATE TABLE xml_streams
(
  xml_stream_datadef_uuid uuid,
  xml_stream_record_position bigint CHECK (xml_stream_record_position > 0),
  xml_stream_record_time double precision CHECK (xml_stream_record_time >= 0),
  xml_stream double precision[],
  PRIMARY KEY (xml_stream_datadef_uuid, xml_stream_record_position)
)
WITH (
  OIDS=FALSE
); 

-- execute
ALTER TABLE collections ADD FOREIGN KEY (collection_uuid) REFERENCES datasets (dataset_uuid);

-- execute
ALTER TABLE comments ADD FOREIGN KEY (comment_contact_uuid) REFERENCES contacts (contact_uuid);

-- execute
ALTER TABLE datamaps ADD FOREIGN KEY (datamap_def_uuid) REFERENCES datadefs (datadef_uuid);

-- execute
ALTER TABLE datasets ADD FOREIGN KEY (dataset_contact_uuid) REFERENCES contacts (contact_uuid);

-- execute
ALTER TABLE datasets ADD FOREIGN KEY (dataset_modality_uuid) REFERENCES modalities (modality_uuid);

-- execute
ALTER TABLE devices ADD FOREIGN KEY (device_contact_uuid) REFERENCES contacts (contact_uuid);

-- execute
ALTER TABLE events ADD FOREIGN KEY (event_type_uuid) REFERENCES event_types (event_type_uuid);

-- execute
ALTER TABLE numeric_streams ADD FOREIGN KEY (numeric_stream_datadef_uuid) REFERENCES datadefs (datadef_uuid);

-- execute
ALTER TABLE numeric_values ADD FOREIGN KEY (numeric_value_datadef_uuid) REFERENCES datadefs (datadef_uuid);

-- execute
ALTER TABLE tag_entities ADD FOREIGN KEY (tag_entity_tag_uuid) REFERENCES tags (tag_uuid);

-- execute
ALTER TABLE tag_groups ADD FOREIGN KEY (tag_group_tag_uuid) REFERENCES tags (tag_uuid);

-- execute
ALTER TABLE transforms ADD FOREIGN KEY (transform_uuid) REFERENCES datasets (dataset_uuid);

-- execute
ALTER TABLE xml_values ADD FOREIGN KEY (xml_value_datadef_uuid) REFERENCES datadefs (datadef_uuid);

-- execute
ALTER TABLE xml_streams ADD FOREIGN KEY (xml_stream_datadef_uuid) REFERENCES datadefs (datadef_uuid);

-- execute
INSERT INTO CONTACTS (CONTACT_UUID, CONTACT_FIRST_NAME, CONTACT_LAST_NAME) 
VALUES ('591df7dd-ce3e-47f8-bea5-6a632c6fcccb', 'System', 'User');

-- execute
INSERT INTO MODALITIES (MODALITY_UUID, MODALITY_NAME, MODALITY_PLATFORM, MODALITY_DESCRIPTION) 
VALUES ('691df7dd-ce3e-47f8-bea5-6a632c6fcccb', 'EEG', 'MATLAB', 'default EEGLAB EEG modality');

-- execute
INSERT INTO MODALITIES (MODALITY_UUID, MODALITY_NAME, MODALITY_PLATFORM, MODALITY_DESCRIPTION) 
VALUES ('791df7dd-ce3e-47f8-bea5-6a632c6fcccb', 'GENERIC', 'MATLAB', 'default generic modality');

-- execute
INSERT INTO MODALITIES (MODALITY_UUID, MODALITY_NAME, MODALITY_PLATFORM, MODALITY_DESCRIPTION) 
VALUES ('891df7dd-ce3e-47f8-bea5-6a632c6fcccb', 'SIMPLE', 'MATLAB', 'default simple modality');		

-- execute
INSERT INTO MODALITIES (MODALITY_UUID, MODALITY_NAME, MODALITY_PLATFORM, MODALITY_DESCRIPTION) 
VALUES ('991df7dd-ce3e-47f8-bea5-6a632c6fcccb', 'CSV', 'MATLAB', 'default csv modality');		

-- excecute
CREATE OR REPLACE FUNCTION trans_md5() RETURNS trigger AS $trans_md5$
    BEGIN
    NEW.transform_md5_hash := md5(NEW.transform_string);
    RETURN NEW;
    END;
$trans_md5$ LANGUAGE plpgsql;

-- execute 
CREATE TRIGGER trans_md5 BEFORE INSERT OR UPDATE ON transforms
    FOR EACH ROW EXECUTE PROCEDURE trans_md5();
