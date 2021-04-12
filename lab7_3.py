from peewee import *

# Создаем соединение с базой данных
conn = PostgresqlDatabase(
    database='universitydb',
    user='helen',
    password='159357',
    host='127.0.0.1', 
    port="5432"
)

# Определяем базовую модель о которой будут наследоваться остальные
class BaseModel(Model):
    class Meta:
        database = conn #соединение с базой, из шаблона выше

class contracts(BaseModel):
	numbercontract = IntegerField(column_name= 'numbercontract')
	datecontract = CharField(column_name='datecontract')
	typecontract = CharField(column_name='typecontract')
	periodcontract = CharField(column_name='periodcontract')
	statuscontract = CharField(column_name='statuscontract')
	valuecontract = IntegerField(column_name= 'valuecontract')
	customerpassport = IntegerField(column_name= 'customerpassport')
	iddirection = CharField(column_name='iddirection')
	idworker = IntegerField(column_name= 'idworker')
	
	class Meta:
        	table_name = 'contracts'
        	
class pay(BaseModel):
	accountnumber = IntegerField(column_name= 'accountnumber')
	paymentmethod = CharField(column_name='paymentmethod')
	paymentdate = CharField(column_name='paymentdate')
	numbercontract = IntegerField(column_name= 'numbercontract')
	class Meta:
        	table_name = 'pay'
class customers(BaseModel):
	idcustomer = IntegerField(column_name= 'idcustomer')
	namecustomer = CharField(column_name='namecustomer')
	birthdaycustomer = CharField(column_name='birthdaycustomer')
	passportdetails = IntegerField(column_name= 'passportdetails')
	class Meta:
        	table_name = 'customers'
class directions(BaseModel):
	typedirection = CharField(column_name='typedirection')
	iddirection = CharField(column_name='iddirection')
	namedirection  = CharField(column_name='namedirection')
	idexecutor = IntegerField(column_name= 'idexecutor')
	class Meta:
        	table_name = 'directions'
class executors(BaseModel):
	faculty = CharField(column_name='faculty')
	department  = CharField(column_name='department')
	idexecutor = IntegerField(column_name= 'idexecutor')
	class Meta:
        	table_name = 'executors'
class workers(BaseModel):
	idworker = IntegerField(column_name= 'idworker')
	nameworker = CharField(column_name='nameworker')
	postworker  = CharField(column_name='postworker')
	phonenumber = IntegerField(column_name= 'phonenumber')
	class Meta:
        	table_name = 'workers'
        	
def task_1():
	global conn
	
	print("Однотабличный запрос на выборку\n")
	query = pay.select(pay.accountnumber, pay.numbercontract).where(pay.paymentmethod == "Материнский капитал")
	print("Запрос на счета с методом оплаты Материнский капитал:\n", query)
	
	result = query.dicts().execute()
	
	for i in result:
		print(i)
def task_2():
	global conn
	
	print("Многотабличный запрос на выборку\n")
	
	query = pay.select(pay.numbercontract, pay.accountnumber, pay.paymentmethod).join(contracts, on =(contracts.numbercontract == pay.numbercontract)).limit(20)
	print("Запрос на первые 20 договоров, выдающий информацию об оплате:\n", query)
	
	result = query.dicts().execute()
	
	for i in result:
		print(i)
def add_executor(n_faculty, n_department, n_id):
	global conn
	try:
		with conn.atomic():
			executors.create(faculty = n_faculty, department = n_department, idexecutor = n_id)
			print("ADDED")
	except:
		print("Error")
def update_executor(id_, n_department):
	result = executors.select(executors.idexecutor, executors.faculty, executors.department).where(executors.idexecutor == id_).get()
	
	result.department = n_department
	result.save()
	
	print("UPDATED")
def delete_executor(id_):
	result = executors.select(executors.idexecutor, executors.faculty, executors.department).where(executors.idexecutor == id_).get()
	
	result.delete_instance()
	
	print("DELETED")

def print_table(id_):
	query = executors.select(executors.idexecutor, executors.faculty, executors.department).where(executors.idexecutor == id_)
	
	result = query.dicts().execute()
	
	for i in result:
		print(i)
	
def task_3():
	print("Три запроса на добавление, изменение и удаление данных в базе данных")
	
	print("ID = 1111111:\n")
	
	print("ADD\n")
	add_executor('TEST', 'TEST_D', 1111111)
	print_table(1111111)
	
	print("UPDATE\n")
	#update_executor(1111111, 'TEST_C')
	#print_table(1111111)
	
	print("DELETE")
	delete_executor(1111111)
	print_table(1111111)
	
def task_4():
	global conn
	    
	cursor = conn.cursor()

	print("Получение доступа к данным, выполняя только хранимую процедуру")
	
	query = workers.select().where(workers.postworker == 'Конусультант')
	
	result = query.dicts().execute()
	
	for i in result:
		print(i)
		
	cursor.execute("call update_postworker('Консультант', 'Оператор');")
	conn.commit()
	
	query = workers.select().where(workers.postworker == 'Конусультант')
	
	result = query.dicts().execute()
	
	for i in result:
		print(i)
if __name__ == "__main__":
	#global conn
	
	#task_1()
	#task_2()
	task_3()
	#task_4()
	
	conn.close()
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	 
