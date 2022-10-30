-- Do drivers improve?

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO uber, public;
DROP TABLE IF EXISTS q4 CASCADE;

CREATE TABLE q4(
    type VARCHAR(9),
    number INTEGER,
    early FLOAT,
    late FLOAT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS TenDays CASCADE;
DROP VIEW IF EXISTS RatingsPerDay CASCADE;
DROP VIEW IF EXISTS DriverEarlyReviews CASCADE;
DROP VIEW IF EXISTS DriverLaterReviews CASCADE;
DROP VIEW IF EXISTS TrainedStats CASCADE;
DROP VIEW IF EXISTS UntrainedStats CASCADE;
DROP VIEW IF EXISTS TrainedPolished CASCADE;
DROP VIEW IF EXISTS UntrainedPolished CASCADE;

-- Define views here 
create view TenDays as
    select driver_id
    from ClockedIn c join Dispatch d on c.shift_id = d.shift_id
    group by driver_id
    having count(distinct d.datetime::date) >= 10;

create view RatingsPerDay as 
    select driver_id, d.datetime::date as date, sum(rating) as sum_rating, count(rating) as count_rating
    from DriverRating dr, Dispatch d, (ClockedIn natural join TenDays) c
    where d.request_id = dr.request_id and d.shift_id = c.shift_id
    group by driver_id, d.datetime::date
    order by d.datetime::date asc; -- important! 

create view DriverEarlyReviews as
    --select sum(sum_rating) as sum_rating, sum(count_rating) as count_rating, driver_id, date
    --from RatingsPerDay
    --group by driver_id, date
    --order by date asc
    --limit 5;
    --select distinct r_outer.driver_id as driver_id,
    --		r_top.sum_rating, r_top.count_rating, r_top.date
    --	from RatingsPerDay r_outer
	--    join lateral (
	  --  	select * from RatingsPerDay r_inner
	    --	where r_inner.date = r_outer.date and r_inner.driver_id = r_outer.driver_id 
	    	--order by r_inner.date
--	    	limit 5
--	    	) r_top on true 
--	    	order by r_outer.driver_id;
	select *
	from (select ROW_NUMBER() OVER (Partition by driver_id order by date asc) as r, rp.*
		from RatingsPerDay rp) x
		where x.r <= 5;
	-- https://stackoverflow.com/a/6064141
	-- I'm leaving all the previous attempts as if they're scratch marks on the inside of a cell
	-- I even deleted the 5 min(date) views ! 
	-- I'm completely serious on my first try I took grouped by d_id and took the min date values
	-- and then excepted those from the ratingsperday view ! 
	-- 5 times ! 
	-- 6 versions of ratings per day ! 
	-- and it didn't work ! 

create view DriverLaterReviews as
    --select sum(sum_rating) as sum_rating, sum(count_rating) as count_rating, driver_id, date 
    --from RatingsPerDay
    --group by driver_id, date
    --order by date asc
    --limit ALL offset 5;
    select *
	from (select ROW_NUMBER() OVER (Partition by driver_id order by date asc) as r, rp.*
		from RatingsPerDay rp) x
		where x.r > 5;

create view TrainedStats as
    select 'trained' as type, count(distinct de.driver_id) as number, 
            	sum(de.sum_rating) as early_sum_rating,
    		sum(de.count_rating) as early_count_rating,
    		sum(dl.sum_rating) as late_sum_rating,
    		sum(dl.count_rating) as late_count_rating
    from DriverEarlyReviews de join DriverLaterReviews dl on de.driver_id = dl.driver_id
    where de.driver_id in (select driver_id from Driver where trained = TRUE);

create view UntrainedStats as 
    select 'untrained' as type, count(distinct de.driver_id) as number, 
            	sum(de.sum_rating) as early_sum_rating,
    		sum(de.count_rating) as early_count_rating,
    		sum(dl.sum_rating) as late_sum_rating,
    		sum(dl.count_rating) as late_count_rating
    from DriverEarlyReviews de join DriverLaterReviews dl on de.driver_id = dl.driver_id
    where de.driver_id in (select driver_id from Driver where trained = FALSE);

create view TrainedPolished as
	select type, number, 
		early_sum_rating / early_count_rating as early, 
		late_sum_rating / late_count_rating as late
	from TrainedStats;
	
create view UntrainedPolished as
	select type, number, 
		early_sum_rating / early_count_rating as early, 
		late_sum_rating / late_count_rating as late
	from UntrainedStats;
INSERT INTO q4
	-- WHY WHY WHY DOESN THIS NOT WORK 
   -- select type, number, early_sum_rating / early_count_rating as early,
   -- 		 late_sum_rating / late_count_rating as late
    -- from (select * from TrainedStats) stats UNION (select * from UntrainedStats);
    select * from (select * from TrainedPolished) stats union (select * from UntrainedPolished);
-- TESTED 
