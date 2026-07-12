-- ===========================================
-- DATABASE CREATION
-- ===========================================

CREATE DATABASE mutual_fund_db;
USE mutual_fund_db;

-- ===========================================
-- TABLE CREATION
-- ===========================================

CREATE TABLE Investors (
    Investor_ID VARCHAR(20) PRIMARY KEY,
    Gender VARCHAR(20),
    Age INT,
    Marital_Status VARCHAR(30),
    Occupation VARCHAR(100),
    Annual_Income DECIMAL(15,2),
    City VARCHAR(100),
    State VARCHAR(100),
    Risk_Profile VARCHAR(30),
    Investment_Goal VARCHAR(100),
    Investment_Horizon_Years INT,
    Investor_Segment VARCHAR(50)
);

CREATE TABLE Fund_Master (
    Fund_ID VARCHAR(20) PRIMARY KEY,
    Fund_Name VARCHAR(100),
    Fund_Category VARCHAR(100),
    AMC VARCHAR(100),
    Expected_Return DECIMAL(5,2)
);

CREATE TABLE SIP_Transactions (
    Transaction_ID VARCHAR(20) PRIMARY KEY,
    Investor_ID VARCHAR(20),
    Date DATE,
    Fund_ID VARCHAR(20),
    Fund_Name VARCHAR(100),
    SIP_Amount DECIMAL(10,2),
    NAV DECIMAL(10,2),
    Units_Allocated DECIMAL(12,4),

    FOREIGN KEY (Investor_ID)
        REFERENCES Investors(Investor_ID),

    FOREIGN KEY (Fund_ID)
        REFERENCES Fund_Master(Fund_ID)
);

-- ===========================================
-- BASIC SQL ANALYSIS
-- ===========================================

-- 1) How many investors are registered?
SELECT COUNT(*) AS Total_Investors
FROM Investors;

-- -- Business Insight:
-- The company has 1,000 registered investors.

-- 2) How many male and female investors are there?
SELECT Gender,
       COUNT(*) AS Total_Investors
FROM Investors
GROUP BY Gender;

-- 3) What is the average age of investors?
select round(avg(Age),2) as Average_Age
from Investors;

-- 4) investor by Risk profile
select Risk_Profile,
	count(*) as Total_Investor
from Investors
group by Risk_Profile
order by Total_Investor desc;

-- 5) investors by City
select city,
	count(*) as Total_Investors
from investors
group by city 
order by Total_Investors desc;

-- 6) investors by occupation
select Occupation,
	count(*) as Total_Investors
from investors 
group by Occupation
order by Total_Investors desc;

-- 7) Average annual income by occupation
SELECT Occupation,
       ROUND(AVG(Annual_Income),2) AS Avg_Income
FROM Investors
GROUP BY Occupation
ORDER BY Avg_Income DESC;

-- 8) Average SIP Amount
SELECT ROUND(AVG(SIP_Amount),2) AS Average_SIP
FROM SIP_Transactions;

-- 9) Maxmimum SIP Amount
SELECT max(SIP_Amount) AS Maximum_SIP
FROM SIP_Transactions;

-- 10) minimum SIP Amount
SELECT min(SIP_Amount) AS Minimum_SIP
FROM SIP_Transactions;

-- ===========================================
-- JOIN QUERIES
-- ===========================================

-- 11) Which investor invested in which fund?
SELECT
    i.Investor_ID,
    s.Fund_Name,
    s.SIP_Amount
FROM Investors i
INNER JOIN SIP_Transactions s
ON i.Investor_ID = s.Investor_ID;

-- 12) Which mutual fund received the highest investment?
SELECT
    Fund_Name,
    SUM(SIP_Amount) AS Total_Investment
FROM SIP_Transactions
GROUP BY Fund_Name
ORDER BY Total_Investment DESC;

-- 13) Which Asset Management Company (AMC) manages the highest SIP investment?
SELECT
    f.AMC,
    SUM(s.SIP_Amount) AS Total_Investment
FROM SIP_Transactions s
INNER JOIN Fund_Master f
ON s.Fund_ID = f.Fund_ID
GROUP BY f.AMC
ORDER BY Total_Investment DESC;

-- 14) Which Fund Category receives the highest SIP investment?
SELECT
    f.Fund_Category,
    SUM(s.SIP_Amount) AS Total_Investment
FROM SIP_Transactions s
JOIN Fund_Master f
ON s.Fund_ID = f.Fund_ID
GROUP BY f.Fund_Category
ORDER BY Total_Investment DESC;

-- 15) Which investor invested the highest total SIP amount?
SELECT
    Investor_ID,
    SUM(SIP_Amount) AS Total_Investment
FROM SIP_Transactions
GROUP BY Investor_ID
ORDER BY Total_Investment DESC
LIMIT 10;

-- 16) Which fund has the highest average NAV?
SELECT
    Fund_Name,
    ROUND(AVG(NAV),2) AS Average_NAV
FROM SIP_Transactions
GROUP BY Fund_Name
ORDER BY Average_NAV DESC;

-- 17) Which city has invested the highest total SIP amount?
SELECT
    i.City,
    SUM(s.SIP_Amount) AS Total_Investment
FROM Investors i
JOIN SIP_Transactions s
ON i.Investor_ID = s.Investor_ID
GROUP BY i.City
ORDER BY Total_Investment DESC;

-- 18) How many investors invested in each fund?
SELECT
    Fund_Name,
    COUNT(DISTINCT Investor_ID) AS Total_Investors
FROM SIP_Transactions
GROUP BY Fund_Name
ORDER BY Total_Investors DESC;

-- 19) Average SIP by Investor Segment
SELECT
    i.Investor_Segment,
    ROUND(AVG(s.SIP_Amount),2) AS Average_SIP
FROM Investors i
JOIN SIP_Transactions s
ON i.Investor_ID = s.Investor_ID
GROUP BY i.Investor_Segment
ORDER BY Average_SIP DESC;

-- 20) Total Investment by State
SELECT
    i.State,
    SUM(s.SIP_Amount) AS Total_Investment
FROM Investors i
JOIN SIP_Transactions s
ON i.Investor_ID = s.Investor_ID
GROUP BY i.State
ORDER BY Total_Investment DESC;

-- 21) Total Investment by Gender
SELECT
    i.Gender,
    SUM(s.SIP_Amount) AS Total_Investment
FROM Investors i
JOIN SIP_Transactions s
ON i.Investor_ID = s.Investor_ID
GROUP BY i.Gender;

-- 22) Highest Investment Goal
SELECT
    Investment_Goal,
    COUNT(*) AS Total_Investors
FROM Investors
GROUP BY Investment_Goal
ORDER BY Total_Investors DESC;

-- 23) Investors with Total Investment > ₹1,50,000 (HAVING)
SELECT
    Investor_ID,
    SUM(SIP_Amount) AS Total_Investment
FROM SIP_Transactions
GROUP BY Investor_ID
HAVING SUM(SIP_Amount) > 150000
ORDER BY Total_Investment DESC;

-- 24) Monthly SIP Trend
SELECT
    YEAR(Date) AS Year,
    MONTH(Date) AS Month,
    SUM(SIP_Amount) AS Total_Investment
FROM SIP_Transactions
GROUP BY YEAR(Date), MONTH(Date)
ORDER BY Year, Month;

-- 25) Fund with Highest Expected Return
SELECT
    Fund_Name,
    Expected_Return
FROM Fund_Master
ORDER BY Expected_Return DESC
LIMIT 1;

-- 26) Top 10 Investors by Units Allocated
SELECT
    Investor_ID,
    ROUND(SUM(Units_Allocated),2) AS Total_Units
FROM SIP_Transactions
GROUP BY Investor_ID
ORDER BY Total_Units DESC
LIMIT 10;

-- 27) Average Units Allocated per Fund
SELECT
    Fund_Name,
    ROUND(AVG(Units_Allocated),2) AS Average_Units
FROM SIP_Transactions
GROUP BY Fund_Name
ORDER BY Average_Units DESC;

-- 28) Create a View
CREATE VIEW Investor_Summary AS
SELECT
    i.Investor_ID,
    i.City,
    i.State,
    i.Risk_Profile,
    SUM(s.SIP_Amount) AS Total_Investment
FROM Investors i
JOIN SIP_Transactions s
ON i.Investor_ID = s.Investor_ID
GROUP BY
    i.Investor_ID,
    i.City,
    i.State,
    i.Risk_Profile;
 
 -- 29) Display the View
    SELECT *
FROM Investor_Summary;

-- 30) Top 5 Investors Using the View
SELECT *
FROM Investor_Summary
ORDER BY Total_Investment DESC
LIMIT 5;