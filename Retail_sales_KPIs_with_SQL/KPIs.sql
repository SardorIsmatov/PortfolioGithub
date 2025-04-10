

--Calculating Company KPIs

--📊 Sales Performance KPIs

--•	Total Revenue(Sum of All sales)

select SUM([Total Sales]) as [Total Sales] from SalesTable

--•	Total Profit(Sum of profit)

select SUM(Profit) as [Total Profit] from SalesTable

--•	Profit Margin (%) (How much profit the company making from its revenue)

select round(SUM(Profit) / SUM([Total Sales])* 100,2) as [Profit Margin in %] from SalesTable

--•	Average Order Value (AOV)(Average amount a customer spends per order)

select SUM([Total Sales])/COUNT(OrderID) as AOV from SalesTable

--•	Year-over-Year (YoY) Growth 

select round(SUM([Total Sales])/(select SUM([Total Sales])  from SalesTable
where OrderDate between '2023-01-01' and '2023-12-31')* 100 - 100 ,2) as YoY
from SalesTable
where OrderDate between '2024-01-01' and '2024-12-31'

--There was decrease in 2024 (-4%)

select round(SUM([Total Sales])/(select SUM([Total Sales])  from SalesTable
where OrderDate between '2024-01-01' and '2024-12-31')* 100 - 100,2) as YoY
from SalesTable
where OrderDate between '2025-01-01' and '2025-12-31'
-- There was a little increase in 2025 (1.6%)

--📊 Customer Analysis KPIs 👥

--•	Total Customers  

select COUNT(CustomerID) as [CountofCustomers] from Customers

--•	Customer Retention Rate(Calculating for 2024)


select cast(COUNT(distinct CustomerID) as decimal(6,2))/
(select COUNT(distinct CustomerID )from SalesTable where YEAR(OrderDate)='2023') from SalesTable 
where YEAR(OrderDate) = '2024'

--•Analyzing Customer Segments by Revenue 

with Age_CTE as(
select *,case when Age between 15 and 24 then 'Youth' 
			when Age between 25 and 64 then 'Adults'
			when Age >= 65 then 'Seniors'
			end as AgeSegmentation from Customers)
select ac.AgeSegmentation, SUM([Total Sales]) as RevenueByAge from Age_CTE ac
join SalesTable st on ac.CustomerID = st.CustomerID
group by ac.AgeSegmentation
order by RevenueByAge desc


--•	Customer Lifetime Value (CLV) 

--First we need to find average purchase frequency(Total Orders/Unique Customers)

select  COUNT(OrderID)/COUNT(distinct CustomerID) from SalesTable

--Now Average Purhcase Value(Total Revenue/Total Orders)

select SUM([Total Sales])/COUNT(OrderID) from SalesTable

-- Customer Lifetime Value = Average Purhcase Value / average purchase frequency
--The result means how much puchased average customer

select  (COUNT(OrderID)/COUNT(distinct CustomerID))* 
(select SUM([Total Sales])/COUNT(OrderID) from SalesTable) as CLV from SalesTable


--•	Top-Selling Products 

select top 10 p.ProductName,COUNT(s.ProductID) as CountofOrders from SalesTable s
join Products p on s.ProductID = p.ProductID
group by p.ProductName
order by COUNT(s.ProductID) desc

--•	Stock Turnover Ratio (calculates how efficiently a company sells and replaces its inventory)

select SUM([Total Sales])/avg(distinct p.StockQuantity) from SalesTable s
join Products p on s.ProductID = p.ProductID

--•	Slow-Moving Products (We need ThereShold to find which products are Slow Mover or Fast Mover)
--I will take top 30% of SoldQuantities as Fast movers

with quantity_cte as (
    SELECT ProductID, SUM(Quantity) AS SumQuantity
    FROM SalesTable
    GROUP BY ProductID),
max_cte as (select MAX(SumQuantity) * 0.7 as Thereshold from quantity_cte)
	select q.ProductID, case when q.SumQuantity > m.Thereshold then 'Fast-Mover' else 'Slow-Mover' 
    end as MoverCategory
	from quantity_cte q
cross join max_cte m

--•	Sales by Store Type 

select s.StoreType, sum(st.[Total Sales]) as TotalSalesByType from SalesTable as st
join Stores as s on st.StoreID = s.StoreID
group by s.StoreType
order by TotalSalesByType desc


--•	Store Revenue Share 


with store_cte as (
select st.StoreID,StoreName,[Total Sales], SUM([Total Sales]) over () as  TotalSalesofCompany from SalesTable st
join Stores as s on st.StoreID = s.StoreID)
select StoreName, format(SUM([Total Sales])/TotalSalesofCompany * 100,'#.##') as [Store Revenue Share] from store_cte
group by StoreName,TotalSalesofCompany


--•	Best & Worst Performing Stores 

--By Customer Purchases

-- Top 3 Best with Performance 

with Count_Cte as (
select StoreID, COUNT(CustomerID) as CountOfCustomers from SalesTable
group by StoreID)
select top 3 s.StoreName,cc.CountOfCustomers from Count_Cte cc
join Stores s on cc.StoreID = s.StoreID
order by cc.CountOfCustomers desc

--Top 3 Worst with Performance

with Count_Cte as (
select StoreID, COUNT(CustomerID) as CountOfCustomers from SalesTable
group by StoreID)
select top 3 s.StoreName,cc.CountOfCustomers from Count_Cte cc
join Stores s on cc.StoreID = s.StoreID
order by cc.CountOfCustomers 








