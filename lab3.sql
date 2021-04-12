--Скалярная функции
create function AvgValueDirection(IdDirection_check varchar(255)) returns numeric as
$$
	select AVG(ValueContract)
	from Contracts
	where IdDirection = IdDirection_check
$$ language sql;

select AvgValueDirection('03.00.00')

--Подставляемая табличная функция
create function CheckDateContract(start_date date, end_date date) returns setof contracts as
$$
	select *
	from Contracts
	where DateContract between start_date and end_date
$$ language sql;


select *
from CheckDateContract('2020-01-01','2020-12-31')

--Функция с рекурсивным отв
create function InfoCourse()
returns table
(
	course varchar(255), 
	quantity bigint, 
	cost decimal
)
as
$$
WITH recursive list_of_courses(course, quantity, cost) AS
(
	 SELECT Course, CountHour, UnitCost
	 FROM Courses 
	 WHERE courses.Сontent IS NULL
	 UNION ALL
		SELECT CS.Course, CS.CountHour,
		CAST(l.quantity * l.cost AS DECIMAL)
		FROM list_of_courses l, Courses CS
		WHERE l.course = cs.Сontent
)
SELECT course , SUM(quantity) as CountHour, SUM(cost) as Cost
FROM list_of_courses
GROUP BY course;
$$language sql;

select *
from InfoCourse()

--Многооператорная табличная функция
create temp table info as
select CT.NumberContract,CT.ValueContract, D.NameDirection, CR.PassportDetails,P.AccountNumber,W.NameWorker
From Contracts CT INNER JOIN Directions D on CT.IdDirection = D.IdDirection
				  INNER JOIN Customers CR on CT.CustomerPassport = CR.PassportDetails
				  INNER JOIN Pay P on CT.NumberContract = P.NumberContract
				  INNER JOIN Workers W on CT.IdWorker = W.IdWorker;
				  
create function InfoContract(check_passportcustomer int)
returns table
(
	ContractId int,
	ValueContract int,
	NameDirection varchar(255),
	PassportCustomer int,
	AccountId int,
	NameWorker varchar(255)
)
as
$$
delete from info where PassportDetails != check_passportcustomer;
update info set ValueContract = ValueContract * 0.9;
update info set AccountNumber = (select max(AccountNumber) from pay) + 1;
select *
from Info
$$language sql;

select *
from InfoContract(845000);	

--Хранимая процедура с параметрами
--Обновляем стоимость по номеру направления
select *
into temp contracts_copy
from contracts;

create or replace procedure update_valuecontract(koef numeric, direction varchar(255)) as
$$
	update contracts_copy
	set ValueContract = ValueContract * koef
	where IdDirection = direction
$$ language sql;

call update_valuecontract(1.5, '03.00.00');

select Contracts.NumberContract, Contracts.IdDirection,Contracts.ValueContract as old_value, contracts_copy.ValueContract as new_value
from contracts_copy join contracts on contracts_copy.NumberContract = contracts.NumberContract
where Contracts.IdDirecton = '03.00.00'

--Рекурсивная хранимая процедура
--Обновляем статус всех договоров в определенном интервале

drop table contracts_copy;

select *
into temp contracts_copy
from contracts;

create or replace procedure update_status (new_status varchar(255), date_l date, date_h date) as
$$
begin
	if (date_l <= date_h)
then
	update contracts_copy
	set statuscontract = new_status
	where datecontract = date_l;
	call update_status(new_status, date_l + 1, date_h);
end if; 
end;
	
$$ language plpgsql;

call update_status('Недействительный', '2016-01-01', '2016-06-30');

select contracts.numbercontract,contracts.datecontract, contracts.statuscontract as old_type, contracts_copy.statuscontract as new_type
from contracts_copy join contracts on contracts_copy.numbercontract = contracts.numbercontract
where contracts.datecontract between '2016-01-01' and '2016-06-30'


-- Хранимая процедура с курсором
-- Обновить должность людей определенной должности

--drop table workers_copy;

select *
into temp workers_copy
from workers;

create or replace procedure update_postworker(new_post varchar(255), old_post varchar(255)) as
$$
declare cur cursor
	for select * 
	from workers
	where postworker = old_post;
	row record;
begin
	open cur;
	loop
		fetch cur into row;
		exit when not found;
		update workers_copy
		set postworker = new_post
		where workers_copy.idworker = row.idworker;
	end loop;
	close cur;		
end
$$ language plpgsql;

call update_postworker('Консультант', 'Оператор');

select workers.idworker, workers.nameworker, workers.postworker as old_post, workers_copy.postworker as new_post
from workers_copy join workers on workers_copy.idworker = workers.idworker
where workers.postworker = 'Оператор'

-- Хранимая процедура доступа к метаданным
-- Вывод названия заданной таблицы и ее физического размера

create or replace procedure table_size(nametable varchar(255)) as
$$
declare 
	cur cursor
	for select nametable, size
	from 
	( 
		SELECT nametable as table, pg_size_pretty(pg_total_relation_size(nametable)) as size
	) AS tmp;
	row record;
begin
	open cur;
		fetch cur into row;
		raise notice '{table : %} {size : %}', row.nametable, row.size;
	close cur;
end
$$ language plpgsql;

call table_size('pay');

--Триггер after
drop table insert_log;

CREATE TABLE insert_log
(
  "log" text
);

create or replace function add_insert_log() returns trigger as
$$
declare
    temp varchar(200);
begin
    temp = TG_OP;
    insert into insert_log(log) values (temp);
    return null;
end;
$$ language plpgsql;

create trigger ContractsTriggerInsert
after insert or update or delete on contracts for each row execute
procedure add_insert_log();

insert into contracts
values (78802, '2020-11-21', 'Двусторонний', 'Четыре года', 'Действительный', 226034,134961,'55.00.00', 51896);


--Триггер instead of
create view customer_view as
select *
from customers;

create or replace function FDeleteT() returns trigger as
$$
begin
	update customers
	set idcustomer = -1,
	namecustomer = '------',
	birthdaycustomer = '0001-01-01'
	where passportdetails = old.passportdetails;
	return old;
end;
$$ language plpgsql;

create trigger tDelete
instead of delete on customer_view
for each row
execute procedure FDeleteT();

delete from customer_view
where passportdetails = 100504;

select *
from customer_view
where passportdetails = 100504;


				
