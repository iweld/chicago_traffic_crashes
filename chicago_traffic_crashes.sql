/*

	Chicago Traffic Crashes
	
	An SQL analysis about each traffic crash on city streets within the City of Chicago limits and under 
	the jurisdiction of Chicago Police Department (CPD). Data shown as is from the electronic crash reporting system 
	(E-Crash) at CPD, excluding any personally identifiable information.
	
	Author: Jaime M. Shaker
	Email: jaime.m.shaker@gmail.com
	Website: https://www.shaker.dev
	
		column_name              |
	-----------------------------+
	crash_date                   |
	date_police_notified         |
	crash_id                     |
	device_condition             |
	weather_condition            |
	lighting_condition           |
	first_crash_type             |
	traffic_way_type             |
	lane_count                   |
	alignment                    |
	roadway_surface_condition    |
	road_defect                  |
	report_type                  |
	crash_type                   |
	hit_and_run                  |
	damage                       |
	primary_cause                |
	secondary_cause              |
	street_direction             |
	street_name                  |
	statement_taken              |
	work_zone                    |
	work_zone_type               |
	workers_present              |
	number_unit                  |
	most_severe_injury           |
	injuries_total               |
	injuries_fatal               |
	injuries_incapacitated       |
	injuries_non_incapacitated   |
	injuries_reported_not_evident|
	crash_hour                   |
	crash_day_of_week            |
	crash_month                  |
	latitude                     |
	longitude                    |
	crash_location               |
	posted_speed_limit           |
	traffic_control_device       |

*/

-- What is the total count of recorded crashes?

SELECT
	count(*)
FROM
	crashes
	
-- Results:

count |
------+
686276|

-- What is the earliest and latest date?

SELECT 
	min(crash_date),
	max(crash_date)
FROM	
	crashes;

-- Results:

min                    |max                    |
-----------------------+-----------------------+
2013-03-03 16:48:00.000|2023-01-12 23:36:00.000|

-- What is the number of reported crashes per year?

SELECT
	EXTRACT(YEAR FROM crash_date) AS crash_year,
	count(*) AS reported_crashes
FROM
	crashes
GROUP BY
	crash_year
ORDER BY 
	crash_year;

-- Results:

crash_year|reported_crashes|
----------+----------------+
    2013.0|               2|
    2014.0|               6|
    2015.0|            9828|
    2016.0|           44297|
    2017.0|           83786|
    2018.0|          118950|
    2019.0|          117762|
    2020.0|           92088|
    2021.0|          108756|
    2022.0|          108292|
    2023.0|            2509|
 
-- What is the number of reported crashes and weather conditions betweeen 2017 and 2022?   

SELECT
	EXTRACT(YEAR FROM crash_date)::numeric AS crash_year,
	weather_condition,
	count(*) AS reported_crashes
FROM
	crashes
WHERE
	EXTRACT(YEAR FROM crash_date) between '2017.0' AND '2022.0'
AND
	weather_condition = 'clear'
GROUP BY
	crash_year,
	weather_condition
HAVING count(*) > 1999
ORDER BY 
	crash_year;

-- Results:

crash_year|weather_condition|reported_crashes|
----------+-----------------+----------------+
      2017|clear            |           67663|
      2018|clear            |           94006|
      2019|clear            |           91604|
      2020|clear            |           74195|
      2021|clear            |           86696|
      2022|clear            |           83615| 
     
-- How many crashes involved and injury or vehicle tow?
      
SELECT 
	crash_type,
	count(*)
FROM 
	crashes
GROUP BY 
	crash_type
	
-- Results:
	
crash_type                      |count |
--------------------------------+------+
injury and / or tow due to crash|180501|
no injury / drive away          |505775|

-- What is the crash count depending on the day of the week?

SELECT
	initcap(crash_day_of_week) AS day_of_week,
	count(*) AS crash_count
FROM 
	crashes
GROUP BY 
	crash_day_of_week
ORDER BY 
	crash_count DESC;

-- Results:

day_of_week|crash_count|
-----------+-----------+
Friday     |     111684|
Saturday   |     101816|
Thursday   |      98239|
Tuesday    |      97883|
Wednesday  |      97257|
Monday     |      94582|
Sunday     |      84815|

-- What was the primary cause of the crash?

SELECT 
	DISTINCT primary_cause
FROM
	crashes;

-- Results:

primary_cause                                                                   |
--------------------------------------------------------------------------------+
failing to reduce speed to avoid crash                                          |
equipment - vehicle condition                                                   |
cell phone use other than texting                                               |
disregarding stop sign                                                          |
vision obscured (signs, tree limbs, buildings, etc.)                            |
unable to determine                                                             |
improper lane usage                                                             |
driving on wrong side/wrong way                                                 |
physical condition of driver                                                    |
failing to yield right-of-way                                                   |
exceeding safe speed for conditions                                             |
distraction - other electronic device (navigation device, dvd player, etc.)     |
passing stopped school bus                                                      |
road construction/maintenance                                                   |
had been drinking (use when arrest is not made)                                 |
road engineering/surface/marking defects                                        |
improper turning/no signal                                                      |
distraction - from outside vehicle                                              |
bicycle advancing legally on red light                                          |
distraction - from inside vehicle                                               |
disregarding other traffic signs                                                |
related to bus stop                                                             |
motorcycle advancing legally on red light                                       |
texting                                                                         |
improper backing                                                                |
following too closely                                                           |
evasive action due to animal, object, nonmotorist                               |
disregarding road markings                                                      |
driving skills/knowledge/experience                                             |
under the influence of alcohol/drugs (use when arrest is effected)              |
not applicable                                                                  |
disregarding yield sign                                                         |
disregarding traffic signals                                                    |
turning right on red                                                            |
obstructed crosswalks                                                           |
exceeding authorized speed limit                                                |
operating vehicle in erratic, reckless, careless, negligent or aggressive manner|
improper overtaking/passing                                                     |
weather                                                                         |
animal                                                                          |

-- What is the number of text caused accidents and on what day of the week?

SELECT
	initcap(crash_day_of_week) AS day_of_week,
	count(*) AS crash_count
FROM 
	crashes
WHERE
	primary_cause LIKE '%text%'
GROUP BY
	day_of_week
ORDER BY
	crash_count DESC;

-- Results:

day_of_week|crash_count|
-----------+-----------+
Saturday   |        210|
Friday     |        193|
Sunday     |        174|
Tuesday    |        172|
Thursday   |        165|
Monday     |        156|
Wednesday  |        150|

-- What is the most common primary cause of crashes?

SELECT
	DISTINCT primary_cause,
	count(*) cause_count
FROM
	crashes
GROUP BY
	primary_cause
ORDER BY
	cause_count DESC
LIMIT 10;

-- Results:

primary_cause                         |cause_count|
--------------------------------------+-----------+
unable to determine                   |     263512|
failing to yield right-of-way         |      74978|
following too closely                 |      68471|
not applicable                        |      36078|
improper overtaking/passing           |      33180|
failing to reduce speed to avoid crash|      29374|
improper backing                      |      28028|
improper lane usage                   |      25346|
improper turning/no signal            |      22665|
driving skills/knowledge/experience   |      22204|

-- What where the lighting conditions for most crashes?

SELECT 
	DISTINCT lighting_condition,
	count(*) AS crash_count
FROM
	crashes
GROUP BY
	lighting_condition;

-- Results:

lighting_condition    |crash_count|
----------------------+-----------+
darkness              |      32967|
darkness, lighted road|     151402|
dawn                  |      11532|
daylight              |     442082|
dusk                  |      20117|
unknown               |      28176|

-- How many hit and runs?

SELECT
	hit_and_run,
	count(*) AS crash_count
FROM
	crashes
WHERE
	hit_and_run = 'y'
GROUP BY
	hit_and_run;

-- Results:

hit_and_run|crash_count|
-----------+-----------+
y          |     203703|

-- Create a temp table with only crashes betweeon 2017 and 2022
DROP TABLE IF EXISTS crash_timeline;
CREATE TEMP TABLE crash_timeline AS
(
	SELECT
		*
	FROM
		crashes
	WHERE
		EXTRACT(YEAR FROM crash_date) between '2017.0' AND '2022.0'
);

SELECT
	min(crash_date),
	max(crash_date)
FROM
	crash_timeline;

-- Results:

min                    |max                    |
-----------------------+-----------------------+
2017-01-01 00:01:00.000|2022-12-31 23:59:00.000|





















	
	
	
	
	
	
	
	
	
	
	
	

    








	

















