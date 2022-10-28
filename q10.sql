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


-- Define views for your intermediate steps here:

create view CrowFliesMileage as
    select driver_id,
            to_char(dispatch.datetime, 'MM') as month,
            to_char(dispatch.datetime, 'YYYY') as year, 
            sum(source <@> destination) as distance 
    from Request, Dispatch, ClockedIn
    where (Request.request_id = Dispatch.request_id)
            and (Dispatch.shift_id = ClockedIn.shift_id)
    group by driver_id, to_char(dispatch.datetime, 'MM YYYY');

create view MonthlyBillings as 
    select driver_id, 
            to_char(dispatch.datetime, 'MM') as month, 
            to_char(dispatch.datetime, 'YYYY') as year, 
            sum(amount) as total
    from Billed, Dispatch, ClockedIn
    where (Billed.request_id = Dispatch.request_id) 
            and (Dispatch.shift_id = ClockedIn.shift_id)
    group by driver_id, to_char(dispatch.datetime, 'MM YYYY');

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
    from (select * from CrowFliesMileage where year = 2020) c2020,
            (select * from MonthlyBillings where year = 2020) m2020,
            (select * from CrowFliesMileage where year = 2021) c2021, 
            (select * from MonthlyBillings where year = 2021) m2021
    where (c2020.driver_id = m2020.driver_id)
            and (m2020.driver_id = c2021.driver_id)
            and (c2021.driver_id = m2021.driver_id)
            and (c2020.month = m2020.month)
            and (m2020.month = c2021.month)
            and (c2021.month = m2021.month);


-- UNTESTED 