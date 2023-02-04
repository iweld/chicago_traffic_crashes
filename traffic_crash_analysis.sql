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

-- What is the total count of recorded crashes in the dataset?

SELECT
	count(*) AS record_count
FROM
	crashes;
	
-- Results:

record_count|
------------+
      686276|

-- What is the earliest and latest date?

SELECT 
	min(crash_date) AS earliest_date,
	max(crash_date) AS latest_date
FROM	
	crashes;

-- Results:

earliest_date          |latest_date            |
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
    
-- 2017 appears to be the first year with the most complete data but there appears to be missing data.
-- Lets take a look at 2017 data to see if we notice anything wrong.
    
SELECT
	EXTRACT(YEAR FROM crash_date) AS crash_year,
	crash_month,
	count(*)
FROM
	crashes
WHERE
	EXTRACT(YEAR FROM crash_date) = '2017.0'
OR
	EXTRACT(YEAR FROM crash_date) = '2018.0'
GROUP BY
	crash_year,
	crash_month
ORDER BY
	crash_month;

-- Results:

crash_year|crash_month|count|
----------+-----------+-----+
    2017.0|1          | 4363|
    2018.0|1          | 9532|
    2017.0|10         |10022|
    2018.0|10         |10402|
    2017.0|11         | 9515|
    2018.0|11         | 9474|
    2017.0|12         |10108|
    2018.0|12         |10021|
    2017.0|2          | 4109|
    2018.0|2          | 8729|
    2017.0|3          | 5105|
    2018.0|3          | 9319|
    2017.0|4          | 5024|
    2018.0|4          | 9648|
    2017.0|5          | 5847|
    2018.0|5          |10714|
    2017.0|6          | 6212|
    2018.0|6          |10601|
    2017.0|7          | 6758|
    2018.0|7          |10367|
    2017.0|8          | 7685|
    2018.0|8          |10212|
    2017.0|9          | 9038|
    2018.0|9          | 9931|

-- After a simple we can conclude that 2017 is incomplete and not going to be used in our analysis.
-- Create a temp table with only crashes betweeon 2017 and 2022
    
DROP TABLE IF EXISTS crash_timeline;
CREATE TEMP TABLE crash_timeline AS
(
	SELECT
		*
	FROM
		crashes
	WHERE
		EXTRACT(YEAR FROM crash_date) between '2018.0' AND '2022.0'
);

SELECT
	min(crash_date) AS min_date,
	max(crash_date) AS max_date
FROM
	crash_timeline;

-- Results:

min_date               |max_date               |
-----------------------+-----------------------+
2018-01-01 00:00:00.000|2022-12-31 23:59:00.000|

-- What is the total count of records in the Temp table?

SELECT
	count(*) AS record_count
FROM
	crash_timeline;
	
-- Results:

record_count|
------------+
      545848|
      
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

-- What are the different types of lighting conditions and the number of crashes?

SELECT
	DISTINCT lighting_condition,
	count(*) AS crash_count
FROM
	crash_timeline
GROUP BY
	lighting_condition
ORDER BY
	crash_count desc;

-- Results:

lighting_condition    |crash_count|
----------------------+-----------+
daylight              |     350241|
darkness, lighted road|     122916|
darkness              |      25282|
unknown               |      22509|
dusk                  |      15600|
dawn                  |       9300|

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
dry                      |     403694|
wet                      |      72751|
unknown                  |      42152|
snow or slush            |      21557|
ice                      |       4060|
other                    |       1433|
sand, mud, dirt          |        201|

-- What is the max amount difference between crash date and the date it was reported?

SELECT
	first_crash_type,
	primary_cause,
	lighting_condition,
	roadway_surface_condition,
	crash_date - date_police_notified AS date_diff
FROM
	crash_timeline
ORDER BY
	date_diff
LIMIT 10;

-- Results:

first_crash_type    |primary_cause                    |lighting_condition    |roadway_surface_condition|date_diff          |
--------------------+---------------------------------+----------------------+-------------------------+-------------------+
rear end            |unable to determine              |daylight              |dry                      |-730 days -21:45:00|
rear end            |unable to determine              |daylight              |unknown                  |          -730 days|
fixed object        |unable to determine              |daylight              |dry                      |-702 days -00:06:00|
fixed object        |road construction/maintenance    |daylight              |wet                      |-505 days -06:15:00|
parked motor vehicle|unable to determine              |darkness, lighted road|dry                      |-454 days -13:04:00|
rear end            |failing to yield right-of-way    |daylight              |dry                      |          -430 days|
parked motor vehicle|improper backing                 |daylight              |dry                      |-411 days -16:25:00|
fixed object        |road construction/maintenance    |daylight              |wet                      |-409 days -07:40:00|
fixed object        |unable to determine              |darkness, lighted road|wet                      |-374 days -01:45:00|
rear end            |distraction - from inside vehicle|daylight              |dry                      |-370 days -19:44:00|

-- What is the average and median date difference?

SELECT
	 avg(date_police_notified - crash_date) AS avg_date_difference,
	 PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY (date_police_notified - crash_date)) AS median_date_diff
FROM
	crash_timeline
WHERE
	(date_police_notified - crash_date) > '00:00:00';

-- Results:

avg_date_difference|median_date_diff|
-------------------+----------------+
    14:33:38.825155|        00:35:00|
    
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
parked motor vehicle    |     128858|
rear end                |     118761|
sideswipe same direction|      80109|
turning                 |      78399|
angle                   |      59406|

-- Most dangerous hour

WITH most_dangerous_hour AS (
	SELECT
		crash_hour,
		count(*) as hour_count
	FROM
		crash_timeline
	GROUP BY 
		crash_hour
	ORDER BY
		crash_hour::int ASC
)
SELECT
	crash_hour,
	hour_count,
	round(100 * ((hour_count * 1.0) / (SELECT count(*) FROM crash_timeline)), 1) AS avg_of_total
FROM
	most_dangerous_hour;

-- Results:

crash_hour|hour_count|avg_of_total|
----------+----------+------------+
0         |     12368|         2.3|
1         |     10490|         1.9|
2         |      8934|         1.6|
3         |      7354|         1.3|
4         |      6543|         1.2|
5         |      7685|         1.4|
6         |     11778|         2.2|
7         |     22233|         4.1|
8         |     27969|         5.1|
9         |     24783|         4.5|
10        |     24928|         4.6|
11        |     28023|         5.1|
12        |     32337|         5.9|
13        |     33064|         6.1|
14        |     36388|         6.7|
15        |     41462|         7.6|
16        |     41479|         7.6|
17        |     40324|         7.4|
18        |     33211|         6.1|
19        |     24833|         4.5|
20        |     20342|         3.7|
21        |     18100|         3.3|
22        |     16598|         3.0|
23        |     14622|         2.7|

-- How many road defects caused crashes?

WITH all_road_defects AS (
	SELECT
		road_defect,
		count(*) AS defect_count
	from
		crash_timeline
	GROUP BY
		road_defect
	ORDER BY 
		defect_count DESC
)
SELECT
	road_defect,
	defect_count,
	round(100 * ((defect_count * 1.0) / (SELECT count(*) FROM crash_timeline)), 1) AS avg_of_total
FROM
	all_road_defects
	

-- Results:

road_defect      |defect_count|avg_of_total|
-----------------+------------+------------+
no defects       |      445069|        81.5|
unknown          |       89942|        16.5|
rut, holes       |        4219|         0.8|
other            |        3036|         0.6|
worn surface     |        2154|         0.4|
shoulder defect  |        1009|         0.2|
debris on roadway|         419|         0.1|

-- What is the average count per day of the week?

WITH weekday_crash AS (
	SELECT
		crash_day_of_week,
		count(*) AS day_count
	FROM
		crash_timeline
	GROUP BY
		crash_day_of_week
	ORDER BY
		day_count DESC
),
get_fatalities AS (
	SELECT
		crash_day_of_week,
		count(*) AS fatality_count
	FROM
		crash_timeline
	WHERE
		injuries_fatal <> '0'
	GROUP BY
		crash_day_of_week
	ORDER BY
		fatality_count DESC
)
SELECT
	wc.crash_day_of_week,
	wc.day_count,
	gf.fatality_count,
	round(100 * ((wc.day_count * 1.0) / (SELECT count(*) FROM crash_timeline)), 1) AS avg_of_total,
	round(100 * ((gf.fatality_count * 1.0) / (SELECT count(*) FROM crash_timeline)), 3) AS avg_of_fatalities
FROM
	weekday_crash AS wc
LEFT JOIN 
	get_fatalities AS gf
ON wc.crash_day_of_week = gf.crash_day_of_week;

-- Results:

crash_day_of_week|day_count|fatality_count|avg_of_total|avg_of_fatalities|
-----------------+---------+--------------+------------+-----------------+
friday           |    88742|            84|        16.3|            0.015|
saturday         |    81323|           103|        14.9|            0.019|
thursday         |    78138|           100|        14.3|            0.018|
tuesday          |    77316|            58|        14.2|            0.011|
wednesday        |    76740|            93|        14.1|            0.017|
monday           |    75375|            86|        13.8|            0.016|
sunday           |    68214|           119|        12.5|            0.022|

-- What are the top 10 deadliest streets?

SELECT
	street_name,
	count(*) AS street_count
FROM
	crash_timeline
WHERE
	injuries_fatal <> '0'
GROUP BY
	street_name
ORDER BY
	street_count DESC
LIMIT 10;

-- Results:

street_name     |street_count|
----------------+------------+
Cicero Ave      |          23|
Ashland Ave     |          21|
Western Ave     |          20|
Pulaski Rd      |          19|
Halsted St      |          17|
Archer Ave      |          14|
Lake Shore Dr Nb|          14|
Kedzie Ave      |          12|
Lake Shore Dr Sb|          12|
Stony Island Ave|          12|

-- Use rank function to rank crash type for crashes which had a fatality.

WITH get_same_rank AS (
	SELECT
		first_crash_type,
		count(*) AS fatality_count,
		DENSE_RANK() OVER (ORDER BY count(*) desc) AS rnk
	FROM
		crash_timeline
	WHERE
		injuries_fatal <> '0'
	GROUP BY 
		first_crash_type
)
SELECT
	g1.first_crash_type,
	g1.fatality_count
FROM
	get_same_rank AS g1
ORDER BY
	g1.rnk;

-- Results:

first_crash_type            |fatality_count|
----------------------------+--------------+
pedestrian                  |           164|
fixed object                |           155|
angle                       |            74|
parked motor vehicle        |            69|
turning                     |            51|
head on                     |            31|
pedalcyclist                |            26|
rear end                    |            26|
sideswipe same direction    |            17|
other object                |            13|
other noncollision          |             4|
sideswipe opposite direction|             4|
animal                      |             4|
overturned                  |             2|
rear to front               |             2|
train                       |             1|

-- Explore workzone data

SELECT
	crash_date,
	work_zone,                  
	work_zone_type,              
	workers_present,
	injuries_total
FROM
	crash_timeline
WHERE
	work_zone IS NOT NULL
AND
	work_zone = 'y'
AND
	injuries_total::int > 1
ORDER BY
	injuries_total::int DESC
LIMIT 10;

-- Results:

crash_date             |work_zone|work_zone_type|workers_present|injuries_total|
-----------------------+---------+--------------+---------------+--------------+
2018-09-04 02:25:00.000|y        |construction  |               |7             |
2019-05-03 07:13:00.000|y        |construction  |y              |6             |
2021-12-14 07:55:00.000|y        |construction  |y              |6             |
2022-07-21 15:50:00.000|y        |unknown       |n              |5             |
2020-01-27 13:15:00.000|y        |construction  |               |5             |
2018-05-31 15:17:00.000|y        |construction  |               |5             |
2020-11-15 16:20:00.000|y        |utility       |y              |5             |
2019-08-18 13:30:00.000|y        |construction  |               |4             |
2018-03-26 07:35:00.000|y        |construction  |               |4             |
2021-06-14 15:00:00.000|y        |construction  |               |4             |


