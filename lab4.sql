create or replace function get_name_by_contract(contract int) returns varchar
as $$
ppl = plpy.execute("select * from contracts ct join customers cs on ct.customerpassport = cs.passportdetails")
for customer in ppl:
	if customer['numbercontract'] == contract:
		return customer['customername']
return 'None'
$$ language plpython3u;