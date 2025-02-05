USE crm_analytics;

SELECT * from account_table;
SELECT * from lead_table;
SELECT * from opp_table;
SELECT * from opp_product;
SELECT * from user_table;

-- ========================================================================================================================================================== 
																	-- OPPORTUNITY 
-- ========================================================================================================================================================== 

-- Expected Amount
SELECT sum(cast(regexp_substr(`expected amount`, '[0-9]+[.]?[0-9]*') AS decimal(10,2))) AS expected_amount
FROM opp_table;


-- Active Opportunities
SELECT count(closed) AS active_opportunities
FROM opp_table 
WHERE closed = 'false'
GROUP BY `closed`;

-- Conversion Rate
SELECT (count(case when closed = 'true' then 1 end) / count('Opportunity ID')) * 100 AS Conversion_Rate_Percentage
FROM opp_table;
 
 -- Win Rate
 SELECT 
    (count(case when stage = 'Closed Won' then 1 end) / count('Opportunity ID')) * 100 AS Win_Rate_Percentage
FROM opp_table;


-- Loss Rate
SELECT 
    (count(case when stage = 'Closed Lost' then 1 end) / count('Opportunity ID')) * 100 AS Lost_Rate_Percentage
FROM opp_table;

-- Running Total Expected Vs Commit Forecast Amount over Time
CREATE VIEW Trend_Analysis1 AS
	SELECT distinct Year(str_to_date(`Created Date`,'%d/%m/%Y %T')) AS Years,
		sum(cast(regexp_substr(`expected amount`, '[0-9]+[.]?[0-9]*') AS decimal(10,2))) AS expected_amount,
		sum(cast(regexp_substr(`amount`, '[0-9]+[.]?[0-9]*') AS decimal(10,2))) AS Amount
	FROM crm_analytics.opp_table
	WHERE `Forecast Category1` = 'Commit'
	GROUP BY Years
	ORDER BY Years desc; 

-- drop view Trend_Analysis2;

SELECT Years,expected_amount,
	SUM(expected_amount) OVER (order by Years) AS Running_Expected_Amount,
	Amount 
FROM Trend_Analysis1;

-- Running Total Active Vs Total Opportunities over Time
CREATE VIEW Trend_Analysis2 AS
	SELECT distinct Year(str_to_date(`Created Date`,'%d/%m/%Y %T')) AS Years,
		count(case when closed = 'false' then 1 end) AS Total_Active,
		count(*) AS Total_Opportunity
	FROM crm_analytics.opp_table
	GROUP BY Years
	ORDER BY Years desc; 
 
SELECT Years,Total_Active,
	SUM(Total_Active) OVER (order by Years) AS Running_Total_Active,
	Total_Opportunity 
FROM Trend_Analysis2;

-- Closed Won Vs Total Opportunities over Time

SELECT distinct Year(str_to_date(`Created Date`,'%d/%m/%Y %T')) AS Years,
	count(case when stage = 'Closed Won' then 1 end)  AS Closed_won,
	count(*) AS Total_Opportunity
FROM opp_table
GROUP BY Years
ORDER BY Years desc;

-- Closed Won vs Total Closed over Time

SELECT distinct Year(str_to_date(`Created Date`,'%d/%m/%Y %T')) AS Years,
	count(case when stage = 'Closed Won' then 1 end)  AS Closed_won,
	count(case when closed = 'true' then 1 end) AS Total_Closed
FROM opp_table
GROUP BY Years
ORDER BY Years desc; 

-- Expected Amount by Opportunity Type

SELECT `Opportunity Type`, 
	sum(cast(regexp_substr(`expected amount`, '[0-9]+[.]?[0-9]*') AS decimal(10,2))) AS expected_amount
FROM opp_table 
GROUP BY `Opportunity Type`;

-- Opportunities by Industry

SELECT industry,
     count(`opportunity id`) as opportunities
FROM opp_table
GROUP BY industry 
ORDER BY opportunities desc;

-- ========================================================================================================================================================== 
																	-- LEAD
-- ========================================================================================================================================================== 

-- Total Lead

SELECT sum(`total leads`) AS total_leads FROM lead_table;

-- Expected Amount from Converted Leads 

SELECT sum(cast(regexp_substr(`expected amount`, '[0-9]+[.]?[0-9]*') AS decimal(10,2))) AS expected_amount
FROM opp_table
JOIN lead_table
ON opp_table.`Opportunity ID` = lead_table.`Converted Opportunity ID` ;

-- Conversion Rate 

SELECT 
    (count(case when `Converted` = 'True' then 1 end) / count(`Lead ID`)) * 100 AS conversion_rate
FROM lead_table;

-- Converted Accounts

SELECT sum(`# Converted Accounts`) AS converted_accounts 
FROM lead_table;

-- Converted Opportunities

SELECT sum(`# Converted Opportunities`) AS Converted_Opportunities
FROM lead_table;

-- Lead By Source

SELECT `Lead Source`, count(*) AS Lead_Count
FROM lead_table
GROUP BY `Lead Source`;

-- Lead By industry

SELECT Industry, count(*) AS Lead_Count
FROM lead_table
GROUP BY Industry;


-- Lead By Stage

SELECT 
	opp_table.`Stage` as Stage , 
	count(lead_table.`Lead ID`) AS Lead_Count
FROM opp_table
JOIN lead_table
ON opp_table.`Opportunity ID` = lead_table.`Converted Opportunity ID`
GROUP BY Stage;