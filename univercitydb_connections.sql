ALTER TABLE contracts ADD COLUMN CustomerPassport int;
ALTER TABLE contracts ADD 
	CONSTRAINT FK_СustomerPassport FOREIGN KEY(CustomerPassport) REFERENCES customers(PassportDetails);

ALTER TABLE contracts ADD COLUMN IdDirection varchar(256);
ALTER TABLE contracts ADD 
	CONSTRAINT FK_IdDirection FOREIGN KEY(IdDirection) REFERENCES directions(IdDirection);

ALTER TABLE contracts ADD COLUMN IdWorker int;
ALTER TABLE contracts ADD 
	CONSTRAINT FK_IdWorker FOREIGN KEY(IdWorker) REFERENCES workers(IdWorker);

ALTER TABLE pay ADD COLUMN NumberContract int;
ALTER TABLE pay ADD
	CONSTRAINT FK_NumberContract FOREIGN KEY(NumberContract) REFERENCES contracts(NumberContract);

ALTER TABLE directions ADD COLUMN IdExecutor int;
ALTER TABLE directions ADD
	CONSTRAINT FK_IdExecutor FOREIGN KEY(IdExecutor) REFERENCES executors(IdExecutor);

