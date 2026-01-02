-- Load the Data using INFILE Method

create schema retail_cohort;
use retail_cohort;

create table if not exists retail (
    InvoiceNo varchar(100),
    StockCode varchar(20),
    Description varchar(100),
    Quantity decimal(8,2), 
    InvoiceDate varchar(25),
    UnitPrice decimal(8,2), 
    CustomerID varchar(100),  
    Country varchar(25)
);

load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Online Retail Data.csv'
into table retail
fields terminated by ',' 
optionally enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows
(InvoiceNo, StockCode, Description, Quantity, @date_str, 
UnitPrice, CustomerID, Country)
set InvoiceDate = STR_TO_DATE(@date_str, '%d/%m/%Y %H:%i');

select * from retail;
select count(distinct InvoiceNo) from retail;
select count(distinct customerid) from retail;



-- Begin the Cohort Analysis



-- 1. Cohort Analysis Based on Order Counts


-- Prepare Data

create view order_cohort as 
with cte1 as (
select InvoiceNo, CustomerID, InvoiceDate, round((Quantity * UnitPrice), 2) as Revenue
from retail
where CustomerID is not null), 

-- Get Purchase Month and 1st Purchase Month

cte2 as (
select InvoiceNo, CustomerID, InvoiceDate,
       date_format(InvoiceDate, '%Y-%m-01') as PurchaseMonth,
       date_format(min(InvoiceDate) over(partition by CustomerID order by InvoiceDate), '%Y-%m-01') as FirstPurchaseMonth,
       Revenue
from cte1),

-- Get Cohort Month

cte3 as (
select InvoiceNo, FirstPurchaseMonth,
       concat('Month_', timestampdiff(month, FirstPurchaseMonth, PurchaseMonth)) as CohortMonth
from cte2)

-- Perform the final query to pivot and count invoices by cohort months

select FirstPurchaseMonth,
       count(distinct if(CohortMonth = 'Month_0', InvoiceNo, null)) as Month_0,
       count(distinct if(CohortMonth = 'Month_1', InvoiceNo, null)) as Month_1,
       count(distinct if(CohortMonth = 'Month_2', InvoiceNo, null)) as Month_2,
       count(distinct if(CohortMonth = 'Month_3', InvoiceNo, null)) as Month_3,
       count(distinct if(CohortMonth = 'Month_4', InvoiceNo, null)) as Month_4,
       count(distinct if(CohortMonth = 'Month_5', InvoiceNo, null)) as Month_5,
       count(distinct if(CohortMonth = 'Month_6', InvoiceNo, null)) as Month_6,
       count(distinct if(CohortMonth = 'Month_7', InvoiceNo, null)) as Month_7,
       count(distinct if(CohortMonth = 'Month_8', InvoiceNo, null)) as Month_8,
       count(distinct if(CohortMonth = 'Month_9', InvoiceNo, null)) as Month_9,
       count(distinct if(CohortMonth = 'Month_10', InvoiceNo, null)) as Month_10,
       count(distinct if(CohortMonth = 'Month_11', InvoiceNo, null)) as Month_11
from cte3
group by FirstPurchaseMonth
order by FirstPurchaseMonth;

select * from order_cohort;



-- 1.1. Cohort Analysis based on Order Rate

create view order_cohort_rate as
with order_counts as (
    -- Select data from the existing order_cohort view
    select * 
    from order_cohort
),
-- Calculate the percentage of orders for each cohort month, add the % sign, and make 0.00% blank
cohort_rate as (
    select 
        FirstPurchaseMonth,
        case when round((Month_0 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_0 / Month_0) * 100, 0), '%') end as Month_0_rate,
        case when round((Month_1 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_1 / Month_0) * 100, 0), '%') end as Month_1_rate,
        case when round((Month_2 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_2 / Month_0) * 100, 0), '%') end as Month_2_rate,
        case when round((Month_3 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_3 / Month_0) * 100, 0), '%') end as Month_3_rate,
        case when round((Month_4 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_4 / Month_0) * 100, 0), '%') end as Month_4_rate,
        case when round((Month_5 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_5 / Month_0) * 100, 0), '%') end as Month_5_rate,
        case when round((Month_6 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_6 / Month_0) * 100, 0), '%') end as Month_6_rate,
        case when round((Month_7 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_7 / Month_0) * 100, 0), '%') end as Month_7_rate,
        case when round((Month_8 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_8 / Month_0) * 100, 0), '%') end as Month_8_rate,
        case when round((Month_9 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_9 / Month_0) * 100, 0), '%') end as Month_9_rate,
        case when round((Month_10 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_10 / Month_0) * 100, 0), '%') end as Month_10_rate,
        case when round((Month_11 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_11 / Month_0) * 100, 0), '%') end as Month_11_rate
    from order_counts
)
select * from cohort_rate;

select * from order_cohort_rate;




-- 2. Cohort Analysis Based on Customer Counts


-- Prepare Data

create view customer_cohort as 
with cte1 as (
select InvoiceNo, CustomerID, InvoiceDate, round((Quantity * UnitPrice), 2) as Revenue
from retail
where CustomerID is not null), 

-- Get Purchase Month and 1st Purchase Month

cte2 as (
select InvoiceNo, CustomerID, InvoiceDate,
       date_format(InvoiceDate, '%Y-%m-01') as PurchaseMonth,
       date_format(min(InvoiceDate) over(partition by CustomerID order by InvoiceDate), '%Y-%m-01') as FirstPurchaseMonth,
       Revenue
from cte1),

-- Get Cohort Month

cte3 as (
select CustomerID, FirstPurchaseMonth,
       concat('Month_', timestampdiff(month, FirstPurchaseMonth, PurchaseMonth)) as CohortMonth
from cte2)

-- Final Query: Count distinct customers in each cohort for subsequent months

select FirstPurchaseMonth,
       count(distinct if(CohortMonth = 'Month_0', CustomerID, null)) as Month_0,
       count(distinct if(CohortMonth = 'Month_1', CustomerID, null)) as Month_1,
       count(distinct if(CohortMonth = 'Month_2', CustomerID, null)) as Month_2,
       count(distinct if(CohortMonth = 'Month_3', CustomerID, null)) as Month_3,
       count(distinct if(CohortMonth = 'Month_4', CustomerID, null)) as Month_4,
       count(distinct if(CohortMonth = 'Month_5', CustomerID, null)) as Month_5,
       count(distinct if(CohortMonth = 'Month_6', CustomerID, null)) as Month_6,
       count(distinct if(CohortMonth = 'Month_7', CustomerID, null)) as Month_7,
       count(distinct if(CohortMonth = 'Month_8', CustomerID, null)) as Month_8,
       count(distinct if(CohortMonth = 'Month_9', CustomerID, null)) as Month_9,
       count(distinct if(CohortMonth = 'Month_10', CustomerID, null)) as Month_10,
       count(distinct if(CohortMonth = 'Month_11', CustomerID, null)) as Month_11
from cte3
group by FirstPurchaseMonth
order by FirstPurchaseMonth;

select * from customer_cohort;



-- 2.1. Cohort Analysis based on Customer Rate

create view customer_cohort_rate as
with customer_counts as (
    -- Select data from the existing customer_cohort view
    select * 
    from customer_cohort
),
-- Calculate the percentage of customers for each cohort month and format with 0 decimal points
cohort_rate as (
    select 
        FirstPurchaseMonth,
        case when round((Month_0 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_0 / Month_0) * 100, 0), '%') end as Month_0_rate,
        case when round((Month_1 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_1 / Month_0) * 100, 0), '%') end as Month_1_rate,
        case when round((Month_2 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_2 / Month_0) * 100, 0), '%') end as Month_2_rate,
        case when round((Month_3 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_3 / Month_0) * 100, 0), '%') end as Month_3_rate,
        case when round((Month_4 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_4 / Month_0) * 100, 0), '%') end as Month_4_rate,
        case when round((Month_5 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_5 / Month_0) * 100, 0), '%') end as Month_5_rate,
        case when round((Month_6 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_6 / Month_0) * 100, 0), '%') end as Month_6_rate,
        case when round((Month_7 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_7 / Month_0) * 100, 0), '%') end as Month_7_rate,
        case when round((Month_8 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_8 / Month_0) * 100, 0), '%') end as Month_8_rate,
        case when round((Month_9 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_9 / Month_0) * 100, 0), '%') end as Month_9_rate,
        case when round((Month_10 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_10 / Month_0) * 100, 0), '%') end as Month_10_rate,
        case when round((Month_11 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_11 / Month_0) * 100, 0), '%') end as Month_11_rate
    from customer_counts
)
select * from cohort_rate;

select * from customer_cohort_rate;




-- 3. Cohort Analysis Based on Revenue

-- Prepare Data

create view revenue_cohort as 
with cte1 as (
select InvoiceNo, CustomerID, InvoiceDate, round((Quantity * UnitPrice), 0) as Revenue
from retail
where CustomerID is not null), 

-- Get Purchase Month and 1st Purchase Month

cte2 as (
select InvoiceNo, CustomerID, InvoiceDate,
       date_format(InvoiceDate, '%Y-%m-01') as PurchaseMonth,
       date_format(min(InvoiceDate) over(partition by CustomerID order by InvoiceDate), '%Y-%m-01') as FirstPurchaseMonth,
       Revenue
from cte1),

-- Get Cohort Month

cte3 as (
select FirstPurchaseMonth as Cohort,
       concat('Month_', timestampdiff(month, FirstPurchaseMonth, PurchaseMonth)) as CohortMonth,
       Revenue
from cte2)

-- Perform the final query to pivot and count invoices by cohort months

select Cohort,
       sum(case when CohortMonth = 'Month_0' then Revenue else 0 end) as Month_0,
       sum(case when CohortMonth = 'Month_1' then Revenue else 0 end) as Month_1,
       sum(case when CohortMonth = 'Month_2' then Revenue else 0 end) as Month_2,
       sum(case when CohortMonth = 'Month_3' then Revenue else 0 end) as Month_3,
       sum(case when CohortMonth = 'Month_4' then Revenue else 0 end) as Month_4,
       sum(case when CohortMonth = 'Month_5' then Revenue else 0 end) as Month_5,
       sum(case when CohortMonth = 'Month_6' then Revenue else 0 end) as Month_6,
       sum(case when CohortMonth = 'Month_7' then Revenue else 0 end) as Month_7,
       sum(case when CohortMonth = 'Month_8' then Revenue else 0 end) as Month_8,
       sum(case when CohortMonth = 'Month_9' then Revenue else 0 end) as Month_9,
       sum(case when CohortMonth = 'Month_10' then Revenue else 0 end) as Month_10,
       sum(case when CohortMonth = 'Month_11' then Revenue else 0 end) as Month_11
from cte3
group by Cohort
order by Cohort;

select * from revenue_cohort;



-- 3.1 Cohort Analysis for Revenue Rate
create view revenue_cohort_rate as
with revenue_totals as (
    -- Select data from the existing revenue_cohort view
    select * 
    from revenue_cohort
),
-- Calculate the revenue percentage for each cohort month with 0 decimal points
cohort_rate as (
    select 
        Cohort,
        case when round((Month_0 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_0 / Month_0) * 100, 0), '%') end as Month_0_rate,
        case when round((Month_1 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_1 / Month_0) * 100, 0), '%') end as Month_1_rate,
        case when round((Month_2 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_2 / Month_0) * 100, 0), '%') end as Month_2_rate,
        case when round((Month_3 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_3 / Month_0) * 100, 0), '%') end as Month_3_rate,
        case when round((Month_4 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_4 / Month_0) * 100, 0), '%') end as Month_4_rate,
        case when round((Month_5 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_5 / Month_0) * 100, 0), '%') end as Month_5_rate,
        case when round((Month_6 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_6 / Month_0) * 100, 0), '%') end as Month_6_rate,
        case when round((Month_7 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_7 / Month_0) * 100, 0), '%') end as Month_7_rate,
        case when round((Month_8 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_8 / Month_0) * 100, 0), '%') end as Month_8_rate,
        case when round((Month_9 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_9 / Month_0) * 100, 0), '%') end as Month_9_rate,
        case when round((Month_10 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_10 / Month_0) * 100, 0), '%') end as Month_10_rate,
        case when round((Month_11 / Month_0) * 100, 0) = 0 then ''
             else concat(round((Month_11 / Month_0) * 100, 0), '%') end as Month_11_rate
    from revenue_totals
)
select * from cohort_rate;

select * from revenue_cohort_rate;