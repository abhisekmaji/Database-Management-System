DROP TABLE IF EXISTS userdb;
create table userdb
( 
	username text,
	password text,
	PRIMARY KEY (username)
);

insert into userdb (username, password)
values
('jatin', 'goyal');

insert into userdb (username, password)
values
('abhisek', 'maji');

insert into userdb (username, password)
values
('deepanshu', 'singh');

insert into userdb (username, password)
values
('prof', 'all hail');
