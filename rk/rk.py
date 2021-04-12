import psycopg2

def func_1(cursor):
	try:
		cursor.execute("select distinct department \
		from\
		( select department, count(id_w)\
		from workers \
		group by department) t where t.count > 10")
		
		for row in cursor:
			print(row, "\n")
	except:
		print('Что-то пошло не так, попробуй еще раз!\n')
def func_2(cursor):
	try:
		cursor.execute("select x.id_w, w.fio \
				from \
				(select id_w, count(*) \
				from t_w \
				where date_w = '14-12-2018' and type_w = 2 \
				group by id_w \
				)as x join workers w on x.id_w = w.id_w \
				where x.count = 1")
		for row in cursor:
			print(row, "\n")
	except:
		print('Что-то пошло не так, попробуй еще раз!\n')
def func_3(cursor):
	try:
		date = input("DATE: ")
		cursor.execute("select w.department \
				from \
				(select first_t.id_w, count(*) \
				from \
				(select id_w, min(t_w.time_w) as first_time, date_w \
					from t_w \
					where t_w.type_w = 1 \
					group by id_w, date_w \
				)as first_t \
				where first_t.first_time > '9:00' and first_t.date_w = %(start)s \
				group by first_t.id_w)d \
				join workers w on d.id_w = w.id_w", {"start": date})
		for row in cursor:
			print(row, "\n")
	except:
		print('Что-то пошло не так, попробуй еще раз!\n')
		

		
if __name__ == "__main__":
	conn = psycopg2.connect(dbname='rk', user='helen', 
		                password='159357', host='127.0.0.1', port = '5432')
	cursor = conn.cursor()
	print("MENU:\n1.Найти отделы, в которых работает более 10 сотрудников \n2.Найти сотрудников,которые не выходят с рабочего места\n3.Опоздавшие сотрудники\n")
	
	menu = int(input("Выберите действие: "))
	while(menu != 0):
		if (menu == 1):
			func_1(cursor)
			conn.commit()
		elif (menu == 2):
			func_2(cursor)
			conn.commit()
		elif (menu == 3):
			func_3(cursor)
			conn.commit()
			
		print("MENU:\n1.Найти отделы, в которых работает более 10 сотрудников \n2.Найти сотрудников,которые не выходят с рабочего места\n3.Отделы, опоздавшие сотрудники\n")
		menu = int(input("Выберите действие: "))
		
	cursor.close()
	conn.close()


