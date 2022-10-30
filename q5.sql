-- Bigger and smaller spenders.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q5 CASCADE;

CREATE TABLE q5(
    client_id INTEGER,
    month VARCHAR(7),
    total FLOAT,
    comparison VARCHAR(30)
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS MonthlyAverage CASCADE;
DROP VIEW IF EXISTS ClientMonthlySpending CASCADE;
DROP VIEW IF EXISTS MonthlyAverageWithoutCID CASCADE;
DROP VIEW IF EXISTS ClientNoSpendMonth CASCADE;

-- Define views for your intermediate steps here:

-- find the average of each month
create view MonthlyAverageWithoutCID as
    select TO_CHAR(datetime, 'YYYY MM') as month, avg(amount) as average_amount -- assuming that this is how the average function works 
    from request join billed on request.request_id = billed.request_id
    --group by Date_Part('month', datetime), Date_Part('year', datetime);
    group by TO_CHAR(datetime, 'YYYY MM');

create view MonthlyAverage as
	select *
	from MonthlyAverageWithoutCID m, (select client_id from client) c;

-- find how much each client spent each month 
create view ClientMonthlySpending as 
    select client_id, COALESCE(sum(amount), real '0') as total, to_char(datetime, 'YYYY MM') as month
    from request natural join billed
    group by client_id, to_char(datetime, 'YYYY MM');
    
create view ClientNoSpendMonth as 
	--select c.client_id as client_id, c.total as total, m.month as month
	--from ClientMonthlySpending c left join MonthlyAverage m on c.client_id = m.client_id
	--where c.total = real '0' or c.month is null;
	select m.client_id as client_id, real '0' as total, m.month as month 
	from MonthlyAverage m
	where not exists (select * 
				from clientmonthlyspending c
				where c.client_id = m.client_id and c.month = m.month);

	    
INSERT INTO q5
    select distinct c.client_id, m.month as month, c.total, 
            CASE WHEN c.total >= m.average_amount then 'at or above'
                 ELSE 'below' END as comparison
    from ((select * from ClientMonthlySpending) union (select * from ClientNoSpendMonth)) c join MonthlyAverage m on c.month = m.month and c.client_id = m.client_id
    group by c.client_id, m.month, c.total, m.average_amount;
