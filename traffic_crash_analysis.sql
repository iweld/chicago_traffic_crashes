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
	crash_date,
	date_police_notified,
	crash_date - date_police_notified AS date_diff
FROM
	crash_timeline
ORDER BY
	date_diff
LIMIT 10;

-- Results:

first_crash_type    |primary_cause                    |crash_date             |date_police_notified   |date_diff          |
--------------------+---------------------------------+-----------------------+-----------------------+-------------------+
rear end            |unable to determine              |2020-05-10 13:15:00.000|2022-05-11 11:00:00.000|-730 days -21:45:00|
rear end            |unable to determine              |2020-10-30 20:00:00.000|2022-10-30 20:00:00.000|          -730 days|
fixed object        |unable to determine              |2019-02-19 14:44:00.000|2021-01-21 14:50:00.000|-702 days -00:06:00|
fixed object        |road construction/maintenance    |2018-10-19 13:00:00.000|2020-03-07 19:15:00.000|-505 days -06:15:00|
parked motor vehicle|unable to determine              |2018-11-13 01:00:00.000|2020-02-10 14:04:00.000|-454 days -13:04:00|
rear end            |failing to yield right-of-way    |2020-09-22 16:30:00.000|2021-11-26 16:30:00.000|          -430 days|
parked motor vehicle|improper backing                 |2021-07-15 19:00:00.000|2022-08-31 11:25:00.000|-411 days -16:25:00|
fixed object        |road construction/maintenance    |2019-01-23 10:30:00.000|2020-03-07 18:10:00.000|-409 days -07:40:00|
fixed object        |unable to determine              |2018-01-29 18:30:00.000|2019-02-07 20:15:00.000|-374 days -01:45:00|
rear end            |distraction - from inside vehicle|2018-04-28 16:46:00.000|2019-05-04 12:30:00.000|-370 days -19:44:00|

