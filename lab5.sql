-- 1) Извлечение данных с помощью функций создания JSON.
select to_json(customers) from customers;
select row_to_json(customers) from customers;

-- 2)Загрузка и сохранение JSON-документа
copy (select row_to_json(customers) from customers)
to '/home/elena/bd/save.json';

create temp table cs_import(doc json);
copy cs_import from '/home/elena/bd/save.json';

select c.*
from cs_import, json_populate_record(null::customers, doc) as c;

--drop table cs_import;

--3)Создать таблицу с json атрибутом и заполнить
create temp table test_json
(
	id int primary key,
	data json
);

insert into test_json values (1, '{}'), (2, '{"test1": 1}'),(3,'{"test2":[1,2,3]}');

select * from test_json;

--4)
--1 Извлечь json фрагмент из json документа
drop table cs_temp;
create temp table cs_temp(doc json);
copy cs_temp from '/home/elena/bd/save.json';

select c.*
from cs_temp, json_to_record(doc) as c(idcustomer int, namecustomer varchar(255), birthdaycustomer date, passportdetails int)
WHERE birthdaycustomer BETWEEN '1997-01-01' and '1997-12-31';

--2 Извлечь значения конкретных узлов или атрибутов 
drop table cs_temp;
create temp table cs_temp(doc json);
copy cs_temp from '/home/elena/bd/save.json';

select passport
from cs_temp, json_extract_path(doc, 'passportdetails') as passport

--3 Выполнить проверку существования узла или атрибута
copy (select json_agg(customers) from customers)
to '/home/elena/bd/save.json';
drop table cs_temp;
create temp table cs_temp(doc json);
copy cs_temp from '/home/elena/bd/save.json';

select *
from cs_temp;

select * 
into temp cs_temp1
from
(
	select c.*
	from cs_temp, json_array_elements(doc) c
)cs;

select json_extract_path(cs_temp1.value, 'passport')
from cs_temp1;

select c.key, c.value
from cs_temp1, json_each(cs_temp1.value) c where json_typeof(c.value) <> 'object';



--4 Изменить json документ
drop table cs_temp;
create temp table cs_temp(id serial primary key, doc jsonb);
insert into cs_temp (doc) values ('{"idcustomer":0,"namecustomer":"Степанов Михаил Артёмович","birthdaycustomer":"1980-08-01","passportdetails":845000}'),
('{"idcustomer":1,"namecustomer":"Бородина Василиса Львовна","birthdaycustomer":"1984-07-13","passportdetails":412789}'),
('{"idcustomer":2,"namecustomer":"Леонова София Кирилловна","birthdaycustomer":"1971-06-15","passportdetails":651290}'),
('{"idcustomer":3,"namecustomer":"Левина София Ильинична","birthdaycustomer":"1980-07-03","passportdetails":735478}'),
('{"idcustomer":4,"namecustomer":"Соколов Илья Тимурович","birthdaycustomer":"1996-11-05","passportdetails":503533}'),
('{"idcustomer":5,"namecustomer":"Сорокина Юлия Степановна","birthdaycustomer":"1991-07-28","passportdetails":310998}'),
('{"idcustomer":6,"namecustomer":"Симонова Анастасия Данииловна","birthdaycustomer":"1978-10-16","passportdetails":654803}'),
('{"idcustomer":7,"namecustomer":"Ефимова Виктория Савельевна","birthdaycustomer":"1999-11-05","passportdetails":441661}'),
('{"idcustomer":8,"namecustomer":"Царева Маргарита Андреевна","birthdaycustomer":"1983-10-24","passportdetails":884585}');

select * from cs_temp;

update cs_temp
set doc = jsonb_set(doc, '{"passportdetails"}', '125856', true)
where id = 7;

select * from cs_temp
where id = 7;
--5 Разделить на несколько строк по узлам
drop table cs_temp;
create temp table cs_temp(id serial primary key, doc jsonb);
insert into cs_temp (doc) values ('{"idcustomer":0,"namecustomer":"Степанов Михаил Артёмович","birthdaycustomer":"1980-08-01","passportdetails":845000}'),
('{"idcustomer":1,"namecustomer":"Бородина Василиса Львовна","birthdaycustomer":"1984-07-13","passportdetails":412789}'),
('{"idcustomer":2,"namecustomer":"Леонова София Кирилловна","birthdaycustomer":"1971-06-15","passportdetails":651290}'),
('{"idcustomer":3,"namecustomer":"Левина София Ильинична","birthdaycustomer":"1980-07-03","passportdetails":735478}'),
('{"idcustomer":4,"namecustomer":"Соколов Илья Тимурович","birthdaycustomer":"1996-11-05","passportdetails":503533}'),
('{"idcustomer":5,"namecustomer":"Сорокина Юлия Степановна","birthdaycustomer":"1991-07-28","passportdetails":310998}'),
('{"idcustomer":6,"namecustomer":"Симонова Анастасия Данииловна","birthdaycustomer":"1978-10-16","passportdetails":654803}'),
('{"idcustomer":7,"namecustomer":"Ефимова Виктория Савельевна","birthdaycustomer":"1999-11-05","passportdetails":441661}'),
('{"idcustomer":8,"namecustomer":"Царева Маргарита Андреевна","birthdaycustomer":"1983-10-24","passportdetails":884585}');

copy (select json_agg(cs_temp) from cs_temp)
to '/home/elena/bd/lab5.json';

drop table cs_temp2;
create temp table cs_temp2 (doc json);
copy cs_temp2 from '/home/elena/bd/lab5.json';

drop table cs_temp1;

select *
into temp cs_temp1
from
(
	select c.*
	from cs_temp2, json_array_elements(doc) c
)cs;

select * from cs_temp2;

select json_each_text(cs_temp1.value -> 'doc') cs from cs_temp1 order by cs desc;
