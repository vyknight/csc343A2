-- tables used in q3: pickup, dropoff, dispatch, clockedin, 
-- conditions that should get one removed from the final table
-- breaking the bylaw only once or twice or in 3 non-consecutive days
-- having 16 minutes of breaks
-- having less than 12 hours of ride duration 

SET SEARCH_PATH TO uber, public; 

INSERT INTO ClockedIn(shift_id, driver_id, datetime) VALUES
	(1, 1, '2020-01-01'), -- breaker of bylaw
	(2, 1, '2020-01-02'),
	(3, 1, '2020-01-03');

INSERT INTO Dispatch(request_id, shift_id, car_location, datetime) VALUES
	(1, 1, '(-79.3871, 43.6426)', '2020-01-01 02:00'),
	(2, 2, '(-79.3871, 43.6426)', '2020-01-02 02:00'),
	(3, 3, '(-79.3871, 43.6426)', '2020-01-03 02:00');

INSERT INTO Pickup(request_id, datetime) VALUES
	(1, '2020-01-01 3:00'),
	(2, '2020-01-02 3:00'),
	(3, '2020-01-03 3:00');

INSERT INTO Dropoff(request_id, datetime) VALUES
	(1, '2020-01-01 23:00'),
	(2, '2020-01-02 23:00'),
	(3, '2020-01-03 23:00');