CREATE DATABASE Saudi_Aramco_Analysis;

USE Saudi_Aramco_Analysis;


CREATE TABLE Income_Statement (
    year INT PRIMARY KEY,
    revenue BIGINT,
    operating_income BIGINT,
    net_income BIGINT
);

CREATE TABLE Balance_Sheet (
    year INT PRIMARY KEY,
    total_assets BIGINT,
    total_liabilities BIGINT,
    total_equity BIGINT,
    current_assets BIGINT,
    current_liabilities BIGINT
);

CREATE TABLE Cash_Flow (
    year INT PRIMARY KEY,
    operating_cash_flow BIGINT,
    investing_cash_flow BIGINT,
    financing_cash_flow BIGINT,
    capital_expenditure BIGINT,
    dividends_paid BIGINT
);

CREATE TABLE Operational_Data (
    year INT PRIMARY KEY,
    realized_oil_price DECIMAL(10,2),
    liquids_production DECIMAL(10,2),
    gas_production DECIMAL(10,2),
    hydrocarbon_production DECIMAL(10,2)
);

INSERT INTO Income_Statement
(year, revenue, operating_income, net_income)
VALUES
(2021, 1346930, 771918, 412396),
(2022, 2006955, 1144077, 604005),
(2023, 1653281, 868287, 454764),
(2024, 1637299, 774625, 398422),
(2025, 1559342, 706822, 350210);

INSERT INTO Balance_Sheet
(year, total_assets, total_liabilities, total_equity,
 current_assets, current_liabilities)
VALUES
(2021, 2162690, 882022, 1280668, 611241, 303828),
(2022, 2492924, 826777, 1666147, 857831, 331386),
(2023, 2477940, 740848, 1737092, 731735, 317566),
(2024, 2423630, 772275, 1651355, 565396, 299263),
(2025, 2551964, 830220, 1721744, 596277, 298349);

INSERT INTO Cash_Flow
(year, operating_cash_flow, investing_cash_flow,
 financing_cash_flow, capital_expenditure, dividends_paid)
VALUES
(2021, 522601, -135741, -294513, 119645, 281300),
(2022, 698152, -389009, -382675, 141161, 281300),
(2023, 537814, -54019, -510869, 158308, 366700),
(2024, 508888, -2861, -488358, 188890, 465918),
(2025, 510798, -203902, -280439, 190444, 320447);

INSERT INTO Operational_Data
(year, realized_oil_price, liquids_production,
 gas_production, hydrocarbon_production)
VALUES
(2021, 70.50, 10359, 10136, 12343),
(2022, 100.20, 11540, 10617, 13617),
(2023, 83.60, 10682, 10672, 12767),
(2024, 80.20, 10292, 10833, 12403),
(2025, 69.20, 10678, 11365, 12891);



-- REVENUE AND PROFITABILITY ANALYSIS

SELECT year, revenue, operating_income, net_income
FROM Income_Statement
ORDER BY year;

SELECT year, revenue,
LAG(revenue) OVER (ORDER BY year) AS previous_year_revenue,
ROUND(
	(revenue - LAG(revenue) OVER (ORDER BY year)) /
      LAG(revenue) OVER (ORDER BY year) * 100, 2)
       AS revenue_growth_percentage
FROM income_statement
ORDER BY year;   

SELECT year, operating_income,
LAG(operating_income) OVER (ORDER BY year) AS previous_operating_income,
ROUND( 
    (operating_income - LAG(operating_income) OVER (ORDER BY year))/
       LAG(operating_income) OVER (ORDER BY year) * 100, 2) AS operating_income_growth,
net_income, 
 LAG(net_income) OVER (ORDER BY year) AS previous_net_income,
ROUND( 
    (net_income - LAG(net_income) OVER (ORDER BY year))/
       LAG(net_income) OVER (ORDER BY year) * 100, 2) AS net_income_growth
FROM income_statement
ORDER BY year;       

SELECT year, revenue, operating_income, net_income,
ROUND(operating_income/ revenue * 100, 2) AS operating_profit_margin,
ROUND(net_income/ revenue * 100, 2) AS net_profit_margin
FROM income_statement 
ORDER BY year;

SELECT year, total_assets, total_liabilities, total_equity, current_assets, current_liabilities
FROM balance_sheet
ORDER BY year;

SELECT year, total_assets,
ROUND(
     (total_assets - LAG(total_assets) OVER (ORDER BY year)) /
        LAG(total_assets) OVER (ORDER BY year) * 100, 2) AS assets_growth_percentage,
total_liabilities,
ROUND(
     (total_liabilities - LAG(total_liabilities) OVER (ORDER BY year)) /
        LAG(total_liabilities) OVER (ORDER BY year) * 100, 2) AS liabilities_growth_percentage,
total_equity, 
ROUND(
     (total_equity - LAG(total_equity) OVER (ORDER BY year)) /
        LAG(total_equity) OVER (ORDER BY year) * 100, 2) AS equity_growth_percentage
FROM balance_sheet
ORDER BY year;        

SELECT year, current_assets, current_liabilities,
ROUND (
    current_assets / current_liabilities, 2) AS current_ratio
FROM balance_sheet
ORDER BY year;    

SELECT year, total_liabilities, total_equity,
ROUND(
	total_liabilities / total_equity, 4
    ) AS liabilities_to_equity
FROM Balance_Sheet
ORDER BY year;
        
SELECT year, total_assets, total_equity,
ROUND(
    total_equity / total_assets * 100, 2) AS equity_ratio_percentage
FROM balance_sheet
ORDER BY year;    

SELECT year, operating_cash_flow
FROM Cash_Flow
ORDER BY year;

SELECT year, operating_cash_flow, capital_expenditure,
operating_cash_flow - capital_expenditure AS free_cash_flow
FROM cash_flow
ORDER BY year;	

SELECT year, operating_cash_flow - capital_expenditure AS free_cash_flow, dividends_paid,
ROUND(
     (operating_cash_flow - capital_expenditure ) / dividends_paid, 2) AS dividend_coverage_ratio
FROM cash_flow
ORDER BY year;     

SELECT 
i.year, i.revenue, i.operating_income, i.net_income,
b.total_assets, b.total_liabilities, b.total_equity,
c.operating_cash_flow, c.capital_expenditure, c.dividends_paid
FROM Income_statement i
INNER JOIN balance_sheet b
ON i.year = b.year
INNER JOIN cash_flow c
ON i.year = c.year
ORDER BY year;

SELECT i.year, i.net_income, c.operating_cash_flow,
ROUND(
    c.operating_cash_flow/ i.net_income, 2) AS operating_cash_flow_to_net_income
FROM Income_statement i
INNER JOIN cash_flow c
ON i.year = c.year
ORDER BY i.year;

SELECT year, net_income,
DENSE_RANK() OVER (ORDER BY net_income DESC) AS profitability_ratio
FROM income_statement;

SELECT year, operating_cash_flow - capital_expenditure AS free_cash_flow,
DENSE_RANK() OVER (ORDER BY operating_cash_flow - capital_expenditure DESC) AS fcf_rank
FROM cash_flow;

WITH Financial_Trends AS (
    SELECT i.year, i.net_income, cf.operating_cash_flow,
        LAG(i.net_income) OVER (ORDER BY i.year
        ) AS previous_net_income,

        LAG(cf.operating_cash_flow) OVER (ORDER BY i.year
        ) AS previous_operating_cash_flow

FROM Income_Statement i
JOIN Cash_Flow cf
ON i.year = cf.year
)
SELECT *
FROM Financial_Trends
WHERE net_income < previous_net_income
AND operating_cash_flow > previous_operating_cash_flow;

WITH Annual_Trends AS(
SELECT i.year, i.revenue, i.net_income, cf.operating_cash_flow, cf.operating_cash_flow - cf.capital_expenditure AS free_cash_flow,
LAG (i.revenue) OVER (ORDER BY i.year) AS previous_revenue,
LAG (i.net_income) OVER (ORDER BY i.year) AS previous_net_income,
LAG (cf.operating_cash_flow) OVER (ORDER BY i.year) AS previous_operating_cash_flow,
LAG (cf.operating_cash_flow - cf.capital_expenditure) OVER (ORDER BY i.year) AS previous_fcf
FROM income_statement i
JOIN cash_flow cf
ON i.year = cf.year
)
SELECT year, 
ROUND((revenue - previous_revenue) / previous_revenue * 100, 2)
AS revenue_growth_pct,
ROUND((net_income - previous_net_income) / previous_net_income * 100, 2)
AS net_income_growth_pct,
ROUND((operating_cash_flow - previous_operating_cash_flow) / previous_operating_cash_flow * 100, 2)
AS operating_cash_flow_growth_pct,
ROUND((free_cash_flow - previous_fcf) / previous_fcf * 100, 2)
AS free_cash_flow_growth_pct
FROM Annual_Trends
ORDER BY year;

WITH Financial_Health AS (
    SELECT i.year, i.revenue, i.net_income, cf.operating_cash_flow, cf.capital_expenditure, cf.dividends_paid,
    i.net_income / i.revenue * 100 AS net_profit_margin,
    bs.current_assets / bs.current_liabilities AS current_ratio,

	(cf.operating_cash_flow - cf.capital_expenditure) / cf.dividends_paid AS dividend_coverage

    FROM Income_Statement i
    JOIN Balance_Sheet bs
	ON i.year = bs.year
    JOIN Cash_Flow cf
    ON i.year = cf.year
)

SELECT year,
    ROUND(net_profit_margin, 2) AS net_profit_margin,
    ROUND(current_ratio, 2) AS current_ratio,
    ROUND(dividend_coverage, 2) AS dividend_coverage,
    CASE
        WHEN net_profit_margin >= 25 THEN 'Strong'
        ELSE 'Weak'
    END AS profitability_status,

    CASE
        WHEN current_ratio >= 2 THEN 'Higher'
        ELSE 'Lower'
    END AS liquidity_status,

    CASE
        WHEN dividend_coverage >= 1 THEN 'Covered'
        ELSE 'Not Fully Covered'
    END AS dividend_status

FROM Financial_Health
ORDER BY year;

SELECT i.year, i.revenue, i.net_income, o.realized_oil_price, o.liquids_production, o.gas_production, o.hydrocarbon_production
FROM Income_Statement i
JOIN Operational_Data o
ON i.year = o.year
ORDER BY i.year;

WITH Annual_Analysis AS (
    SELECT
        i.year, i.revenue, o.realized_oil_price, o.hydrocarbon_production,
        LAG(i.revenue) OVER (ORDER BY i.year) AS previous_revenue,
        LAG(o.realized_oil_price) OVER (ORDER BY i.year) AS previous_oil_price,
        LAG(o.hydrocarbon_production) OVER (ORDER BY i.year) AS previous_production
	FROM Income_Statement i
    JOIN Operational_Data o
    ON i.year = o.year
)

SELECT year,
ROUND(
        (revenue - previous_revenue) / previous_revenue * 100, 2) AS revenue_growth_pct,
ROUND(
        (realized_oil_price - previous_oil_price) / previous_oil_price * 100, 2) AS oil_price_change_pct,
ROUND(
        (hydrocarbon_production - previous_production) / previous_production * 100, 2) AS production_change_pct
FROM Annual_Analysis
ORDER BY year;

WITH Annual_Changes AS (
    SELECT i.year, i.revenue, o.realized_oil_price,
    LAG(i.revenue) OVER (ORDER BY i.year) AS previous_revenue,
    LAG(o.realized_oil_price) OVER (ORDER BY i.year) AS previous_oil_price
    FROM Income_Statement i
    JOIN Operational_Data o
        ON i.year = o.year
)
SELECT year,

    CASE
        WHEN revenue > previous_revenue
         AND realized_oil_price > previous_oil_price
            THEN 'Both Increased'

        WHEN revenue < previous_revenue
         AND realized_oil_price < previous_oil_price
            THEN 'Both Decreased'

        ELSE 'Moved in Opposite Directions'
    END AS movement_pattern

FROM Annual_Changes
WHERE previous_revenue IS NOT NULL
ORDER BY year;

SELECT i.year, o.realized_oil_price, o.hydrocarbon_production, i.revenue
FROM Income_Statement i
JOIN Operational_Data o
ON i.year = o.year
WHERE
    o.realized_oil_price < (
        SELECT previous_oil_price
        FROM (
            SELECT
                year,
                LAG(realized_oil_price)
                    OVER (ORDER BY year) AS previous_oil_price
            FROM Operational_Data
        ) AS price_changes
        WHERE price_changes.year = i.year
    )

    AND o.hydrocarbon_production > (
        SELECT previous_production
        FROM (
            SELECT
                year,
                LAG(hydrocarbon_production)
                    OVER (ORDER BY year) AS previous_production
            FROM Operational_Data
        ) AS production_changes
        WHERE production_changes.year = i.year
    );






      
