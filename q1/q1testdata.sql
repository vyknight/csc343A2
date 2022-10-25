SET SEARCH_PATH TO uber, public; 

Insert into Client(client_id, surname, firstname, email) VALUES
    (99, 'Mason', 'Daisy', 'daisy@kitchen.com'),
    (100, 'Crawley', 'Violet', 'dowager@dower-house.org'),
    (88, 'Branson', 'Tom', 'branson@gmail.com');

Insert into Request(request_id, client_id, datetime, source, destination) VALUES
    (3, 100, '2020-02-01 13:00', '(-1.3605, 51.3267)', '(0.41584, 51.3782)'),
    (4, 100, '2020-02-03 08:00', '(0.41584, 51.3782)', '(-1.3605, 51.3267)'),
    (6, 100, '2022-07-01 08:00', '(0.41584, 51.3782)', '(-0.4496, 51.4696)'),
    (5, 99, '2021-01-08 16:10', '(-79.3806, 43.654)', '(-79.6306, 43.6767)');

Insert into Dropoff(request_id, datetime) VALUES
    (3, '2020-02-01 15:07'),
    (4, '2020-02-03 09:30'),
    (6, '2022-07-01 09:16');

-- expected result: (client_id: 100, 2), (client_id: 99, 0), (client_id: 88, 0)