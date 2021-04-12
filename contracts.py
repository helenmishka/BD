class _contractClass():
    numbercontract = int()
    datecontract = str()
    typecontract = str()
    periodcontract = str()
    statuscontract = str()
    valuecontract = int()
    customerpassport = int()
    iddirection = str()
    idworker = int()

    def __init__(self, numbercontract, datecontract, typecontract, periodcontract, statuscontract, valuecontract, customerpassport, iddirection, idworker):
        self.numbercontract = numbercontract
        self.datecontract = datecontract
        self.typecontract = typecontract
        self.periodcontract = periodcontract
        self.statuscontract = statuscontract
        self.valuecontract = valuecontract
        self.customerpassport = customerpassport
        self.iddirection = iddirection
        self.idworker = idworker

    def GetDict(self):
        return {'numbercontract': self.numbercontract, 'datecontract': self.datecontract, 'typecontract': self.typecontract,'periodcontract': self.periodcontract, 'statuscontract': self.statuscontract, 'valuecontract': self.valuecontract,'customerpassport': self.customerpassport, 'iddirection': self.iddirection, 'idworker': self.idworker}


def get_data(file_name):
    file = open(file_name, 'r')
    _contract = list()

    for line in file:
        contract_array = line.split(',')
	
        contract_array[0] = int(contract_array[0])
        contract_array[5] = int(contract_array[5])
        contract_array[6] = int(contract_array[6])
        contract_array[8] = int(contract_array[8])
        

        _contract.append(_contractClass(*contract_array).GetDict())

    return _contract
