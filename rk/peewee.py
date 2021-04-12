from peewee import *
import datetime
conn = PostgresqlDatabase(
    database='rk',
    user='helen',
    password='159357',
    host='127.0.0.1', 
    port="5432"
)

class BaseModel(Model):
    class Meta:
        database = conn 

class workers(BaseModel):
	id_w = IntegerField(column_name='id_w')
	fio = CharField(column_name='fio')
	birthday = DateField(column_name='birthday')
	department = CharField(column_name='department')
	class Meta:
        	table_name = 'workers'
class t_w(BaseModel):
	id_w = IntegerField(column_name='id_w')
	date_w = DateField(column_name='date_w')
	day_w = CharField(column_name='day_w')
	time_w = TimeField(column_name='time_w')
	type_w = IntegerField(column_name='type_w')
	class Meta:
        	table_name = 't_w'
   
def func_3():  
	date = input("DATE: ")
	first_t = t_w.alias()   
	cte = (first_t.select(first_t.id_w, fn.MIN(first_t.time_w), first_t.date_w).where(first_t.type_w == 1).group_by(first_t.id_w, first_t.date_w).cte('first_t', columns = ('id', 'first_time', 'date')))
	
	subquery = cte.select_from(cte.c.id, fn.count(cte.c.id)).alias("count").where(cte.c.first_time > '9:00',cte.c.date == date).group_by(cte.c.id)
	
	query = workers.select(workers.department).join(subquery, on=(workers.id_w == subquery.c.id))
	
	result = query.dicts().execute()
	for i in result:
		print(i)
	
def func_1():
	print("\nЗапрос 1:")
	t = workers.alias()
	
	subquery_1 = (t.select(t.department, fn.COUNT(t.id_w).alias("count")).group_by(t.department).alias('sub_1'))
	
	query = workers.select(workers.department.distinct()).join(subquery_1, on=(workers.department == subquery_1.c.department)).where(subquery_1.c.count > 10)
	
	result = query.dicts().execute()
	for i in result:
		print(i)
def func_2():
	print("\nЗапрос 3:")
	x = t_w.alias()
	
	subquery_1 = (x.select(x.id_w, fn.COUNT(x.id_w).alias("count")).where(x.date_w == '14-12-2018', x.type_w == 2).group_by(x.id_w).alias('sub_1'))
	
	query = workers.select(workers.id_w,workers.fio).join(subquery_1, on=(workers.id_w == subquery_1.c.id_w)).where(subquery_1.c.count == 1)
	
	result = query.dicts().execute()
	for i in result:
		print(i)
	

if __name__ == "__main__":
	func_1()
	func_2()
	func_3()
