
--KPIs

--Top 3 Customers with the Highest Total Balance Across All Accounts 

select top 3 * from Core.Accounts
order by Balance desc


--•	Customers Who Have More Than One Active Loan


select * from Core.Customers
where CustomerID in (
select CustomerID from Loans.Loans
where Status = 'Active'
group by customerID
having count(CustomerID) > 1)


--•	Transactions That Were Flagged as Fraudulent 



select * from Risk.FraudDetection

--Finding the most FraudDetected customers

select top 10 CustomerID, COUNT(*) as CountOfFrauds from Risk.FraudDetection
group by CustomerID
order by CountOfFrauds desc


---•	Total Loan Amount Issued Per Branch



select  BranchId  , MAX(Amount)as amount from Loans.Loans as l 
join (select CustomerID , BranchId  from Core.Accounts
group by CustomerID, BranchId) a on l.CustomerID = a.CustomerID
group by BranchId


--•	Customers who made multiple large transactions (above $10,000) within a short time frame (less than 1 hour apart)


Select distinct AccountID from Core.Accounts a
where a.AccountID IN 
(select t.AccountID  from Core.Transactions t
join Core.Transactions t1 on t.AccountID = t1.AccountID 
and t.TransactionID <> t1.TransactionID and t1.Date between t.Date and DATEADD(HOUR, 1, t.Date)
where t.Amount > 9000)






--•	Customers who have made transactions from different countries within 10 minutes, a common red flag for fraud.

Select distinct a.CustomerID from Core.Accounts a
where a.AccountID IN (select t.AccountID from Core.Transactions t
join Core.Transactions t1 on t.AccountID = t1.AccountID 
and t.TransactionID <> t1.TransactionID and t1.Date between t.Date and DATEADD(MINUTE, 10, t.Date))


--Customer Segment 

with CTE as (
select CustomerID, FullName, case when age < 27 then 'Young Adult' when age between 28 and 53 then 'Adult'
else  'Old' end as AgeRange, AnnualIncome, NumberOfAccounts, TotalBalance  from (
SELECT top 100 percent
    c.CustomerID,
    c.FullName,
    DATEDIFF(year, c.DateOfBirth, GETDATE()) AS Age,
    c.AnnualIncome,
    COUNT(a.AccountID) AS NumberOfAccounts,
    SUM(a.Balance) AS TotalBalance
FROM Core.Customers c
JOIN Core.Accounts a ON c.CustomerID = a.CustomerID
GROUP BY c.CustomerID, c.FullName, c.DateOfBirth, c.AnnualIncome
ORDER BY TotalBalance DESC) a)
select agerange , sum(AnnualIncome) as AnnualIncomeofTheGroup, sum(NumberOfAccounts) as NumberOfAccounts from CTE
group by AgeRange
order by AnnualIncomeofTheGroup desc

--Account counts by Age

SELECT top 100 percent
    c.CustomerID,
    c.FullName,
    DATEDIFF(year, c.DateOfBirth, GETDATE()) AS Age,
    c.AnnualIncome,
    COUNT(a.AccountID) AS NumberOfAccounts,
    SUM(a.Balance) AS TotalBalance
FROM Core.Customers c
JOIN Core.Accounts a ON c.CustomerID = a.CustomerID
GROUP BY c.CustomerID, c.FullName, c.DateOfBirth, c.AnnualIncome
ORDER BY TotalBalance DESC




--Counting Of ALL Rows

select  sum(RowCounts) as CountofRows from (SELECT top 100 percent t.name AS TableName, p.rows AS RowCounts
FROM sys.tables t
JOIN sys.partitions p ON t.object_id = p.object_id
WHERE p.index_id IN (0,1)
ORDER BY p.rows DESC) a

CountofRows
--------------------
2124961

(1 row affected)


Completion time: 2025-04-10T20:12:34.6254857+05:00

