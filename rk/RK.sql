create table workers 
(
	id_w int PRIMARY KEY,
	FIO varchar(255),
	birthday date,
	department varchar(255)
);
create table t_w
(
	 id_w int, 
	 date_w date, 
	 day_w varchar(255), 
	 time_w time, 
	 type_w int check (type_w > 0 and type_w <3)
);

ALTER TABLE t_w ADD CONSTRAINT FK_Worker FOREIGN KEY(Id_W) REFERENCES workers(Id_W);

insert into workers values (1,'Иванов Иван Иванович','25-09-1990','ИТ'),
(2,'Петров Петр Петрович','12-11-1987','Бухгалтерия');

insert into t_w values
(1,'14-12-2018','Суббота','9:00',1),
(1,'14-12-2018','Суббота','9:20',2),
(1,'14-12-2018','Суббота','9:25',1),
(2,'14-12-2018','Суббота','9:05',1);

insert into t_w values (1,'16-12-2018','Понедельник','9:20',1),
(2,'16-12-2018','Понедельник','9:30',1),
(1,'16-12-2018','Понедельник','9:25',2),
(1,'16-12-2018','Понедельник','9:40',1),
(2,'16-12-2018','Понедельник','9:50',2);

create or replace function func(date_check date) returns bigint as
$$
	select count(*)
	from
	(
		select id_w, count(*)
		from t_w 
		where date_w = date_check and type_w = 2
		group by id_w
	) d join workers w on d.id_w = w.id_w where date_part('year', age(current_date, birthday)) between 18 and 40
and d.count > 3
$$ language sql;



