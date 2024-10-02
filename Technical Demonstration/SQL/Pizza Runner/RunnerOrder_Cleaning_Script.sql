#Cleaning the NULL values from the table
UPDATE RUNNER_ORDERS 
SET pickup_time = NULL 
WHERE pickup_time = 'null';

UPDATE RUNNER_ORDERS 
SET distance = NULL 
WHERE distance = 'null';

UPDATE RUNNER_ORDERS 
SET duration = NULL 
WHERE duration = 'null';

UPDATE RUNNER_ORDERS 
SET cancellation = NULL 
WHERE cancellation = 'null';

UPDATE RUNNER_ORDERS 
SET cancellation = NULL 
WHERE cancellation = '';

UPDATE RUNNER_ORDERS 
SET distance = REPLACE(distance,' km','') 
WHERE distance LIKE '% km';

UPDATE RUNNER_ORDERS 
SET distance = REPLACE(distance,'km','') 
WHERE distance LIKE '%km';

ALTER TABLE RUNNER_ORDERS 
CHANGE distance distance_in_km float;

UPDATE RUNNER_ORDERS 
SET duration = REPLACE(duration,' minutes','') 
WHERE duration LIKE '% minutes';

UPDATE RUNNER_ORDERS 
SET duration = REPLACE(duration,'minutes','') 
WHERE duration LIKE '%minutes';

UPDATE RUNNER_ORDERS 
SET duration = REPLACE(duration,' minute','') 
WHERE duration LIKE '% minute';

UPDATE RUNNER_ORDERS 
SET duration = REPLACE(duration,' minute','') 
WHERE duration LIKE '% minute';

UPDATE RUNNER_ORDERS 
SET duration = REPLACE(duration,' mins','') 
WHERE duration LIKE '% mins';

UPDATE RUNNER_ORDERS 
SET duration = REPLACE(duration,'mins','') 
WHERE duration LIKE '%mins';

ALTER TABLE RUNNER_ORDERS 
CHANGE duration duration_in_mins int;