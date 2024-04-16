SELECT * from datacleaning.earthquakes;
-- A look at my datasets shows that it contains date, time and some numerical values
-- To confirm that the variables are stored in the right type of data type; I have to confirm the data types

-- Confirming the data types of the variables
SELECT DATA_TYPE from INFORMATION_SCHEMA.COLUMNS where
table_schema = 'datacleaning' and table_name = 'earthquakes';

-- This shows that shows that the data are stored in wrong datatype; Dates and time as well as some numerical values are stored with text.
-- This will throw up error during calculation and will also bring out wrong queries that will skew our analysis.alter
-- -------------------------------------------------------------------

-- Handling data entry inconsistence
SELECT length(date), MAX(length(date)), min(length(date))
from datacleaning.earthquakes;-- min=10, Max=24
-- Making sure that there are no other length apart from the two above
SELECT date from datacleaning.earthquakes 
where length(date) != 10 AND length(date) != 24; -- 0

-- Using the LEFT function to clean up the Date string

SELECT LEFT(Date,10) from datacleaning.earthquakes;

UPDATE datacleaning.earthquakes SET Date = LEFT(date,10);-- 3 rows were affected
 
 Select Date from datacleaning.earthquakes where length(Date) = 24; -- 0 rows
 
 -- To Standardize Date column
 
 Select str_to_date(Date, '%d/%m/%Y') from datacleaning.earthquakes;
 
 ALTER TABLE datacleaning.earthquakes
ADD column Date2 date after Date;

UPDATE datacleaning.earthquakes
SET Date2 = STR_TO_DATE(Date, '%d/%m/%Y'); -- throws up some error of incorrect datetime values
-- To find the cause of the error
Select date, str_to_date(Date, '%d/%m/%Y') from datacleaning.earthquakes
where str_to_date(Date, '%d/%m/%Y') is null; -- 3 of them (since there are not much I will manually update the 3 columns with REPLACE fnx

update datacleaning.earthquakes
SET Date = Replace(Date, '1975-02-23', '23/02/1975');

update datacleaning.earthquakes
SET Date = Replace(Date, '1985-04-28', '28/04/1985');

update datacleaning.earthquakes
SET Date = Replace(Date, '2011-03-13', '13/03/2011');

Select date, str_to_date(Date, '%d/%m/%Y') from datacleaning.earthquakes
where str_to_date(Date, '%d/%m/%Y') is null;-- 0 [Error has been corrected]

-- To update the new Date2 column again
UPDATE datacleaning.earthquakes
SET Date2 = STR_TO_DATE(Date, '%d/%m/%Y');-- 23412 rows were affected

select date, date2 from datacleaning.earthquakes;

-- To standardize the time column
select cast(Time as time) from datacleaning.earthquakes;

Alter table datacleaning.earthquakes add Time2 time after Time;

Update datacleaning.earthquakes
set Time2 = cast(Time as time);-- this threw up error ' Truncated incorrect time value

-- To find the cause of the error
Select length(Time), max(length(Time)), min(length(Time)) from datacleaning.earthquakes;-- min=8, max =24

select count(Time) from datacleaning.earthquakes where length(Time) = 24;-- 3
select count(Time) from datacleaning.earthquakes where length(Time) = 8; -- 23409 (the sum of the two above queries shows that there is no other differing length.

-- To show the abnormal time length:
select Time from datacleaning.earthquakes where length(Time) = 24; 

-- Cleaning up the Time length with SUBSTRING FNX
Select Time, substr(Time,12,8) as 'new time' from datacleaning.earthquakes where length(Time) = 24;

-- To replace the 3 rows with the correct Time length
update datacleaning.earthquakes 
Set Time = replace(Time,'1975-02-23T02:58:41.000Z', substr(Time,12,8))
where Time = '1975-02-23T02:58:41.000Z';

update datacleaning.earthquakes 
Set Time = replace(Time,'1985-04-28T02:53:41.530Z', substr(Time,12,8))
where Time = '1985-04-28T02:53:41.530Z';

update datacleaning.earthquakes 
Set Time = replace(Time,'2011-03-13T02:23:34.520Z', substr(Time,12,8))
where Time = '2011-03-13T02:23:34.520Z';

-- To check if it the correction has been effected correctly
Select min(length(Time)), Max(length(Time)) from datacleaning.earthquakes;-- min(8), Max(8)
-- To Update the new column Time 2
Update datacleaning.earthquakes
set Time2 = cast(Time as time);

select Time, Time2 from datacleaning.earthquakes;
-- -------------------------------------------------------------------
-- Using CASE FNX handle the blank values in the columns before converting them to the appropriate datatype
Select count(Depth_Error) from datacleaning.earthquakes where Depth_Error = '';-- 18951

update datacleaning.earthquakes 
Set Depth_Error = case
when Depth_Error = '' then 0.0
else Depth_Error
end;

update datacleaning.earthquakes Set Depth_Seismic_Stations = case
when  Depth_Seismic_Stations = '' then 0.0 
else Depth_Seismic_Stations
end;

update datacleaning.earthquakes Set Magnitude_Error = case
when  Magnitude_Error = '' then 0.0 
else Magnitude_Error
end;

update datacleaning.earthquakes Set Magnitude_Seismic_Stations = case
when  Magnitude_Seismic_Stations = '' then 0.0 
else Magnitude_Seismic_Stations
end;

update datacleaning.earthquakes Set Azimuthal_Gap = case
when Azimuthal_Gap = '' then 0.0 
else Azimuthal_Gap
end;

update datacleaning.earthquakes Set Horizontal_Distance = case
when Horizontal_Distance = '' then 0.0 
else Horizontal_Distance
end;

update datacleaning.earthquakes Set Horizontal_Error = case
when Horizontal_Error = '' then 0.0 
else Horizontal_Error
end;

update datacleaning.earthquakes Set Root_Mean_Square = case
when Root_Mean_Square = '' then 0.0 
else Root_Mean_Square
end;

-- Converting the numerical data that were stored as text to double

ALTER TABLE earthquakes Modify column Depth_Error double;
ALTER TABLE earthquakes Modify column Depth_Seismic_Stations double;
ALTER TABLE earthquakes Modify column Magnitude_Error double;
ALTER TABLE earthquakes Modify column Magnitude_Seismic_Stations double;
ALTER TABLE earthquakes Modify column Azimuthal_Gap double;
ALTER TABLE earthquakes Modify column Horizontal_Distance double;
ALTER TABLE earthquakes Modify column Horizontal_Error double;
ALTER TABLE earthquakes Modify column Root_Mean_Square double; 

-- CHECKING FOR DUPLICATES USING CTE
With t1 as (
SELECT *, row_number() over(partition by Date2, Time2, Latitude, Longitude order by ID) rownum
from datacleaning.earthquakes)
Select count(*) from t1 where rownum >1; -- 0 (No duplicate values)

-- CREATING NEW COLUMNS (YEAR, MONTH, DAY, WEEK, DAY OF WEEK) FROM THE DATE2 COLUMN
-- Year 
SELECT EXTRACT(YEAR FROM Date2) from datacleaning.earthquakes;

alter table datacleaning.earthquakes add column Year int after Time2;

Update datacleaning.earthquakes set Year =
extract(YEAR FROM Date2);
-- ----Month and MonthName
select extract(MONTH FROM Date2), monthname(Date2) from earthquakes;
alter table datacleaning.earthquakes add column Month int after Year; 

Update datacleaning.earthquakes set Month =
extract(Month FROM Date2);
-- Week
Select week(Date2,0) from earthquakes;
alter table datacleaning.earthquakes add column Week int after Month;
update datacleaning.earthquakes set Week =
week(Date2,0);
-- Day of the week
select dayname(Date2) from earthquakes;
alter table datacleaning.earthquakes add column Weekdays character after Week; 

update earthquakes set Weekdays =
dayname(Date2); -- This throws up Error 1406. Data too long for column

alter table datacleaning.earthquakes modify column Weekdays character (15);

update earthquakes set Weekdays =
dayname(Date2);

-- Looking for outliers (with the knowledge that the years data were collected were 1965-2016 and magnitude is >= 5.5)
select year from earthquakes 
where Year < 1965 or Year > 2016;

select * from earthquakes
where Magnitude < 5.5; -- 0

-- Deleting UNUSED COLUMN
Alter table datacleaning.earthquakes
Drop column Date,
Drop column Time ;

Select * from datacleaning.earthquakes;









 
 
 