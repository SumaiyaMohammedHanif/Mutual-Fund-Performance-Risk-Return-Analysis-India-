CREATE TABLE mutual_funds_nav (
    fund_name TEXT,
    nav DECIMAL,
    nav_date DATE
);
CREATE TABLE temp_nav (
    nav DECIMAL,
    nav_date DATE
);
INSERT INTO mutual_funds_nav (fund_name, nav, nav_date)
SELECT 'SBI Largecap', nav, nav_date FROM temp_nav;
INSERT INTO mutual_funds_nav (fund_name, nav, nav_date)
SELECT 'Nippon Smallcap', nav, nav_date FROM temp_nav;
INSERT INTO mutual_funds_nav (fund_name, nav, nav_date)
SELECT 'ICIC Debt', nav, nav_date FROM temp_nav;
INSERT INTO mutual_funds_nav (fund_name, nav, nav_date)
SELECT 'HDFC Balanced', nav, nav_date FROM temp_nav;
INSERT INTO mutual_funds_nav (fund_name, nav, nav_date)
SELECT 'Axis Midcap', nav, nav_date FROM temp_nav;

CREATE TABLE mutual_fund_nav_all (
    nav DECIMAL,
    nav_date DATE,
    fund_name TEXT
);
INSERT INTO mutual_fund_nav_all (nav, nav_date, fund_name)
SELECT nav, nav_date, 'SBI Large Cap' FROM temp_nav;
TRUNCATE TABLE temp_nav;

INSERT INTO mutual_fund_nav_all (nav, nav_date, fund_name)
SELECT nav, nav_date, 'Axis Mid Cap' FROM temp_nav;
TRUNCATE TABLE temp_nav;

INSERT INTO mutual_fund_nav_all (nav, nav_date, fund_name)
SELECT nav, nav_date, 'Nippon Small Cap' FROM temp_nav;
TRUNCATE TABLE temp_nav;

INSERT INTO mutual_fund_nav_all (nav, nav_date, fund_name)
SELECT nav, nav_date, 'HDFC Balanced' FROM temp_nav;
TRUNCATE TABLE temp_nav;

INSERT INTO mutual_fund_nav_all (nav, nav_date, fund_name)
SELECT nav, nav_date, 'ICIC Debt' FROM temp_nav;
TRUNCATE TABLE temp_nav;

SELECT * FROM mutual_fund_nav_all ORDER BY fund_name, nav_date;
TRUNCATE TABLE mutual_fund_nav_all;

TRUNCATE TABLE temp_nav;
INSERT INTO mutual_fund_nav_all (nav, nav_date, fund_name)
SELECT nav, nav_date, 'SBI Large Cap' FROM temp_nav;

TRUNCATE TABLE temp_nav;
INSERT INTO mutual_fund_nav_all (nav, nav_date, fund_name)
SELECT nav, nav_date, 'Nippon Small Cap' FROM temp_nav;

TRUNCATE TABLE temp_nav;
INSERT INTO mutual_fund_nav_all (nav, nav_date, fund_name)
SELECT nav, nav_date, 'Axis Mid Cap' FROM temp_nav;

TRUNCATE TABLE temp_nav;
INSERT INTO mutual_fund_nav_all (nav, nav_date, fund_name)
SELECT nav, nav_date, 'HDFC Balanced' FROM temp_nav;

TRUNCATE TABLE temp_nav;
INSERT INTO mutual_fund_nav_all (nav, nav_date, fund_name)
SELECT nav, nav_date, 'ICIC Debt' FROM temp_nav;

SELECT fund_name, COUNT(*) 
FROM mutual_fund_nav_all 
GROUP BY fund_name;

SELECT fund_name, COUNT(*) AS row_count
FROM mutual_fund_nav_all
GROUP BY fund_name
ORDER BY row_count DESC;

SELECT *
FROM mutual_fund_nav_all
WHERE nav IS NULL OR nav_date IS NULL OR fund_name IS NULL;

SELECT fund_name, MIN(nav_date) AS start_date, MAX(nav_date) AS end_date
FROM mutual_fund_nav_all
GROUP BY fund_name;




