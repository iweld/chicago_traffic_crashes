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











