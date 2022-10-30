-- Rainmakers.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q10 CASCADE;

CREATE TABLE q10(
    driver_id INTEGER,
    month CHAR(2),
    mileage_2020 FLOAT,
    billings_2020 FLOAT,
    mileage_2021 FLOAT,
    billings_2021 FLOAT,
    mileage_increase FLOAT,
    billings_increase FLOAT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS CrowFliesMileage CASCADE;
DROP VIEW IF EXISTS MonthlyBillings CASCADE;
DROP VIEW IF EXISTS sumCrowFliesMileage CASCADE;
DROP VIEW IF EXISTS sumMonthlyBillings CASCADE;
DROP VIEW IF EXISTS EveryMonthAndDriver CASCADE;
DROP VIEW IF EXISTS NoValuesMonthlyBillings CASCADE;
DROP VIEW IF EXISTS allDistance CASCADE;
DROP VIEW IF EXISTS allBillings CASCADE;




-- Define views for your intermediate steps here:

create view CrowFliesMileage as
    select driver_id,
            to_char(dispatch.datetime, 'MM') as month,
            to_char(dispatch.datetime, 'YYYY') as year, 
            sum(source <@> destination) as distance 
    from Request, Dispatch, ClockedIn
    where (Request.request_id = Dispatch.request_id)
            and (Dispatch.shift_id = ClockedIn.shift_id)
    group by driver_id, to_char(dispatch.datetime, 'MM YYYY'), dispatch.datetime;

create view sumCrowFliesMileage as
	select driver_id, month, year, sum(distance) as distance
	from crowfliesmileage
	group by driver_id, month, year;

create view MonthlyBillings as 
    select driver_id, 
            to_char(dispatch.datetime, 'MM') as month, 
            to_char(dispatch.datetime, 'YYYY') as year, 
            sum(amount) as total
    from Billed, Dispatch, ClockedIn
    where (Billed.request_id = Dispatch.request_id) 
            and (Dispatch.shift_id = ClockedIn.shift_id)
    group by driver_id, to_char(dispatch.datetime, 'MM YYYY'), dispatch.datetime;

create view sumMonthlyBillings as
	select driver_id, month, year, sum(total) as total
	from MonthlyBillings
	group by driver_id, month, year;

DROP TABLE IF EXISTS q10months CASCADE;
Create Table q10months(
	month CHAR(2),
	year CHAR(4)
);
INSERT INTO q10months VALUES
	('01', '2020'), ('02', '2020'), ('03', '2020'), ('04', '2020'), 
	('05', '2020'), ('06', '2020'), ('07', '2020'), ('08', '2020'), 
	('09', '2020'), ('10', '2020'), ('11', '2020'), ('12', '2020'),
	('01', '2021'), ('02', '2021'), ('03', '2021'), ('04', '2021'), 
	('05', '2021'), ('06', '2021'), ('07', '2021'), ('08', '2021'), 
	('09', '2021'), ('10', '2021'), ('11', '2021'), ('12', '2021');

create view EveryMonthAndDriver as
	select month, year, driver_id
	from q10months, driver;
	
create view NoValuesMonthlyBillings as
	select e.driver_id as driver_id,
		e.month as month,
		e.year as year,
		float '0' as total
	from EveryMonthAndDriver e where not exists
		(select * from MonthlyBillings m
			where e.month = m.month and e.year = m.year and e.driver_id = m.driver_id); 

create view NoValuesCrowFliesMileage as
	select	e.driver_id as driver_id,
		e.month as month,
		e.year as year,
		float '0' as distance
	from EveryMonthAndDriver e where not exists
		(select * from CrowFliesMileage c
			where e.month = c.month and e.year = c.year and e.driver_id = c.driver_id);

create view allDistance as
	select driver_id, month, year, distance
	from (select * from sumCrowFliesMileage) f union (select * from NoValuesCrowFliesMileage);

	
create view allBillings as 
	select f.driver_id, f.month, f.year, sum(f.total) as total 
	from ((select * from MonthlyBillings) union (select * from NoValuesMonthlyBillings)) f 
	group by f.driver_id, f.month, f.year;


-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q10
    select c2021.driver_id as driver_id,
            c2021.month as month,
            c2020.distance as mileage_2020,
            m2020.total as billings_2020,
            c2021.distance as mileage_2021,
            m2021.total as billings_2021,
            c2021.distance - c2020.distance as mileage_increase,
            m2021.total - m2020.total as billings_increase
    from (select * from allDistance where year = char '2020') c2020,
            (select * from allBillings where year = char '2020') m2020,
            (select * from allDistance where year = char '2021') c2021, 
            (select * from allBillings where year = char '2021') m2021
    where (c2020.driver_id = m2020.driver_id)
            and (m2020.driver_id = c2021.driver_id)
            and (c2021.driver_id = m2021.driver_id)
            and (c2020.month = m2020.month)
            and (m2020.month = c2021.month)
            and (c2021.month = m2021.month);


-- TESTED 
