from py_linq import *
from contracts import *

def task_1(contracts):
	#Список договоров направления '03.00.00', отсортированный по дате заключения
	result = contracts.where(lambda x: x['iddirection'] == '03.00.00').order_by(lambda x: x['datecontract']).select(lambda x: {x['numbercontract'], x['datecontract'], x['typecontract'], x['valuecontract'], x['iddirection']})
	for i in result:
		print(i)
		
def task_2(contracts):
	#Максимальная стоимость обучения направления '03.00.00'      
    	result = contracts.where(lambda x: x['iddirection'] == '03.00.00').max(lambda x: x['valuecontract'])
    	print('\n', result)
    	
def task_3(contracts):
	#Количество заказчиков каждого направления (группировка по направлению) 
	result = contracts.group_by(key_names=['iddirection'], key=lambda x: x['iddirection']).select(lambda y: { 'key': y.key.iddirection, 'quantity': y.count()}).to_list()
	for i in range(len(result)):
		print('\n', result[i])
		
def task_4(contracts):
	#Значение True или False в зависимости от условия all(): True, если в каждом направлении количество заказчиков больше 20
	direction = contracts.group_by(key_names=['iddirection'], key=lambda x: x['iddirection']).select(lambda y: { 'key': y.key.iddirection, 'quantity': y.count()})
	result = direction.all(lambda x: x['quantity'] > 20)
	print('\n', result)
	
def task_5(contracts):
	pay = Enumerable([{"accountnumber":82568,"paymentmethod":"Материнский капитал","paymentdate":"2016-01-09","numbercontract":49920},{"accountnumber":70082,"paymentmethod":"Личные средства","paymentdate":"2018-01-27","numbercontract":64788},{"accountnumber":80672,"paymentmethod":"Материнский капитал","paymentdate":"2019-03-24","numbercontract":67733}])
	result = contracts.join(pay, lambda k1: k1['numbercontract'], lambda k2: k2['numbercontract'], lambda result: result)
	for i in result:
		print("\n",i)
        	
def main():
	contracts = Enumerable(get_data("contracts.csv"))
	print("task 1:")
	task_1(contracts)
	print("task 2:")
	task_2(contracts)
	print("task 3:")
	task_3(contracts)
	print("task 4:")
	task_4(contracts)
	print("task 5:")
	task_5(contracts)

if __name__ == "__main__":
    main()
