#<unbound>

create table users (
  userid uuid default uuid_generate_v4 () primary key,
  username text unique not null default noone,
  password text not null,
  emailid text unique not null,
  roles text[]
);

create table rolepermissions (
  id uuid default uuid_generate_v4 () primary key,
  role text,
  permissions text[]
);

create table crops (
  crops_cropid uuid default uuid_generate_v4 () primary key,
  crops_cropname text
);

create table dailyharvest (
  dailyharvest_harvestid uuid default uuid_generate_v4 () primary key,
  dailyharvest_harvestname text,
  dailyharvest_cropid uuid,
  constraint fkey_dailyharvest_crops foreign key (dailyharvest_cropid) references crops (crops_cropid)
);

create table sorting (
  sorting_sortingid uuid default uuid_generate_v4 () primary key,
  sorting_sortname text,
  sorting_harvestid uuid,
  constraint fkey_sorting_dailyharvest foreign key (sorting_harvestid) references dailyharvest (dailyharvest_harvestid)
);
