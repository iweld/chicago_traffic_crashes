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

    








	

















