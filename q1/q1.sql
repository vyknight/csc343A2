-- Months.

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q1 CASCADE;

CREATE TABLE q1(
    client_id INTEGER,
    email VARCHAR(30),
    months INTEGER
);

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q1
    select Client.client_id, email, count(distinct to_char(Request.datetime, 'MON YYYY'))
    from Client left join (Request join Dropoff on Request.request_id = Dropoff.request_id)
    group by Client.client_id;

-- TESTED AND DONE 
