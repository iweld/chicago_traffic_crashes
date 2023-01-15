/*
	Chicago Traffic Crashes
*/


DROP TABLE IF EXISTS crashes;
CREATE TABLE crashes (
	crash_id int PRIMARY KEY,
	crash_date timestamp,
	posted_speed_limit varchar(2),
	traffic_control_device varchar(50),
	device_condition varchar(50),
	weather_condition varchar(25),
	lighting_condition varchar(50),
	first_crash_type varchar(100),
	traffic_way_type varchar(100),
	lane_count varchar(5),
	alignment varchar(25),
	roadway_surface_condition varchar(25),
	road_defect varchar(50),
	report_type varchar(50),
	crash_type varchar(100),
	hit_and_run varchar(1),
	damage varchar(25),
	date_police_notified timestamp,
	primary_cause varchar(100),
	secondary_cause varchar(100),
	street_direction varchar(1),
	street_name varchar(50),
	statement_taken varchar(1),
	work_zone varchar(1),
	work_zone_type varchar(25),
	workers_present varchar(1),
	number_unit varchar(2),
	most_severe_injury varchar(50),
	injuries_total varchar(2),
	injuries_fatal varchar(2),
	injuries_incapacitated varchar(2),
	injuries_non_incapacitated varchar(2),
	injuries_reported_not_evident varchar(2),
	crash_hour varchar(2),
	crash_day_of_week varchar(9),
	crash_month varchar(2),
	latitude varchar(25),
	longitude varchar(25),
	crash_location varchar(75)
);

-- Import csv from wheverever you have it stored.  Note the delimiter.

COPY crashes
FROM
'C:\Users\Jaime\Desktop\git-repo\chicago_traffic_crashes\csv\chicago_traffic_crashes_part_1.csv'
DELIMITER ',' CSV HEADER;

COPY crashes
FROM
'C:\Users\Jaime\Desktop\git-repo\chicago_traffic_crashes\csv\chicago_traffic_crashes_part_2.csv'
DELIMITER ',' CSV HEADER;

COPY crashes
FROM
'C:\Users\Jaime\Desktop\git-repo\chicago_traffic_crashes\csv\chicago_traffic_crashes_part_3.csv'
DELIMITER ',' CSV HEADER;

-- Test the record count

SELECT
	count(*)
FROM
	crashes;

-- Results:

count |
------+
686276|


