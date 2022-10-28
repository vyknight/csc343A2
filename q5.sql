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

-- Define views for your intermediate steps here:

-- find the average of each month
create view MonthlyAverage as
    select TO_CHAR(datetime, 'YYYY MM') as month, avg(amount) as average_amount -- assuming that this is how the average function works 
    from request join billed on request.request_id = billed.request_id
    --group by Date_Part('month', datetime), Date_Part('year', datetime);
    group by TO_CHAR(datetime, 'YYYY MM');

-- find how much each client spent each month 
create view ClientMonthlySpending as 
    select client.client_id as client_id, sum(amount) as total, TO_CHAR(datetime, 'YYYY MM') as month
    from client, (request join billed on request.request_id = billed.request_id) as ride
    where (ride.client_id = client.client_id
    group by client_id, to_char(datetime, 'YYYY MM');
    
INSERT INTO q5
    select client_id, c.month as month, COALESCE(sum(c.total), '0') as total, 
            CASE WHEN c.total >= m.average_amount then 'at or above'
                 ELSE 'below' as comparison
    from ClientMonthlySpending c left join MonthlyAverage m on c.month = m.month;


-- find people who spent during each month 
-- find people who didn't spend during each month 
-- create view DidNotSpend as 
--     select client_id
--     from client
--     where not exists (
--         select * 
--         from Client, ClientMonthlySpending, MonthlyAverage 
--         where client.client_id = ClientMonthlySpending
--                 and ClientMonthlySpending.month = MonthlyAverage.month)
-- create view DidNotSpend as 
--     select client_id 
--     from client left join (ClientMonthlySpending right join MonthlyAverage on ClientMonthlySpending.month = MonthlyAverage.month

-- Your query that answers the question goes below the "insert into" line:
-- INSERT INTO q5
--     select 
--         client_id,
--         MonthlyAverage.month as month,
--         ClientMonthlySpending.total as total, -- fucking hell there are clients who didn't spend this month 
--         CASE 
--             WHEN MonthlyAverage.average_amount is null THEN 'below'
--             WHEN ClientMonthlySpending.total > MonthlyAverage.average_amount THEN 'at or above'
--             ELSE 'below'
--         END as comparison
--     from ClientMonthlySpending left join MonthlyAverage on ClientMonthlySpending.month = MonthlyAverage.month;



