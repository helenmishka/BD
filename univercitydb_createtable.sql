CREATE TABLE customers(
	IdCustomer serial NOT NULL,
	NameCustomer varchar(255) NOT NULL,
	BirthdayCustomer date NOT NULL,
	PassportDetails int PRIMARY KEY NOT NULL
);

CREATE TABLE contracts(
	NumberContract int PRIMARY KEY NOT NULL,
	DateContract date NOT NULL,
	TypeContract varchar(100) NOT NULL,
	PeriodContract varchar(100) NOT NULL,
	StatusContract varchar(100) NOT NULL,
	ValueContract int NOT NULL
);

CREATE TABLE workers(
	IdWorker int PRIMARY KEY NOT NULL,
	NameWorker varchar(256) NOT NULL,
	PostWorker varchar(256) NOT NULL,
	PhoneNumber varchar(50)
);

CREATE TABLE pay(
	AccountNumber int PRIMARY KEY NOT NULL,
	PaymentMethod varchar(256) NOT NULL,
	PaymentDate date
);

CREATE TABLE executors(
	Faculty varchar(256) NOT NULL,
	Department int NOT NULL,
	IdExecutor int PRIMARY KEY NOT NULL
);

CREATE TABLE directions(
	TypeDirection varchar(256) NOT NULL,
	IdDirection int PRIMARY KEY NOT NULL,
	NameDirection varchar(256) NOT NULL
);