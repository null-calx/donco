create extension if not exists "uuid-ossp";

create table users (
  userid uuid default uuid_generate_v4 () primary key,
  username text unique not null,
  password text not null,
  emailid text unique not null,
  roles text[]
);

create table rolepermissions (
  id uuid default uuid_generate_v4 () primary key,
  role text,
  permissions text[],
  page text
);

create table crops (
  crops_id uuid default uuid_generate_v4 () primary key,
  crops_name text,
  crops_variety text,
  crops_sowingdate date,
  crops_area integer
);

create table harvest (
  harvest_id uuid default uuid_generate_v4 () primary key,
  harvest_cropid uuid,
  harvest_date date,
  harvest_starttime time,
  harvest_endtime time,
  harvest_quantity integer,
  harvest_labourcost integer,
  constraint fkey_harvest_crops foreign key (harvest_cropid) references crops (crops_id)
);

create table sorting (
  sorting_id uuid default uuid_generate_v4 () primary key,
  sorting_harvestid uuid,
  sorting_date date,
  sorting_starttime time,
  sorting_endtime time,
  sorting_totalquantity integer,
  sorting_quantitydiscarded integer,
  sorting_quantitystoredforlater integer,
  sorting_labourcost integer,
  constraint fkey_sorting_harvest foreign key (sorting_harvestid) references harvest (harvest_id)
);

create table washing (
  washing_id uuid default uuid_generate_v4 () primary key,
  washing_sortingid uuid,
  washing_date date,
  washing_starttime time,
  washing_endtime time,
  washing_totalquantity integer,
  washing_water_ph numeric(4, 2),
  washing_water_temp numeric(5, 2),
  constraint fkey_washing_sorting foreign key (washing_sortingid) references sorting (sorting_id)
);

create table processing (
  processing_id uuid default uuid_generate_v4 () primary key,
  processing_washingid uuid,
  processing_date date,
  processing_starttime time,
  processing_endtime time,
  processing_totalquantity integer,
  constraint fkey_processing_washing foreign key (processing_washingid) references washing (washing_id)
);
