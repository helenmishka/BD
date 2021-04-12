import psycopg2

def scalar_inquiry(cursor):
	type_contract = input("Введите тип договора: ")
	try:
		cursor.execute('SELECT AVG(ValueContract) as AvgValueContract FROM Contracts WHERE TypeContract = %(t)s',{"t": type_contract})
		for row in cursor:
			print(row, "\n")
	except:
		print('Что-то пошло не так, попробуй еще раз!\n')
	
def multi_join(cursor):
	number_contract = input("Введите номер договора: ")
	try:
		cursor.execute('select ct.numbercontract, p.accountnumber, cs.namecustomer from customers cs join contracts ct on cs.passportdetails = ct.customerpassport join pay p on ct.numbercontract = p.numbercontract where ct.numbercontract = %(n)s', {"n": number_contract})
		for row in cursor:
			print(row, "\n")
	except:
		print('Что-то пошло не так, попробуй еще раз!\n')
	
def cte(cursor):
	try:
		cursor.execute('WITH CTE (IdDirection, NameDirection, ValueContract) AS (SELECT D.IdDirection, D.NameDirection, CT.ValueContract FROM Contracts CT LEFT OUTER JOIN Directions D ON D.IdDirection = CT.IdDirection) SELECT AVG(ValueContract) OVER(PARTITION BY IdDirection, NameDirection) AS AvgPrice, MIN(ValueContract) OVER(PARTITION BY IdDirection, NameDirection) AS MinPrice, MAX(ValueContract) OVER(PARTITION BY IdDirection, NameDirection) AS MaxPrice from cte')
		for row in cursor:
			print(row, "\n")
	except:
		print('Что-то пошло не так, попробуй еще раз!\n')
def meta_inquiry(cursor):
	nametable = input("Введите название таблицы: ")
	try:
		cursor.execute('SELECT %(n)s as table, pg_size_pretty(pg_total_relation_size(%(n)s)) as size',{"n": nametable})
		for row in cursor:
			print(row, "\n")
	except:
		print('Что-то пошло не так, попробуй еще раз!\n')
def scalar_function(cursor):
	direction = input("Введите IdDirection: ")
	try:
		cursor.execute('select * from AvgValueDirection(%(d)s)', {"d": direction})
		for row in cursor:
			print(row, "\n")
	except:
		print('Что-то пошло не так, попробуй еще раз!\n')
def table_function(cursor):
	date_s = input("Введите начальную дата (example: 2020-01-01): ")
	date_e = input("Введите конечную дату (example: 2020-01-01): ")
	try:
		cursor.execute('select * from CheckDateContract(%(start)s, %(end)s)', {"start": date_s, "end": date_e})
		for row in cursor:
			print(row, "\n")
	except:
		print('Что-то пошло не так, попробуй еще раз!\n')
def storing_procedure(cursor):
	koef = input("Введите коэффициент: ")
	direction = input("Введите IdDirection: ")
	try:
		cursor.execute('drop table if exists contracts_copy')
		cursor.execute('select * into temp contracts_copy from contracts')
		cursor.execute('call update_valuecontract(%(k)s, %(d)s)',{"k": koef, "d": direction})
		cursor.execute('select Contracts.NumberContract, Contracts.IdDirection,Contracts.ValueContract as old_value, contracts_copy.ValueContract as new_value from contracts_copy join contracts on contracts_copy.NumberContract = contracts.NumberContract where Contracts.IdDirection = %(d)s',{"d": direction})
		for row in cursor:
			print(row, "\n")
	except:
		print('Что-то пошло не так, попробуй еще раз!\n')
		
def name_db(cursor):
	try:
		cursor.execute('SELECT current_database()')
		for row in cursor:
			print(row, "\n")
	except:
		print('Что-то пошло не так, попробуй еще раз!\n')
	
def create_table(cursor):
	try:
		cursor.execute("drop table if exists teachers;")
		cursor.execute("create table if not exists teachers (id int PRIMARY KEY NOT NULL, name varchar(256) NOT NULL);")
		cursor.execute("ALTER TABLE teachers ADD COLUMN IdExecutor int; ALTER TABLE teachers ADD CONSTRAINT FK_IdExecutor FOREIGN KEY(IdExecutor) REFERENCES executors(IdExecutor);")
		print("Таблица создана\n")
	except:
		print('Что-то пошло не так, попробуй еще раз!\n')
	return 1
def insert_in_table(cursor):
	try:
		cursor.execute("insert into teachers values (1, 'Коровин Петр',848421),(2, 'Klichko Mikhaail',852753);")
		cursor.execute("select * from teachers")
	except:
		print('Что-то пошло не так, попробуй еще раз!\n')
	return 1
if __name__ == "__main__":
	flag_create = 0
	flag_insert = 0
	flag_create, flag_insert = 0, 0
	conn = psycopg2.connect(dbname='universitydb', user='helen', 
		                password='159357', host='127.0.0.1', port = '5432')
	cursor = conn.cursor()
	print("MENU:\n1.Средняя стоимость обучения по типу договора\n2.Информация о договоре по номеру договора\n3.Средняя,минимальная и  максимальная стоимость обучения по всем направлениям\n4.Размер таблицы\n5.Средняя стоимость обучения по заданному направлению\n6.Вывести все договоры за определенный интервал\n7.Изменить стоимость обучения по определенному направлению\n8.Получить имя текущей базы данных\n9.Создать таблицу преподавателей\n10.Заполнить таблицу преподавателей\n0.Выход\n")
	
	menu = int(input("Выберите действие: "))
	while(menu != 0):
		if (menu == 1):
			scalar_inquiry(cursor)
			conn.commit()
		elif (menu == 2):
			multi_join(cursor)
			conn.commit()
		elif (menu == 3):
			cte(cursor)
			conn.commit()
		elif (menu == 4):
			meta_inquiry(cursor)
			conn.commit()
		elif (menu == 5):
			scalar_function(cursor)
			conn.commit()
		elif (menu == 6):
			table_function(cursor)
			conn.commit()
		elif (menu == 7):
			storing_procedure(cursor)
			conn.commit()
		elif (menu == 8):
			name_db(cursor)
			conn.commit()
		elif (menu == 9):
			if (flag_create == 0):
				flag_create = create_table(cursor)
				conn.commit()
			else:
				print("Таблица уже создана\n")
		elif (menu == 10):
			if flag_create == 1 and flag_insert == 0:
				flag_insert = insert_in_table(cursor)
				conn.commit()
			elif flag_create == 0:
				print("Таблица не создана\n")
			else:
				print("Данные уже добавлены\n")
			
		print("MENU:\n1.Средняя стоимость обучения по типу договора\n2.Информация о договоре по номеру договора\n3.Средняя,минимальная и  максимальная стоимость обучения по всем направлениям\n4.Размер таблицы\n5.Средняя стоимость обучения по заданному направлению\n6.Вывести все договоры за определенный интервал\n7.Изменить стоимость обучения по определенному направлению\n8.Получить имя текущей базы данных\n9.Создать таблицу преподавателей\n10.Заполнить таблицу преподавателей\n0.Выход\n")
		menu = int(input("Выберите действие: "))
		
	cursor.close()
	conn.close()

