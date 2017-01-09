
/* Business Problem: Can we model and model a new user browsing experience using a number of tabs, based on the explanatory variables in the Firefox data to predict success? If yes, what are the primary variables that affect a user browsing experience?

/*  Null Hypothesis 1:A 10% increase in the launch of new tabs will not significantly effect the browsing experience of Firefox users

/* Alternative Hypothesis 2:We reject the null hypothesis and accept the alternative hypothesis that the launch of new tabs will  have a significant effect on browsing experience for Firefox users. We will revert back to bookmarks (i.e. no launch).

 ---Note: Obtaining the data from two servers:
        -- /1. User & Survey Tables / APAC: analyticsga-apac.csuojbfcexhv.ap-southeast-2.rds.amazonaws.com 
        --/2. Events table / US-West: analyticsga-cuwj8wvu6wbh.us-west-2.rds.amazonaws.com 

/*Firefox  Initial Exploratory analysis:

--Table'Users'
--27,267 rows 
--7 columns:Id,location, fx_version,ox,Version, survey_answers, number_extensions
--Data Type: Id and number_extensions are integers, the remaining columns are text
--Assumptions: *All rows that have the same user number came from the same submission
             -- *Each submission is a different user
             -- *A single user can have multiple submissions (e.g multiple computers and multiple Firefox profiles)
SELECT *
FROM   Users
;
--Table 'Survey'
--4081 rows
--15 columns:Id,q1 to q14
--Data Type: Id is an integer, the remaining columns are text

SELECT *
FROM   Survey
;

--Table 'events'
--614,292 rows
--7 columns:Id,event_code, data1, data2, data3, timestamp,session_id
--Data Type: Id  and event_code are integers, timestamp is numeric and the remaining columns are text
-- NULL exists

SELECT *
FROM  events
;
/*****************
--Firefox REQUIREMENTS

--Summarize the data in your presentation
--Review the Users Table. Summarize the users represented in the survey

--Count number of Users:
SELECT  COUNT(*) as Total_Number_of_Users        
FROM   users
;
--Returned 27,267 rows of users 

--Q. What is the average,maximum and minimum number of installed add-ons/extensions?
SELECT ROUND(AVG(number_extensions)) as average_number_of_Installed_addons
       ,MAX(number_extensions) as Maximum_Installed_addons
       ,MIN(number_extensions) as Minimum_installed_addons
FROM   Users
;
---returned 1 row (i.e.6, 185 and 1 respectively)

--Q.How many distinct Firefox versions available to users in the User table?
SELECT  COUNT (DISTINCT fx_version) as DifferentTypesofFirefoxversion
FROM    Users
;
---There were 27 rows (i.e. 27 versions of Firefox)

--Q.Count the number of OS types:
SELECT COUNT(DISTINCT os) 
FROM  users
;
--returned 18 rows.

--Q. Count the number of version (test pilot version):
SELECT COUNT(DISTINCT version)   
FROM   users
;
--Returned 4 rows (4 types of pilot version)

--Q.Count number of Firefox versions between 3.5 to 3.6. Returned 29 rows
SELECT COUNT(fx_version)    
FROM   users  
WHERE  fx_version BETWEEN '3.5' AND '3.6'             
;
--(a) Average number of fx_versions, os and versions by User:
SELECT  COUNT(*) as TotalNumberofUsers        
FROM   users
;

SELECT 27267/29 as averagenumerofFXversionbyUser
      ,27267/18 as averagenumberofOSbyUser
      ,27267/4 as averagenumberofVersionbyUser
FROM  Users 
;
-- Returned 27,267 rows(On average from the total number Users: there are 940 variations in fx_versions, 1514 os and 6816 versions of test pilot)
--------------------------------------------------------------------------------------------------------------------------
----Review the Survey Table. How many of the total users completed the survey:
SELECT COUNT(DISTINCT user_id)
FROM   Survey
;
--Returned 4081 rows

--Of the users that completed the survey,identify the number of users who are new to firefox and who are long term users?
SELECT  COUNT(q1) as NumberofFireFoxNew_Users
FROM    Survey
WHERE q1='0'
;
---- Returned 215  new users (i.e Less than 3 months)
SELECT  COUNT(q1) as NumberofFire_Longtime_users
FROM    Survey
WHERE q1='6'
;
-- Returned 1604 long time users (i.e.More than 5 years)

---------------------------Additional findings (include other info in initial findings) _____________________
--Other Questions:

--(ai) How many users only use Firefox as their browser?
SELECT COUNT(q2) as OnlyuseFireFox_as_browser
FROM   Survey
WHERE  q2='0'
--Returned 1356 users who only use Firefox (i.e. LOYAL CUSTOMERS)

--(aii) How many users use other browsers besides Firefox?
SELECT COUNT(q2) as Use_other_browsers_besides_Firefox
FROM   Survey
WHERE  q2 <> '0'
;
--returned 2687 rows of users

--(b) Of the 2687 users who use other competitor browsers,how many use Chrome, Safari, Opera and Internet Explorer?
SELECT COUNT(q3) as Use_competitor_Browser
FROM   Survey
WHERE  --q3='0'
       --q3='1'
       --q3='2'
       q3='3'
;
--returned 551 rows(Chrome users)
--returned 139 rows (Safari users)
--returned 107 rows (Opera users)
--returned 775 rows (Internet Explorer users)

--------Distinguish the user profile behaviour for male and female users:

--- If you use multiple browsers what is your primary browser for males and females? '0' = male, '1'= female
---(c)1, Profile of males and female who are the (Loyal Customers) who do not have any other browsers but only use FireFox as their main browser
SELECT COUNT(q4)
       q5
FROM Survey
WHERE --q5='0'
      q5='1'
---returned 3801 users who completed q4'whatis primary browser', 3483 were males and 240

SELECT    user_id
          ,q4 as WhatisyourmainPrimaryBrowser
          ,q5 as Gender
          ,q6 as Age
          ,q7 as HowmuchTimedoyouspendonWeb
          ,q9 as WheredoyouAcessInternet
          ,q10 as WhichSmartphoneDeviceyouuse
          ,q11 as WhatisMainReasonyouusetheWeb
          ,q12 as Frequentwebsites
          ,q13 as Howtofindtechinfo
FROM       Survey
GROUP BY   q4
           ,q5
           ,q6
           ,q7
           ,q9
           ,q10
           ,q11
           ,q12
           ,q13
           ,user_id
HAVING    q5='0'AND q4='0'
           --q5='1' AND q4='0'
ORDER BY   q4 ASC
           ,q5 ASC
           ,user_id DESC
;
--solution: Profile for males and females who don't have other browsers but only use Firefox as their primary browser:returned 662 (rows)for males and 50 (rows) for females use Firefox as Primary browser:

--(c)2 Profile of males and females who only use Firefox as primary browser:
SELECT    user_id
          ,q4 as WhatisyourmainPrimaryBrowser
          ,q5 as Gender
          ,q6 as Age
          ,q7 as HowmuchTimedoyouspendonWeb
          ,q9 as WheredoyouAcessInternet
          ,q10 as WhichSmartphoneDeviceyouuse
          ,q11 as WhatisMainReasonyouusetheWeb
          ,q12 as Frequentwebsites
          ,q13 as Howtofindtechinfo
FROM       Survey
GROUP BY   q4
           ,q5
           ,q6
           ,q7
           ,q9
           ,q10
           ,q11
           ,q12
           ,q13
          ,user_id
HAVING     --q5='0'AND q4='1'
          q5='1' AND q4='1'
ORDER BY   q4 ASC
           ,q5 ASC
           ,user_id DESC
;
--Solution: Females who only use Firefox returned 165 rows and males returned 2415 rows

--(c)2,Profile of males and females who use Chrome as their primary browser:
SELECT    user_id
          ,q4 as WhatisyourmainPrimaryBrowser
          ,q5 as Gender
          ,q6 as Age
          ,q7 as HowmuchTimedoyouspendonWeb
          ,q9 as WheredoyouAcessInternet
          ,q10 as WhichSmartphoneDeviceyouuse
          ,q11 as WhatisMainReasonyouusetheWeb
          ,q12 as Frequentwebsites
          ,q13 as Howtofindtechinfo
FROM       Survey
GROUP BY   q4
           ,q5
           ,q6
           ,q7
           ,q9
           ,q10
           ,q11
           ,q12
           ,q13
          ,user_id
HAVING    q5='0'AND q4='2'
           --q5='1' AND q4='2'
ORDER BY   q4 ASC
           ,q5 ASC
          ,user_id DESC
; 
-- Solution:Profile for males and females who use Chrome as their primary browser:returned 230 (rows)for males and  9 (rows) for females use Chrome as Primary browser

---(c)3, profile of males and females who use Safari as their primary browser:
SELECT    user_id
          ,q4 as WhatisyourmainPrimaryBrowser
          ,q5 as Gender
          ,q6 as Age
          ,q7 as HowmuchTimedoyouspendonWeb
          ,q9 as WheredoyouAcessInternet
          ,q10 as WhichSmartphoneDeviceyouuse
          ,q11 as WhatisMainReasonyouusetheWeb
          ,q12 as Frequentwebsites
          ,q13 as Howtofindtechinfo
FROM       Survey
GROUP BY   q4
           ,q5
           ,q6
           ,q7
           ,q9
           ,q10
           ,q11
           ,q12
           ,q13
           ,user_id
HAVING     --q5='0'AND q4='3'
          q5='1' AND q4='3'
ORDER BY   q4 ASC
           ,q5 ASC
           ,user_id DESC
;
--solution:Profile for males and females who use Safari as their primary browser:returned 47 (rows)for males and zero (rows) for females use Safari as Primary browser

--(c)4,What is the profile of males and females who use Opera as their primary browser:
SELECT    user_id
          ,q4 as WhatisyourmainPrimaryBrowser
          ,q5 as Gender
          ,q6 as Age
          ,q7 as HowmuchTimedoyouspendonWeb
          ,q9 as WheredoyouAcessInternet
          ,q10 as WhichSmartphoneDeviceyouuse
          ,q11 as WhatisMainReasonyouusetheWeb
          ,q12 as Frequentwebsites
          ,q13 as Howtofindtechinfo
FROM       Survey
GROUP BY   q4
           ,q5
           ,q6
           ,q7
           ,q9
           ,q10
           ,q11
           ,q12
           ,q13
          ,user_id
HAVING    --q5='0'AND q4='4'
          q5='1' AND q4='4'
ORDER BY   q4 ASC
           ,q5 ASC
          ,user_id DESC
;
--Solution the profile of males and females who use Opera as their primary browser returned (3 rows)females and (31 rows) for males 

--(c)5,What is the profile of males and females who use Internet Explorer as their primary browser:
SELECT    user_id
          ,q4 as WhatisyourmainPrimaryBrowser
          ,q5 as Gender
          ,q6 as Age
          ,q7 as HowmuchTimedoyouspendonWeb
          ,q9 as WheredoyouAcessInternet
          ,q10 as WhichSmartphoneDeviceyouuse
          ,q11 as WhatisMainReasonyouusetheWeb
          ,q12 as Frequentwebsites
          ,q13 as Howtofindtechinfo
FROM       Survey
GROUP BY   q4
           ,q5
           ,q6
           ,q7
           ,q9
           ,q10
           ,q11
           ,q12
           ,q13
           ,user_id
HAVING     q5='0'AND q4='5'
           --q5='1' AND q4='5'
ORDER BY   q4 ASC
           ,q5 ASC
           ,user_id DESC
;
---Solution the profile of males and females who use all versions of Internet Explorer as their primary browser returned 13 rows females and 98 rows for males

--------------------------------------------------------------------------------------------------------------------------------
--Summarise  your exploration of the bookmark usage feature in your presentation;

--Event records 614,292 rows
--7 columns:Id,event_code, data1, data2, data3, timestamp,session_id
--Data Type: Id  and event_code are integers, timestamp is numeric and the remaining columns are text
-- NULL exists

--Q1. What is the median number of bookmarks?  Median was 29 bookmarks
-- The output of data extract below was export into Excel as csv. file.

SELECT user_id
       ,data1 as TotalNumberofBookmarksfound
       ,data2 as TotalBookmarkFolders
       ,event_code as Bookmarkstatus
       ,COUNT(data1)
FROM   events
WHERE  event_code IN('8')
GROUP BY event_code
         ,data1
         ,data2
         ,user_id
ORDER BY data1 DESC
;

---(b) Average number of bookmark? Used data extract above from csv export was 123.1476461

--data1 is a string  and cannot be casted as numeric
SELECT AVG(CAST(data1 as numeric))
FROM events
WHERE event_code IN ('8')
;

--/Q.What fraction of users launched AT LEAST ONE BOOKMARK during the sample week? event_code 8 (launch)
--- Total users who launched at least one bookmark 10912 divide by total number of bookmarks launched 10915
  
-- Returned 10912 rows
SELECT  user_id
        ,event_code as Bookmarkstatus
       ,data1 as Total_num_of_bookmarks_launched
FROM   events
WHERE  event_code IN('8') 
GROUP BY event_code
        ,data1
        ,user_id
HAVING  data1>='1'
;

--Total number of  bookmarks launched, returned 10,915 rows:
SELECT COUNT(user_id)
       ,user_id
       ,data1
FROM events
WHERE event_code IN('8')
GROUP BY event_code
         ,user_id
         ,data1
;
--%Launched at least one bookmark (10912/10915)* 100 is 99.97%

--/Q.What fraction of users created new bookmarks?for event_code 9 (create):

-- Returned 216 rows:
SELECT  user_id
        ,event_code as Bookmark_created
       ,data1 as Total_num_of_bookmarks_created
FROM   events
WHERE  event_code IN('9') 
GROUP BY event_code
        ,data1
        ,user_id
HAVING  data1>='1'
;

--Total number of bookmarks created(i.e.new bookmark added), returned 1074 rows:
SELECT COUNT(user_id)
       ,user_id
       ,data1
FROM events
WHERE event_code IN('9')
GROUP BY event_code
         ,user_id
         ,data1
;
--% Created at least one bookmark (216/1074)* 100 is 20.11%

-/Q.What's the distribution of how often bookmarks are used? Bookmark launched event_code 8
SELECT  user_id
        ,event_code as Bookmark_status
       ,data1 as Total_num_of_bookmarks_found
FROM   events
WHERE  event_code IN('8') 
GROUP BY event_code
        ,data1
        ,user_id
;
-- Range:19883, MIN: 0, MAX:19883, MODE:9, Range:19883

--Q. How does number of bookmarks correlate with how long the user has been using Firefox? Sub Query
SELECT e.user_id,e.data1,s.q0
FROM events AS ev
INNER JOIN survey As surv
ON e.user_id=surv.survey.i;


-----------------------------Summarise your exploration of usage of browser tabs in presentation:
-/Q. What's the distribution of maximum number of tabs? Export csv to Excel because data1 is a string  and cannot be casted as numeric
-- Returned 76190 rows

SELECT  user_id
        ,data2
       ,event_code
       ,COUNT(data2)
FROM events
WHERE event_code IN('26')
GROUP BY data2         
        ,event_code
        ,user_id
;
-- Max is:1103

--Q. Are there users who regularly have more than 10 tabs open? csv to Excel

--users >10 tabs is 10493 

--Q.What fraction of user have ever had more than 5 tabs open? 22947/76190 =30.11%

--Q. What fraction of users have had more than  10 tabs open? 10493/76190= 13.77%

--Q. What fraction of users have had more than 15 tabs open? 6456/76190=8.47%


--- Perform inner join to connect the data tables for Events with Survey to return all th rows in two tables where the common condition of 'user_if' is met

SELECT events.event_code
      ,survey.q1
      ,survey.q2
      ,survey.q3
      ,survey.q4
      ,survey.q5
      ,survey.q6
FROM 	events 
INNER JOIN survey 
ON events.user_id=survey.user_id
;

--Returned 386,940 rows