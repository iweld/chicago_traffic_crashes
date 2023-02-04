# Chicago Traffic Crashes 2018-2022
## Questions and Answers
**Author**: Jaime M. Shaker
**Email**: jaime.m.shaker@gmail.com
**Website**: https://www.shaker.dev
**LinkedIn**: https://www.linkedin.com/in/jaime-shaker/

An SQL analysis about each traffic crash on city streets within the City of Chicago limits and under the jurisdiction of Chicago Police Department (CPD). Data shown as is from the electronic crash reporting system (E-Crash) at CPD, excluding any personally identifiable information.


#### What is the total count of recorded crashes in the complete dataset?

````sql
SELECT
	count(*) AS total_records
FROM
	crashes;
````

**Results:**

total_records|
-------------|
686276|

#### What is the earliest and latest date of recorded crashes?

````sql
SELECT 
	min(crash_date) AS earliest_date,
	max(crash_date) AS latest_date
FROM	
	crashes;
````

**Results:**

earliest_date          |latest_date            |
-----------------------|-----------------------|
2013-03-03 16:48:00.000|2023-01-12 23:36:00.000|

#### What is the number of reported crashes per year?

````sql
SELECT
	EXTRACT(YEAR FROM crash_date)::numeric AS crash_year,
	count(*) AS reported_crashes
FROM
	crashes
GROUP BY
	crash_year
ORDER BY 
	crash_year;
````

**Results:**

crash_year|reported_crashes|
----------|----------------|
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


##### 2017 appears to be the first year with the most complete data but there appears to be missing data.  Lets take a look at 2017 data and compare to 2018 data to see if we notice any major inconsistancies.

````sql
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
)
SELECT
	DISTINCT g17.crash_month,
	g17.crash_count AS "2017_count",
	g18.crash_count AS "2018_count"
FROM
	get_2017 AS g17
JOIN
	get_2018 AS g18
ON g17.crash_month = g18.crash_month
ORDER BY
	g17.crash_month::NUMERIC 
````

**Results:**

crash_month|2017_count|2018_count|
-----------|----------|----------|
1|      4363|      9532|
2|      4109|      8729|
3|      5105|      9319|
4|      5024|      9648|
5|      5847|     10714|
6|      6212|     10601|
7|      6758|     10367|
8|      7685|     10212|
9|      9038|      9931|
10|     10022|     10402|
11|      9515|      9474|
12|     10108|     10021|

##### After a simple analysis we can conclude that the early 2017 data is incomplete and not going to be used in our analysis.

#### Create a temp table with recorded crashes between 2018 and 2022.

````sql
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
````

**Results:**

min_date               |max_date               |
-----------------------|-----------------------|
2018-01-01 00:00:00.000|2022-12-31 23:59:00.000|

#### What month had the most crimes reported?

````sql
SELECT
	to_char(CRIME_DATE::timestamp, 'Month') AS month,
	COUNT(*) AS n_crimes
FROM
	chicago_crimes
GROUP BY
	month
ORDER BY
	n_crimes DESC;
````

**Results:**

month    |n_crimes|
---------|--------|
October  |   19018|
September|   18987|
July     |   18966|
June     |   18566|
August   |   18255|
May      |   17539|
November |   16974|
January  |   16038|
March    |   15742|
April    |   15305|
December |   14258|
February |   12888|

![Highest monthly crimes reported Chart](https://github.com/iweld/chicago_crime_and_weather_2021/blob/main/img/line_mild_to_cold.PNG)

#### What month had the most homicides and what was the average and median temperature?

````sql
SELECT
	to_char(CRIME_DATE::timestamp, 'Month') AS month,
	COUNT(*) AS n_homicides,
	round(avg(temp_high), 1) AS avg_high_temp,
	percentile_cont(0.5) WITHIN group(ORDER BY temp_high) AS median_temp
FROM
	chicago_crimes
WHERE crime_type = 'homicide'
GROUP BY
	month
ORDER BY
	n_homicides DESC;
````

**Results:**

month    |n_homicides|avg_high_temp|median_temp|
---------|-----------|-------------|-----------|
July     |        112|         82.6|       82.0|
September|         89|         80.8|       82.0|
June     |         85|         83.5|       82.0|
August   |         81|         85.3|       85.0|
May      |         66|         73.9|       75.5|
October  |         64|         67.9|       71.0|
November |         62|         50.6|       51.0|
January  |         55|         34.1|       34.0|
April    |         54|         65.1|       62.0|
December |         52|         48.6|       49.0|
March    |         45|         54.7|       52.0|
February |         38|         27.0|       26.0|

![Monthly Homicide Bar Chart](https://github.com/iweld/chicago_crime_and_weather_2021/blob/main/img/bar_monthly_homicide.PNG)

#### What weekday were most crimes committed?

````sql
SELECT
	to_char(CRIME_DATE::timestamp, 'Day') AS day_of_week,
	COUNT(*) AS n_crimes
FROM
	chicago_crimes
GROUP BY
	day_of_week
ORDER BY
	n_crimes DESC;
````

**Results:**

day_of_week|n_crimes|
-----------|--------|
Saturday   |   29841|
Friday     |   29829|
Sunday     |   29569|
Monday     |   29194|
Wednesday  |   28143|
Tuesday    |   28135|
Thursday   |   27825|

![Day of the Week totals Bar Chart](https://github.com/iweld/chicago_crime_and_weather_2021/blob/main/img/bar_day_of_week_totals.PNG)

#### What are the top ten city streets that have had the most reported crimes?

````sql
SELECT
	street_name,
	count(*) AS n_crimes
FROM
	chicago_crimes
GROUP BY
	street_name
ORDER BY
	count(*) DESC
LIMIT 10;
````

**Results:**

street_name                 |n_crimes|
----------------------------|--------|
 michigan ave               |    3257|
 state st                   |    2858|
 halsted st                 |    2329|
 ashland ave                |    2276|
 clark st                   |    2036|
 western ave                |    1987|
 dr martin luther king jr dr|    1814|
 pulaski rd                 |    1686|
 kedzie ave                 |    1606|
 madison st                 |    1584|

#### What are the top ten city streets that have had the most homicides including ties?

````sql
 SELECT
 	street_name,
 	n_homicides
 from
	(SELECT
		street_name,
		count(*) AS n_homicides,
		rank() OVER (ORDER BY count(*) DESC) AS rnk
	FROM
		chicago_crimes
	WHERE
		crime_type = 'homicide'
	GROUP BY
		street_name
	ORDER BY
		count(*) DESC) AS tmp
WHERE 
	rnk <= 10;
````

**Results:**

street_name                 |n_homicides|
----------------------------|-----------|
 79th st                    |         14|
 madison st                 |         14|
 morgan st                  |         10|
 71st st                    |         10|
 michigan ave               |          9|
 cottage grove ave          |          9|
 van buren st               |          8|
 cicero ave                 |          7|
 dr martin luther king jr dr|          7|
 pulaski rd                 |          7|
 state st                   |          7|
 emerald ave                |          7|
 polk st                    |          7|

#### What are the top ten city streets that have had the most burglaries?

````sql
SELECT
	street_name,
	count(*) AS n_burglaries
FROM
	chicago_crimes
WHERE
	crime_type = 'burglary'
group BY
	street_name
ORDER BY
	n_burglaries DESC
LIMIT 10;
````

**Results:**

street_name                 |n_burglaries|
----------------------------|------------|
 ashland ave                |         104|
 halsted st                 |         103|
 michigan ave               |          92|
 western ave                |          79|
 kedzie ave                 |          67|
 north ave                  |          62|
 chicago ave                |          50|
 dr martin luther king jr dr|          50|
 79th st                    |          48|
 sheridan rd                |          45|


#### What was the number of reported crimes on the hottest day of the year vs the coldest?

````sql
WITH hottest AS (
	SELECT
	  	temp_high,
	 	count(*) AS n_crimes
	FROM
	 	chicago_crimes
	WHERE
	 	temp_high = (SELECT max(temp_high) FROM chicago_crimes)
	GROUP BY temp_high
),
coldest AS (
	SELECT
	  	temp_high,
	 	count(*) AS n_crimes
	FROM
	 	chicago_crimes
	WHERE
	 	temp_high = (SELECT min(temp_high) FROM chicago_crimes)
	GROUP BY temp_high
)

SELECT
	h.temp_high,
	h.n_crimes
FROM 
	hottest AS h
UNION
SELECT
	c.temp_high,
	c.n_crimes
FROM 
	coldest AS c;
````

**Results:**

temp_high|n_crimes|
---------|--------|
95|     552|
4|     402|

![Hottest vs Coldest Day Bar Chart](https://github.com/iweld/chicago_crime_and_weather_2021/blob/main/img/bar_hot_vs_cold.PNG)

#### What is the number and types of reported crimes on Michigan Ave (The Rodeo Drive of the Midwest)?

````sql
SELECT
	crime_type,
	count(*) AS michigan_ave_crimes
FROM 
	chicago_crimes
WHERE 
	street_name like '%michigan ave%'
GROUP BY 
	crime_type
ORDER BY 
	michigan_ave_crimes desc;
````

**Results:**

crime_type                       |michigan_ave_crimes|
---------------------------------|-------------------|
theft                            |                923|
battery                          |                564|
assault                          |                324|
deceptive practice               |                317|
criminal damage                  |                269|
motor vehicle theft              |                212|
other offense                    |                172|
weapons violation                |                106|
robbery                          |                106|
burglary                         |                 92|
criminal trespass                |                 53|
criminal sexual assault          |                 30|
offense involving children       |                 22|
narcotics                        |                 16|
public peace violation           |                 14|
sex offense                      |                 10|
homicide                         |                  9|
liquor law violation             |                  8|
stalking                         |                  5|
interference with public officer |                  5|
obscenity                        |                  1|
arson                            |                  1|
intimidation                     |                  1|
concealed carry license violation|                  1|

#### What are the top 5 least reported crime, how many arrests were made and the percentage of arrests made?

````sql
SELECT
	crime_type,
	least_amount,
	arrest_count,
	round(100 * (arrest_count::float / least_amount)) AS arrest_percentage
from
	(SELECT
		crime_type,
		count(*) AS least_amount,
		sum(CASE
			WHEN arrest = 'true' THEN 1
			ELSE 0
		END) AS arrest_count
	FROM chicago_crimes
	GROUP BY 
		crime_type
	ORDER BY least_amount
	LIMIT 5) AS tmp;
````

**Results:**

crime_type              |least_amount|arrest_count|arrest_percentage|
------------------------|------------|------------|-----------------|
other narcotic violation|           2|           1|             50.0|
non-criminal            |           4|           1|             25.0|
public indecency        |           4|           4|            100.0|
human trafficking       |          12|           0|              0.0|
gambling                |          13|          11|             85.0|

#### What is the percentage of domestic violence crimes?

````sql
SELECT
	100 - n_domestic_perc AS non_domestic_violence,
	n_domestic_perc AS domestic_violence
from
	(SELECT
		round(100 * (SELECT count(*) FROM chicago_crimes WHERE domestic = true)::numeric / count(*), 2) AS n_domestic_perc
	FROM 
		chicago_crimes) AS tmp
````

**Results:**

non_domestic_violence|domestic_violence|
---------------------|-----------------|
78.20|            21.80|

![Domestic Violence Percdentage Bar Chart](https://github.com/iweld/chicago_crime_and_weather_2021/blob/main/img/bar_domestic_violence.PNG)



#### Display how many crimes were reported on a monthly basis in chronological order.  What is the month to month percentage change of crimes reported?

````sql
SELECT
	crime_month,
	n_crimes,
	round(100 * (n_crimes - LAG(n_crimes) over()) / LAG(n_crimes) over()::numeric, 2) AS month_to_month
FROM
	(SELECT
		to_char(crime_date, 'Month') AS crime_month,
		count(*) AS n_crimes
	FROM 
		chicago_crimes
	GROUP BY 
		crime_month
	ORDER BY
		to_date(to_char(crime_date, 'Month'), 'Month')) AS tmp
````

**Results:**

crime_month|n_crimes|month_to_month|
-----------|--------|--------------|
January    |   16038|              |
February   |   12888|        -19.64|
March      |   15742|         22.14|
April      |   15305|         -2.78|
May        |   17539|         14.60|
June       |   18566|          5.86|
July       |   18966|          2.15|
August     |   18255|         -3.75|
September  |   18987|          4.01|
October    |   19018|          0.16|
November   |   16974|        -10.75|
December   |   14258|        -16.00|

#### Display the most consecutive days where a homicide occured and the timeframe.

````sql
WITH get_all_dates AS (
	-- Get only one date per homicide
	SELECT DISTINCT ON (crime_date::date)
		crime_date::date AS c_date
	FROM
		chicago_crimes
	WHERE
		crime_type = 'homicide'
),
get_diff AS (
	SELECT 
		c_date,
		row_number() OVER () AS rn,
		c_date - row_number() OVER ()::int AS diff
	from
		get_all_dates
),
get_diff_count AS (
	SELECT
		c_date,
		count(*) over(PARTITION BY diff) AS diff_count
	from
		get_diff
	GROUP BY
		c_date,
		diff
)
SELECT
	max(diff_count) AS most_consecutive_days,
	min(c_date) || ' to ' || max(c_date) AS time_frame
from
	get_diff_count
WHERE diff_count > 40;
````

**Results:**

most_consecutive_days|time_frame              |
---------------------|------------------------|
43|2021-06-17 to 2021-07-29|

#### What are the top 10 most common locations for reported crimes and their frequency depending on the season?

````sql
SELECT
	location_description,
	count(*) AS location_description_count,
	sum(
		CASE
			WHEN crime_date::date >= '2021-04-15' AND crime_date::date <= '2021-10-15' THEN 1
			ELSE 0
		END) AS mild_weather,
	sum(
		CASE
			WHEN crime_date::date >= '2021-01-01' AND crime_date::date < '2021-04-15' THEN 1
			WHEN crime_date::date > '2021-10-15' AND crime_date::date <= '2021-12-31' THEN 1
			ELSE 0
		END) AS cold_weather
FROM
	chicago_crimes
WHERE
	location_description IS NOT NULL
GROUP BY
	location_description
ORDER BY 
	location_description_count DESC
LIMIT 10;
````

**Results:**

location_description                  |location_description_count|mild_weather|cold_weather|
--------------------------------------|--------------------------|------------|------------|
street                                |                     51310|       28308|       23002|
apartment                             |                     43253|       22823|       20430|
residence                             |                     31081|       15923|       15158|
sidewalk                              |                     11687|        7083|        4604|
parking lot / garage (non residential)|                      6324|        3497|        2827|
small retail store                    |                      5300|        2773|        2527|
alley                                 |                      4694|        2647|        2047|
restaurant                            |                      3650|        2025|        1625|
residence - porch / hallway           |                      2932|        1500|        1432|
gas station                           |                      2921|        1562|        1359|

#### What is the Month, day of the week and the number of homicides that occured in a babershop or beauty salon?

````sql
SELECT
	DISTINCT location_description,
	crime_type,
	to_char(crime_date, 'Month') AS crime_month,
	to_char(crime_date, 'Day') AS crime_day,
	count(*) AS incident_count
FROM
	chicago_crimes
WHERE
	location_description LIKE '%barber%'
AND 
	crime_type = 'homicide'
GROUP BY 
	location_description,
	crime_month,
	crime_day,
	crime_type
ORDER BY
	incident_count DESC;
````

**Results:**

location_description    |crime_type|crime_month|crime_day|incident_count|
------------------------|----------|-----------|---------|--------------|
barber shop/beauty salon|homicide  |July       |Wednesday|             2|
barber shop/beauty salon|homicide  |November   |Tuesday  |             2|
barber shop/beauty salon|homicide  |April      |Friday   |             1|
barber shop/beauty salon|homicide  |August     |Sunday   |             1|
barber shop/beauty salon|homicide  |January    |Thursday |             1|













