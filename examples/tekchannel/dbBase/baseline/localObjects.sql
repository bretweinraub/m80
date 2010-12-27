-- -*-sql-*--

drop table m80moduleVersion cascade;

CREATE TABLE m80moduleVersion (
  module_name			varchar (32) NOT NULL ,
  release 			varchar (32) NOT NULL ,
  baseline                      smallint default 1 NOT NULL,
  CONSTRAINT m80moduleVersion_pk PRIMARY KEY (module_name, release)
);

drop table m80patchLog;

CREATE TABLE m80patchLog (
  module_name			VARCHAR(32) NOT NULL ,
  release                       VARCHAR(32) NOT NULL ,
  patchlevel                    int NOT NULL,
  datetime_applied              DATE NOT NULL,
  hostname                      VARCHAR(64) NOT NULL,
  host_user                     VARCHAR(64) NOT NULL,
  host_path                     VARCHAR(512) NOT NULL,
-- 
  CONSTRAINT m80patchLog_pk PRIMARY KEY (module_name, release, patchlevel),
  CONSTRAINT m80patchLog_fk01 FOREIGN KEY (module_name, release) references m80moduleVersion
);

drop table dual;

create table dual (
  x                            varchar(1) not null
);

insert into dual (x) values ('y');


