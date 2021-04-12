--Получить номера счетов, сумма которых меньше 500000 в 2016 году
SELECT Pay.AccountNumber, Contracts.ValueContract
FROM Pay JOIN Contracts ON Contracts.NumberContract = Pay.NumberContract
WHERE ValueContract < 500000 AND (PaymentDate BETWEEN '2016-01-01' and '2016-12-31')

--Получить список договоров, оплаченных материнским капиталом
SELECT Contracts.NumberContract, PaymentMethod
FROM Contracts JOIN Pay ON Contracts.NumberContract = Pay.NumberContract
WHERE PaymentMethod = 'Материнский капитал'

--Получить список договоров, которые были оплачены в первой половине 2016 года
SELECT DISTINCT NumberContract, PaymentDate
FROM pay 
WHERE PaymentDate BETWEEN '2016-01-01' and '2016-06-30'

--Получить список кафедр в название факультета которых есть слово 'Информатика'
SELECT namedirection
FROM executors JOIN directions ON directions.IdExecutor = executors.IdExecutor
WHERE faculty LIKE '%Информатика%'

--Получить список договоров для клиентов, родившихся в 1997 году, оформленных через сотрудника 52591
SELECT NumberContract, CustomerPassport, IdWorker, DateContract
FROM Contracts
WHERE CustomerPassport IN
(
	 SELECT CustomerPassport
	 FROM Customers
	 WHERE birthdaycustomer BETWEEN '1997-01-01' and '1997-12-31'
) AND IdWorker = 52591

--EXIST
SELECT IdDirection, NameDirection
FROM Directions D
where exists(
	SELECT *
	FROM Contracts C 
	where C.IdDirection = d.IdDirection and C.StatusContract = 'Действительный'
)

--Получить список договоров, стоимость которых больше стоимости любого трехстороннего договора
SELECT NumberContract, TypeContract, ValueContract
FROM Contracts
WHERE ValueContract > ALL
	(
		SELECT ValueContract
		FROM Contracts
		WHERE TypeContract = "Трехсторонний"
	)


--Получить средную стоимость двусторонних договоров
SELECT AVG(ValueContract) as AvgValueContract
FROM Contracts
WHERE TypeContract = 'Двусторонний'

--Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов.
SELECT AccountNumber, ValueContract,
	(
		SELECT AVG(ValueContract)
		FROM Contracts 
		where CustomerPassport = CT.CustomerPassport
	)AS AvgValueContract,
	(
		SELECT MIN(ValueContract)
		FROM Contracts
		where CustomerPassport = CT.CustomerPassport
	)AS MinValueContract,
	(
		SELECT count(*)
		FROM Contracts 
		where CustomerPassport = CT.CustomerPassport
	)AS CountContract,
	PaymentDate
FROM Pay Join Contracts CT on Pay.NumberContract = CT.NumberContract
WHERE PaymentMethod = 'Личные средства'


--Инструкция SELECT, использующая простое выражение CASE
SELECT Contracts.NumberContract, AccountNumber,
	CASE date_part('year', PaymentDate)
		WHEN date_part('year',current_date) THEN 'This Year'
		WHEN date_part('year',current_date) - 1 THEN 'Last year'
		ELSE CAST(date_part('year', age(current_date, PaymentDate)) AS varchar(5)) || ' years ago' 
	END AS When
FROM Pay JOIN Contracts ON Pay.NumberContract = Contracts.NumberContract

--Инструкция SELECT, использующая поисковое выражение CASE
SELECT NumberContract,
	CASE 
		WHEN ValueContract < 200000 THEN 'Inexpensive'
		WHEN ValueContract < 500000 THEN 'Fair'
		WHEN ValueContract < 1000000 THEN 'Expensive'
		ELSE 'Very Expensive'
	END AS Value
FROM Contracts 

--Создание новой временной локальной таблицы из результирующего
-- набора данных инструкции SELECT
drop table CurrentContracts;
SELECT NumberContract, TypeContract, DateContract
INTO temp CurrentContracts
FROM Contracts
WHERE StatusContract = 'Действительный'

--Инструкция SELECT, использующая вложенные коррелированные подзапросы 
--в качестве производных таблиц в предложении FROM.

select NameCustomer, PassportDetails, AccountNumber, Paymentmethod
from customers join
(
	contracts CS join pay on CS.NumberContract = Pay.NumberContract
) as CustomerPay on Customers.PassportDetails = CustomerPay.CustomerPassport


--Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3.

Select NumberContract, TypeContract, ValueContract
from Contracts
where ValueContract <
(
	select AVG(ValueContract)
	from Contracts
	where iddirection =
	(
		select IdDirection
		from directions
		where typedirection = 'Бакалавриат' and IdExecutor =
		(
			select IdExecutor 
			from executors 
			where faculty = 'Информатика и системы управления' and department =  1
		)
	)
)
--Инструкция SELECT, консолидирующая данные с помощью предложения
--GROUP BY, но без предложения HAVING.
SELECT C.IdDirection,
	AVG(CAST(date_part('year', age(current_date, BirthdayCustomer)) as int)) AS AvgAgeCustomer,
	MIN(CAST(date_part('year', age(current_date, BirthdayCustomer)) as int)) AS MinAgeCustomer
FROM Contracts C LEFT OUTER JOIN Customers ON  C.CustomerPassport = Customers.PassportDetails
WHERE TypeContract = 'Двусторонний'
GROUP BY C.IdDirection

--Инструкция SELECT, консолидирующая данные с помощью предложения
--GROUP BY и предложения HAVING.
SELECT IdDirection, AVG(valuecontract)
FROM Contracts C 
group by iddirection
having AVG(valuecontract) > 
(
		select AVG(valuecontract) as AvgContracts
		from Contracts
)

--Однострочная инструкция INSERT, выполняющая вставку в таблицу одной строки значений.
INSERT customers (IdCustomer, NameCustomer, BirthdayCustomer, PassportDetails)
VALUES (0, 'Степанов Михаил Артёмович', '1980-08-01', 845000);

--Многострочная инструкция INSERT, выполняющая вставку в таблицу 
--результирующего набора данных вложенного подзапроса.
INSERT into Contracts (numbercontract, datecontract, typecontract, periodcontract, statuscontract, valuecontract, customerpassport, iddirection, idworker)
values ((select max(numbercontract) from contracts) + 1,current_date, 'Двусторонний', '3 года', 'Действительный',
(select AVG(valuecontract)
from contracts
where IdDIrection = '03.00.00'
),845000, '03.00.00',55694);


--Простая инструкция UPDATE
UPDATE Contracts
SET ValueContract = ValueContract * 1.2
WHERE Contracts.IdDirection = '03.00.00'

--Инструкция UPDATE со скалярным подзапросом в предложении SET
UPDATE Contracts
SET ValueContract =
(
	SELECT AVG(ValueContract)
	FROM Contracts
	WHERE IdDirection = '03.00.00'
)
WHERE IdDirection = '03.00.00'

--Простая инструкция DELETE.
delete contracts
where statuscontract = 'Выбыл'

--Инструкция DELETE с вложенным коррелированным подзапросом в
--предложении WHERE.
DELETE FROM Contracts
WHERE NumberContract IN
(
	 SELECT Contracts.NumberContract
	 FROM Contracts JOIN Directions D ON Contracts.IdDirection = D.IdDirection
	 WHERE Contracts.IdDirection = '03.00.00' AND statuscontract = 'Недействительный'
 )
 
--Для каждого направления вывести среднуюю, максимальную и минимальную стоимость
SELECT D.IdDirection, D.NameDirection, CT.ValueContract,
AVG(CT.ValueContract) OVER(PARTITION BY D.IdDirection, D.NameDirection) AS AvgPrice,
MIN(CT.ValueContract) OVER(PARTITION BY D.IdDirection, D.NameDirection) AS MinPrice,
MAX(CT.ValueContract) OVER(PARTITION BY D.IdDirection, D.NameDirection) AS MaxPrice
FROM Contracts CT LEFT OUTER JOIN Directions D ON D.IdDirection = CT.IdDirection

--Инструкция SELECT, использующая простое обобщенное табличное
--выражение
WITH CTE (Contract, ValueContract)
AS
(
	SELECT numbercontract, valuecontract
	from Contracts 
	where statuscontract = 'Действительный'
)
SELECT AVG(ValueContract) as AvgValueContract
FROM CTE

--Инструкция SELECT, использующая рекурсивное обобщенное табличное
--выражение.
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

--Оконные функции для устранения дублей
 
select typecontract, W.idworker, row_number() over (partition by W.IdWorker) as count
INTO WorkerContract
from contracts CS INNER JOIN workers W on CS.IdWorker = W.IdWorker
where typecontract = 'Двусторонний';

delete from WorkerContract
where count > 1;

select typecontract, idworker
from WorkerContract



	

