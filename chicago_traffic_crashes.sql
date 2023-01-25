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


-- What is the count of crashes during different lighting conditions that resulted in a fatality?

SELECT
	lighting_condition,
	count(*)
FROM
	crash_timeline
WHERE
	injuries_fatal <> '0'
GROUP BY
	lighting_condition;

-- Results:

lighting_condition    |count|
----------------------+-----+
darkness, lighted road|  368|
unknown               |    6|
dawn                  |   13|
dusk                  |   23|
daylight              |  269|
darkness              |   42|

-- What are the different kinds of road conditions and crash count?

SELECT
	DISTINCT roadway_surface_condition,
	count(*) AS crash_count
FROM
	crash_timeline
GROUP BY
	roadway_surface_condition
ORDER BY
	crash_count DESC;

-- Results:

roadway_surface_condition|crash_count|
-------------------------+-----------+
dry                      |     468910|
wet                      |      83867|
unknown                  |      46949|
snow or slush            |      23511|
ice                      |       4553|
other                    |       1594|
sand, mud, dirt          |        250|

-- What is the max amount difference between crash date and the date it was reported?

SELECT
	first_crash_type,
	primary_cause,
	crash_date AS crash_date,
	date_police_notified,
	date_police_notified - crash_date AS date_difference
FROM
	crash_timeline
ORDER BY
	date_difference DESC
LIMIT 10;

-- Results:

first_crash_type    |primary_cause                      |crash_date             |date_police_notified   |date_difference  |
--------------------+-----------------------------------+-----------------------+-----------------------+-----------------+
pedestrian          |failing to yield right-of-way      |2017-12-17 22:59:00.000|2019-12-19 14:30:00.000|731 days 15:31:00|
rear end            |unable to determine                |2020-05-10 13:15:00.000|2022-05-11 11:00:00.000|730 days 21:45:00|
rear end            |unable to determine                |2020-10-30 20:00:00.000|2022-10-30 20:00:00.000|         730 days|
fixed object        |unable to determine                |2019-02-19 14:44:00.000|2021-01-21 14:50:00.000|702 days 00:06:00|
pedestrian          |exceeding safe speed for conditions|2017-04-10 15:30:00.000|2018-12-13 11:50:00.000|611 days 20:20:00|
fixed object        |road construction/maintenance      |2018-10-19 13:00:00.000|2020-03-07 19:15:00.000|505 days 06:15:00|
fixed object        |not applicable                     |2017-08-03 11:24:00.000|2018-12-14 20:01:00.000|498 days 08:37:00|
parked motor vehicle|unable to determine                |2018-11-13 01:00:00.000|2020-02-10 14:04:00.000|454 days 13:04:00|
rear end            |failing to yield right-of-way      |2020-09-22 16:30:00.000|2021-11-26 16:30:00.000|         430 days|
parked motor vehicle|improper backing                   |2021-07-15 19:00:00.000|2022-08-31 11:25:00.000|411 days 16:25:00|


-- What is the least amount of difference between crash date and the date it was reported?

SELECT
	first_crash_type,
	primary_cause,
	crash_date AS crash_date,
	date_police_notified,
	date_police_notified - crash_date AS date_difference
FROM
	crash_timeline
WHERE
	(date_police_notified - crash_date) > '00:00:00'
ORDER BY
	date_difference
LIMIT 10;

-- Results:

first_crash_type            |primary_cause                         |crash_date             |date_police_notified   |date_difference|
----------------------------+--------------------------------------+-----------------------+-----------------------+---------------+
fixed object                |not applicable                        |2021-01-01 02:29:00.000|2021-01-01 02:30:00.000|       00:01:00|
rear end                    |failing to reduce speed to avoid crash|2022-01-08 21:13:00.000|2022-01-08 21:14:00.000|       00:01:00|
rear end                    |unable to determine                   |2022-07-15 17:03:00.000|2022-07-15 17:04:00.000|       00:01:00|
rear end                    |equipment - vehicle condition         |2022-07-15 08:30:00.000|2022-07-15 08:31:00.000|       00:01:00|
parked motor vehicle        |unable to determine                   |2021-01-06 19:00:00.000|2021-01-06 19:01:00.000|       00:01:00|
sideswipe opposite direction|driving skills/knowledge/experience   |2022-07-15 16:09:00.000|2022-07-15 16:10:00.000|       00:01:00|
pedestrian                  |failing to yield right-of-way         |2022-10-11 18:45:00.000|2022-10-11 18:46:00.000|       00:01:00|
rear end                    |failing to reduce speed to avoid crash|2022-07-15 13:14:00.000|2022-07-15 13:15:00.000|       00:01:00|
pedestrian                  |driving skills/knowledge/experience   |2019-12-03 14:22:00.000|2019-12-03 14:23:00.000|       00:01:00|
angle                       |disregarding stop sign                |2022-04-27 06:57:00.000|2022-04-27 06:58:00.000|       00:01:00|

-- What is the average and median date difference?

SELECT
	 avg(date_police_notified - crash_date) AS avg_date_difference,
	 PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY (date_police_notified - crash_date)) AS median_date_diff
FROM
	crash_timeline
WHERE
	(date_police_notified - crash_date) > '00:00:00';

-- Results:

avg_date_difference|mean_date_diff|
-------------------+--------------+
    14:52:31.517892|      00:35:00|
    
-- What are the top 5 Crash Types?
    
WITH get_crash_type AS (    
	SELECT
		first_crash_type,
		count(*) AS crash_count,
		RANK() OVER (ORDER BY count(*) desc) AS rnk
	FROM
		crash_timeline
	GROUP BY
		first_crash_type
)
SELECT
	first_crash_type AS crash_type,
	crash_count
FROM
	get_crash_type
WHERE
	rnk <= 5;

-- Results:

crash_type              |crash_count|
------------------------+-----------+
parked motor vehicle    |     147481|
rear end                |     140314|
sideswipe same direction|      93799|
turning                 |      89882|
angle                   |      68282|

-- What are the top 5 Crash Types?
    
WITH get_primary_cause AS (    
	SELECT
		primary_cause,
		count(*) AS cause_count,
		RANK() OVER (ORDER BY count(*) desc) AS rnk
	FROM
		crash_timeline
	GROUP BY
		primary_cause
)
SELECT
	primary_cause,
	cause_count
FROM
	get_primary_cause
WHERE
	rnk <= 5;

-- Results:

primary_cause                |cause_count|
-----------------------------+-----------+
unable to determine          |     241832|
failing to yield right-of-way|      69545|
following too closely        |      61228|
not applicable               |      32773|
improper overtaking/passing  |      30107|

-- Explore workzone data

SELECT
	crash_date,
	work_zone,                  
	work_zone_type,              
	workers_present
FROM
	crash_timeline
WHERE
	work_zone IS NOT NULL
LIMIT 10;

-- Results:

crash_date             |work_zone|work_zone_type|workers_present|
-----------------------+---------+--------------+---------------+
2018-12-12 09:30:00.000|y        |construction  |y              |
2017-09-02 08:00:00.000|n        |              |               |
2019-02-02 18:02:00.000|y        |construction  |               |
2021-08-27 15:49:00.000|n        |              |               |
2019-07-19 10:56:00.000|y        |construction  |n              |
2022-07-30 01:12:00.000|n        |              |               |
2019-06-15 18:25:00.000|y        |construction  |               |
2022-07-16 13:10:00.000|y        |construction  |               |
2018-11-01 17:30:00.000|y        |construction  |y              |
2018-10-09 11:15:00.000|y        |construction  |n              |

-- Most dangerous hour

SELECT
	crash_hour,
	count(*) as hour_count
FROM
	crash_timeline
GROUP BY 
	crash_hour
ORDER BY
	hour_count desc;

-- Results:

crash_hour|hour_count|
----------+----------+
16        |     47964|
15        |     47800|
17        |     46679|
14        |     41977|
18        |     38546|
13        |     38240|
12        |     37316|
8         |     32694|
11        |     32221|
9         |     28892|
10        |     28799|
19        |     28627|
7         |     26186|
20        |     23190|
21        |     20769|
22        |     19077|
23        |     16612|
0         |     13914|
6         |     13717|
1         |     11811|
2         |     10129|
5         |      8803|
3         |      8278|
4         |      7393|

-- How many road defects caused crashes?

SELECT
	road_defect,
	count(*) AS defect_count
from
	crash_timeline
GROUP BY
	road_defect
ORDER BY 
	defect_count desc;

-- Results:

road_defect      |defect_count|
-----------------+------------+
no defects       |      515811|
unknown          |      101142|
rut, holes       |        4960|
other            |        3488|
worn surface     |        2511|
shoulder defect  |        1229|
debris on roadway|         493|

-- What types of damage?

SELECT
	damage,
	count(*) AS damage_count
FROM
	crash_timeline
GROUP BY
	damage;

-- Results:

damage       |damage_count|
-------------+------------+
$500 or less |       74095|
$501 - $1,500|      169453|
over $1,500  |      386086|

-- How many hit a pedestrian?

SELECT
	count(*) AS pedestrians_hit
FROM
	crash_timeline
WHERE
	first_crash_type = 'pedestrian';

-- Results:

pedestrians_hit|
---------------+
          15121|


    


    











	
	
	
	
	
	
	
	
	
	
	
	

    








	

















