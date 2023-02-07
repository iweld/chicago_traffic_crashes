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
	count(*) AS total_records
FROM
	crashes;
	
-- Results:

total_records|
-------------+
       686276|

-- What is the earliest and latest date of recorded crashes?

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
	EXTRACT(YEAR FROM crash_date)::numeric AS crash_year,
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
      2013|               2|
      2014|               6|
      2015|            9828|
      2016|           44297|
      2017|           83786|
      2018|          118950|
      2019|          117762|
      2020|           92088|
      2021|          108756|
      2022|          108292|
      2023|            2509|
    
-- 2017 appears to be the first year with the most complete data but there appears to be missing data.
-- Lets take a look at 2017 data and compare to 2018 data to see if we notice any major inconsistancies.

WITH get_2017 AS (
	SELECT
		EXTRACT(YEAR FROM crash_date) AS crash_year,
		crash_month::numeric,
		count(*) AS crash_count
	FROM
		crashes
	WHERE
		EXTRACT(YEAR FROM crash_date) = '2017.0'
	GROUP BY
		crash_year,
		crash_month
),
get_2018 AS (
	SELECT
		EXTRACT(YEAR FROM crash_date) AS crash_year,
		crash_month::numeric,
		count(*) AS crash_count
	FROM
		crashes
	WHERE
		EXTRACT(YEAR FROM crash_date) = '2018.0'
	GROUP BY
		crash_year,
		crash_month
),
get_count_diff AS (
	SELECT
		to_char(to_date(g17.crash_month::TEXT, 'MM'), 'Month') AS crash_month,
		g17.crash_count AS count_2017,
		g18.crash_count AS count_2018,
		g18.crash_count - g17.crash_count AS count_diff
	FROM
		get_2017 AS g17
	JOIN
		get_2018 AS g18
	ON g17.crash_month = g18.crash_month
	ORDER BY
		g17.crash_month::NUMERIC
)
SELECT
	crash_month,
	count_2017,
	count_2018,
	count_diff,
	CASE
		WHEN count_diff >= (count_2018 * .5) THEN 'Over 50% Difference'
		WHEN count_diff >= (count_2018 * .4) THEN 'Over 40% Difference'
		WHEN count_diff >= (count_2018 * .3) THEN 'Over 30% Difference'
		WHEN count_diff >= (count_2018 * .2) THEN 'Over 20% Difference'
		ELSE 'No Significant Difference'
	END AS difference_percentage_range
FROM
	get_count_diff;
	
-- Results:

crash_month|count_2017|count_2018|count_diff|difference_percentage_range|
-----------+----------+----------+----------+---------------------------+
January    |      4363|      9532|      5169|Over 50% Difference        |
February   |      4109|      8729|      4620|Over 50% Difference        |
March      |      5105|      9319|      4214|Over 40% Difference        |
April      |      5024|      9648|      4624|Over 40% Difference        |
May        |      5847|     10714|      4867|Over 40% Difference        |
June       |      6212|     10601|      4389|Over 40% Difference        |
July       |      6758|     10367|      3609|Over 30% Difference        |
August     |      7685|     10212|      2527|Over 20% Difference        |
September  |      9038|      9931|       893|No Significant Difference  |
October    |     10022|     10402|       380|No Significant Difference  |
November   |      9515|      9474|       -41|No Significant Difference  |
December   |     10108|     10021|       -87|No Significant Difference  |

-- After a simple analysis we can conclude that the early 2017 data is incomplete and not going to be used in our analysis.
-- Create a temp table with recorded crashes between 2018 and 2022 and check the record dates.
    
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

-- What are the different kinds of road conditions and the number of crashes?

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

-- What is the crash_type and max amount difference between crash date and the date it was reported?

SELECT
	first_crash_type,
	crash_date - date_police_notified AS date_diff
FROM
	crash_timeline
ORDER BY
	date_diff
LIMIT 10;

-- Results:

first_crash_type    |date_diff          |
--------------------+-------------------+
rear end            |-730 days -21:45:00|
rear end            |          -730 days|
fixed object        |-702 days -00:06:00|
fixed object        |-505 days -06:15:00|
parked motor vehicle|-454 days -13:04:00|
rear end            |          -430 days|
parked motor vehicle|-411 days -16:25:00|
fixed object        |-409 days -07:40:00|
fixed object        |-374 days -01:45:00|
rear end            |-370 days -19:44:00|

-- What is the average and median date difference between crash date and police report date?

SELECT
	 avg(date_police_notified - crash_date) AS avg_date_difference,
	 PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY (date_police_notified - crash_date)) AS median_date_difference
FROM
	crash_timeline
WHERE
	(date_police_notified - crash_date) > '00:00:00';

-- Results:

avg_date_difference|median_date_difference|
-------------------+----------------------+
    14:33:38.825155|              00:35:00|
    
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

-- What is the frequency of crashes relative to the time of day and what is the hour per hour percentage change?

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
	to_char(to_timestamp(crash_hour, 'HH24'), 'HH AM') AS hour_of_day,
	hour_count,
	round(100 * ((hour_count * 1.0) / (SELECT count(*) FROM crash_timeline)), 1) AS avg_of_total,
	round(100 * (hour_count - LAG(hour_count) OVER ()) / LAG(hour_count) OVER()::NUMERIC, 2) AS hour_to_hour 
FROM
	most_dangerous_hour;

-- Results:

hour_of_day|hour_count|avg_of_total|hour_to_hour|
-----------+----------+------------+------------+
12 AM      |     12368|         2.3|            |
01 AM      |     10490|         1.9|      -15.18|
02 AM      |      8934|         1.6|      -14.83|
03 AM      |      7354|         1.3|      -17.69|
04 AM      |      6543|         1.2|      -11.03|
05 AM      |      7685|         1.4|       17.45|
06 AM      |     11778|         2.2|       53.26|
07 AM      |     22233|         4.1|       88.77|
08 AM      |     27969|         5.1|       25.80|
09 AM      |     24783|         4.5|      -11.39|
10 AM      |     24928|         4.6|        0.59|
11 AM      |     28023|         5.1|       12.42|
12 PM      |     32337|         5.9|       15.39|
01 PM      |     33064|         6.1|        2.25|
02 PM      |     36388|         6.7|       10.05|
03 PM      |     41462|         7.6|       13.94|
04 PM      |     41479|         7.6|        0.04|
05 PM      |     40324|         7.4|       -2.78|
06 PM      |     33211|         6.1|      -17.64|
07 PM      |     24833|         4.5|      -25.23|
08 PM      |     20342|         3.7|      -18.08|
09 PM      |     18100|         3.3|      -11.02|
10 PM      |     16598|         3.0|       -8.30|
11 PM      |     14622|         2.7|      -11.91|

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
	all_road_defects;
	

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
unable to determine          |     211228|
failing to yield right-of-way|      59735|
following too closely        |      51273|
not applicable               |      28703|
improper overtaking/passing  |      26162|

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

WITH get_fatality_rank AS (
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
	get_fatality_rank AS g1
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

-- What is the number of fatalities what days of the week did they occur?

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
	fatality_count DESC;

-- Results:

crash_day_of_week|fatality_count|
-----------------+--------------+
sunday           |           119|
saturday         |           103|
thursday         |           100|
wednesday        |            93|
monday           |            86|
friday           |            84|
tuesday          |            58|

-- What was the ranking of the deadliest years in our recordset?

SELECT
	EXTRACT(YEAR FROM crash_date)::numeric AS crash_year,
	count(*) AS fatality_count,
	RANK() OVER (ORDER BY count(*) desc) AS year_rank
FROM
	crash_timeline
WHERE
	injuries_fatal <> '0'
GROUP BY
	crash_year
ORDER BY
	fatality_count DESC;

-- Results:

crash_year|fatality_count|year_rank|
----------+--------------+---------+
      2021|           156|        1|
      2022|           137|        2|
      2020|           134|        3|
      2018|           114|        4|
      2019|           102|        5|

-- What month has the most amount of fatal crashes?

SELECT
	to_char(to_date(crash_month::TEXT, 'MM'), 'Month') AS crash_month,
	count(*) AS fatality_count
FROM
	crash_timeline
WHERE
	injuries_fatal <> '0'
GROUP BY
	crash_month
ORDER BY
	fatality_count DESC;

-- Results:

crash_month|fatality_count|
-----------+--------------+
July       |            81|
September  |            67|
August     |            65|
December   |            57|
October    |            57|
June       |            55|
May        |            54|
January    |            46|
November   |            46|
April      |            43|
March      |            39|
February   |            33|

-- What single day has the most amount of fatal crashes?

SELECT
	crash_date::date,
	count(*) AS fatality_count,
	RANK() OVER (ORDER BY count(*) desc) AS date_rank
FROM
	crash_timeline
WHERE
	injuries_fatal <> '0'
GROUP BY
	crash_date::date
ORDER BY
	fatality_count DESC
LIMIT 10;

-- Results:

crash_date|fatality_count|date_rank|
----------+--------------+---------+
2022-07-04|             4|        1|
2021-06-20|             3|        2|
2022-01-15|             3|        2|
2021-05-26|             3|        2|
2021-03-25|             3|        2|
2020-07-19|             3|        2|
2020-09-06|             3|        2|
2020-12-02|             3|        2|
2020-10-19|             3|        2|
2019-11-21|             3|        2|

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






