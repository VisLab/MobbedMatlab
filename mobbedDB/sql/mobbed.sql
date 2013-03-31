CREATE TABLE attributes
(
  attribute_uuid uuid NOT NULL,
  attribute_entity_uuid uuid,
  attribute_organizational_uuid uuid,
  attribute_structure_uuid uuid,
  attribute_position bigint,
  attribute_numeric_value double precision, 
  attribute_value character varying,
  CONSTRAINT attributes_pk PRIMARY KEY (attribute_uuid)
)
WITH (
  OIDS=FALSE
);

CREATE TABLE collections
(
  collection_uuid uuid NOT NULL,
  collection_entity_uuid uuid,
  CONSTRAINT collections_pkey PRIMARY KEY (collection_uuid, collection_entity_uuid)
)
WITH (
  OIDS=FALSE
);

CREATE TABLE comments
(
  comment_uuid uuid NOT NULL,
  comment_entity_uuid uuid,
  comment_entity_class character varying,
  comment_contact_uuid uuid,
  comment_time timestamp without time zone DEFAULT LOCALTIMESTAMP,
  comment_value character varying,
  CONSTRAINT comments_pkey PRIMARY KEY (comment_uuid)
)
WITH (
  OIDS=FALSE
);

CREATE TABLE contacts
(
  contact_uuid uuid NOT NULL,
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
  CONSTRAINT contacts_pk PRIMARY KEY (contact_uuid)
)
WITH (
  OIDS=FALSE
);

 CREATE TABLE data_defs
(
  data_def_uuid uuid NOT NULL,
  data_def_format character varying,
  data_def_sampling_rate double precision,
  data_def_timestamps double precision[],
  data_def_oid oid,
  data_def_description character varying, 
  CONSTRAINT data_defs_pk PRIMARY KEY (data_def_uuid)
)
WITH (
  OIDS=FALSE
);
 
 CREATE TABLE data_maps
(
  data_map_def_uuid uuid,
  data_map_entity_uuid uuid,
  data_map_structure_uuid uuid,
  data_map_structure_path character varying, 
  CONSTRAINT data_maps_pk PRIMARY KEY (data_map_def_uuid, data_map_entity_uuid)
)
WITH (
  OIDS=FALSE
);
  
  CREATE TABLE datasets
(
  dataset_uuid uuid,
  dataset_session_uuid uuid,  
  dataset_namespace character varying DEFAULT 'mobbed',
  dataset_name character varying,
  dataset_version integer,
  dataset_contact_uuid uuid DEFAULT '691df7dd-ce3e-47f8-bea5-6a632c6fcccb',
  dataset_creation_date timestamp without time zone DEFAULT LOCALTIMESTAMP,
  dataset_description character varying,
  dataset_parent_uuid uuid,
  dataset_modality_uuid uuid DEFAULT '791df7dd-ce3e-47f8-bea5-6a632c6fcccb',
  dataset_oid oid,
  CONSTRAINT datasets_pk PRIMARY KEY (dataset_uuid),
  CONSTRAINT "DATASETS_NAME_UK" UNIQUE (dataset_namespace, dataset_name, dataset_version)
)
WITH (
  OIDS=FALSE
);
 
  CREATE TABLE devices
(
  device_uuid uuid NOT NULL,
  device_contact_uuid uuid,
  device_description character varying,
  CONSTRAINT devices_pk PRIMARY KEY (device_uuid)
)
WITH (
  OIDS=FALSE
);
 
 CREATE TABLE elements
(
  element_uuid uuid NOT NULL,
  element_label character varying,
  element_parent_uuid uuid,  
  element_position bigint,
  element_description character varying,
	  CONSTRAINT elements_pk PRIMARY KEY (element_uuid)
)
	WITH (
	  OIDS=FALSE
	);  
 
CREATE TABLE event_types
(
  event_type_uuid uuid NOT NULL,
  event_type character varying,
  event_type_description character varying,
  CONSTRAINT event_types_pk PRIMARY KEY (event_type_uuid )
)
WITH (
  OIDS=FALSE
);
 
CREATE TABLE event_type_maps
(
  event_type_uuid uuid NOT NULL,
  event_type_entity_uuid uuid NOT NULL,
  event_type_map_entity_class character varying,
  CONSTRAINT event_type_maps_pk PRIMARY KEY (event_type_uuid, event_type_entity_uuid)
)
WITH (
  OIDS=FALSE
);
 
CREATE TABLE events
(
  event_uuid uuid NOT NULL,
  event_entity_uuid uuid,
  event_type_uuid uuid,
  event_start_time double precision,
  event_end_time double precision,
  event_position bigint,
  event_certainty double precision,
  CONSTRAINT events_pk PRIMARY KEY (event_uuid )
)
WITH (
  OIDS=FALSE
);
 
CREATE TABLE modalities
(
  modality_uuid uuid NOT NULL,
  modality_name character varying,
  modality_platform character varying,
  modality_description character varying,
  CONSTRAINT modality_pk PRIMARY KEY (modality_uuid)
)
WITH (
  OIDS=FALSE
);
 
CREATE TABLE numeric_values
(
  data_def_uuid uuid NOT NULL,  
  numeric_value double precision[],
  CONSTRAINT numeric_values_pk PRIMARY KEY (data_def_uuid)
)
WITH (
  OIDS=FALSE
);

CREATE TABLE numeric_streams
(
  data_def_uuid uuid NOT NULL,  
  numeric_stream_record_position bigint NOT NULL,
  numeric_stream_record_time double precision,
  numeric_stream_data_value double precision[],
  CONSTRAINT numeric_stream_pk PRIMARY KEY (data_def_uuid, numeric_stream_record_position)
)
WITH (
  OIDS=FALSE
);

CREATE TABLE structures
(
  structure_uuid uuid NOT NULL,
  structure_name character varying,
  structure_handler character varying,
  structure_parent_uuid uuid,
  structure_path character varying, 
  CONSTRAINT structures_pk PRIMARY KEY (structure_uuid)
)
WITH (
  OIDS=FALSE
);

CREATE TABLE subjects
(
  subject_uuid uuid NOT NULL,
  subject_description character varying,
  CONSTRAINT subjects_pk PRIMARY KEY (subject_uuid)
)
WITH (
  OIDS=FALSE
);

CREATE TABLE tags
(
  tag_name character varying,
  tag_entity_uuid uuid,
  tag_entity_class character varying,
  CONSTRAINT tags_pk PRIMARY KEY (tag_name, tag_entity_uuid)
)
WITH (
  OIDS=FALSE
);

CREATE TABLE transforms
(
  transform_uuid uuid NOT NULL,
  transform_string character varying,
  transform_md5_hash character varying,
  transform_description character varying,
  CONSTRAINT transforms_pk PRIMARY KEY (transform_uuid )
)
WITH (
  OIDS=FALSE
); 

CREATE TABLE xml_values
(
  data_def_uuid uuid NOT NULL,
  xml_value character varying,
  CONSTRAINT xml_values_pk PRIMARY KEY (data_def_uuid)
)
WITH (
  OIDS=FALSE
); 

CREATE TABLE xml_streams
(
  data_def_uuid uuid NOT NULL,
  xml_stream_record_position bigint NOT NULL,
  xml_stream_record_time double precision,
  xml_stream_data_value double precision[],
  CONSTRAINT xml_streams_pk PRIMARY KEY (data_def_uuid, xml_stream_record_position)
)
WITH (
  OIDS=FALSE
); 

INSERT INTO CONTACTS (CONTACT_UUID, CONTACT_FIRST_NAME, CONTACT_LAST_NAME) 
VALUES ('691df7dd-ce3e-47f8-bea5-6a632c6fcccb', 'System', 'User');

INSERT INTO MODALITIES (MODALITY_UUID, MODALITY_NAME, MODALITY_PLATFORM, MODALITY_DESCRIPTION) 
VALUES ('791df7dd-ce3e-47f8-bea5-6a632c6fcccb', 'EEG', 'MATLAB', 'default EEGLAB EEG modality');

INSERT INTO MODALITIES (MODALITY_UUID, MODALITY_NAME, MODALITY_PLATFORM, MODALITY_DESCRIPTION) 
VALUES ('891df7dd-ce3e-47f8-bea5-6a632c6fcccb', 'GENERIC', 'MATLAB', 'default generic modality');

INSERT INTO MODALITIES (MODALITY_UUID, MODALITY_NAME, MODALITY_PLATFORM, MODALITY_DESCRIPTION) 
VALUES ('991df7dd-ce3e-47f8-bea5-6a632c6fcccb', 'SIMPLE', 'MATLAB', 'default simple modality');