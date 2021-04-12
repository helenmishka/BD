from contracts import _contractClass
import psycopg2

count = 20

def read_json(cursor):
	cursor.execute("select row_to_json(contracts) from contracts")
	
	records = cursor.fetchmany(count)
	
	result = []
	
	for record in records:
		result.append(_contractClass(record[0]['numbercontract'], record[0]['datecontract'], record[0]['typecontract'], record[0]['periodcontract'], record[0]['statuscontract'], record[0]['valuecontract'], record[0]['customerpassport'], record[0]['iddirection'], record[0]['idworker']))
		
	for record in result:
		print((record.GetDict()))
		
	return result
		
def update_json(contracts, iddirection, koef):
	for record in contracts:
		if record.iddirection == iddirection:
			record.valuecontract *= koef

	for record in contracts:
		if record.iddirection == iddirection:
			print((record.GetDict()))
		
	return contracts
	
def add_json(contracts, new_contract):
	contracts.append(new_contract)

	for record in contracts:
		print((record.GetDict()))
	return contracts
	

if __name__ == "__main__":
	conn = psycopg2.connect(dbname='universitydb', user='helen', 
		                password='159357', host='127.0.0.1', port = '5432')
	cursor = conn.cursor()

	print("Чтение из json-документа:\n")
	contracts = read_json(cursor)
	print("Обновление json-документа:\n")
	contracts = update_json(contracts, '55.00.00', 0.7)
	
	print("Запись в json-документ:\n")
	new_contract = _contractClass(254178, '2020-12-18', 'Двусторонний', '4 года', 'Действительный', 152000, 256201, '03.00.00', 12458)
	contracts = add_json(contracts, new_contract)

	cursor.close()
	conn.close()
