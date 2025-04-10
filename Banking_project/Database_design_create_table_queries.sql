



create database Banking_System 

use Banking_System

create schema Core
 
--Customers – Stores bank customer information.


create table Core.Customers 
( CustomerID int Identity (1,1) Primary key, 
FullName varchar(100),
DateOfBirth date,
Email varchar(200),
PhoneNumber varchar(50),
Address varchar(max),
NationalID varchar(30),
TaxID varchar(30),
EmploymentStatus varchar(70),
AnnualIncome Decimal(15,2) , 
CreatedAt datetime default getdate() ,
UpdatedAt datetime default getdate() )


exec sp_help 'core.employees'

--Employees – Stores bank staff details.


create table core.Employees
(
EmployeeID int identity(1,1) constraint PK_Empolyee_id primary key,
BranchID int, 
FullName varchar(100) not null,
Postion varchar(100),
Department varchar(100),
Salary decimal(15,2),
HireDate date,
Status varchar(100)
)

--Creating all tables
-- Branches – Bank branch details.



create table core.Branches
(
BranchID int identity (1,1) constraint PK_Branch_ID primary key,
BranchName varchar(100),
Address varchar(max),
City varchar(100),
State varchar(50),
Country varchar(50),
ManagerId int constraint FK_Manager_ID foreign key references core.Employees(EmployeeID),
ContactNumber varchar(40)
)


alter table core.employees 
add constraint FK_Branch_ID foreign key (branchid) references core.branches(BranchId)


--Accounts – Stores customer bank accounts.


create table Core.Accounts(
AccountID int identity(1,1) constraint PK_Account_id primary key,
CustomerID int constraint FK_Customer_id foreign key references core.customers(customerID),
AccountType varchar(100) check (AccountType in 
('Savings', 'Checking', 'Business', 'Loan', 'Fixed Deposit', 'Salary', 'Student')),
Balance decimal(20,2),
Currency varchar(50),
Status varchar(50)  ,
BranchId int constraint FK_Branch_account_id foreign key references core.Branches(branchid),
CreatedDate date default getdate())


--Transactions – Logs all banking transactions (inc Core schema)




create  table Transactions(
TransactionID int identity(1,1) constraint PK_Transaction_id primary key,
AccountID int constraint FK_Account_transaction_id foreign key references core.Accounts(AccountId),
TransactionType varchar(100) check (TransactionType in ('Deposit','Withdrawal','Transfer', 'Bill Payment','Loan Payment',
'Interest Credit','POS Purchase','Online Purchase','Mobile Banking','International Transfer','Cashback','Fraud Alert',
'Salary Deposit','Refund','Card Payment')),
Amount decimal(20,2) check (Amount > 0),
Currency varchar(50) not null  ,
Date date not null,
Status varchar(100) check (Status in  ('Pending', 'Completed', 'Failed', 'Canceled', 
                                     'Processing', 'Rejected', 'Reversed', 'On Hold', 'Refunded')) ,
ReferenceNO bigint
)


alter schema core transfer dbo.transactions

--Creating Adress column to include longitude and latitude to calculate distance

create table Core.Customer_addresses (
AddressID int identity(1,1),
StreetName nvarchar(300),
Region nvarchar(100),
Latitude float,
Longitude float
)





--Digital Banking & Payments

create schema DigitalPay


--CreditCards – Customer credit card details.


create table DigitalPay.CreditCards (
CardID int identity(1, 1) constraint PK_Card_id primary key ,
CustomerID int constraint FK_customer_card_id foreign key  references core.customers(CustomerID),
CardNumber varchar(16) not null, 
CardType varchar(100) not null CHECK (CardType IN ('Debit Card','Credit Card',
'Prepaid Card','Virtual Card','Contactless Card',  
'Secured Credit Card','Student Card','Business Card',
'Corporate Card','Travel Card','Cashback Card','Retail Card')),
CVV varchar(3) not null, 
ExpiryDate Date not null, 
[Limit] date not null, 
Status varchar(50) not null check (Status in ('Active', 'Blocked', 'Expired', 'Pending')))


alter table digitalpay.creditcards 
add constraint CK_CardType check (cardtype in (
'Standard Credit Card',
'Gold Credit Card',
'Platinum Credit Card',
'Business Credit Card',
'Corporate Credit Card',
'Secured Credit Card',
'Student Credit Card',
'Cashback Credit Card',
'Rewards Credit Card',
'Travel Credit Card',
'Balance Transfer Credit Card',
'Low Interest Credit Card',
'Store Credit Card',
'Charge Card'))


--CreditCardTransactions – Logs credit card transactions.



create table DigitalPay.CreditCardTransactions (
TransactionID int identity (1, 1) constraint PK_Card_Transaction_id primary key, 
CardID int constraint FK_Card_ID foreign key references DigitalPay.CreditCards(CardID),
Merchant varchar(200), 
Amount decimal(20,2),
Currency varchar(5),
Date datetime default getdate(),  
Status varchar(100))




--OnlineBankingUsers – Customers registered for internet banking.


create table DigitalPay.OnlineBankingUsers (
UserID int identity(1,1) constraint PK_User_OnlineBanking_id primary key ,
CustomerID int constraint FK_OnlineBanking_Customers_id foreign key references Core.Customers(CustomerID),
UserName varchar(200) Unique not null,
PasswordHash varchar(300) not null ,
LastLogin DateTime default getdate() not null)


--BillPayments – Tracks utility bill payments.



create table DigitalPay.BillPayments(
PaymentID int identity(1,1) constraint PK_Payment_id primary key,
CustomerID int constraint FK_BillPayments_Customer_id references core.customers(CustomerId),
BillerName varchar(80) not null,
Amount decimal(20,2) not null,
Date datetime default getdate() not null,
Status varchar(100) not null 
)



--MobileBankingTransactions – Tracks mobile banking activity




create table DigitalPay.MobileBankingTransactions (
TransactionID int identity (1,1) constraint PK_MobileBanking_Transaction_id primary key,
CustomerID int constraint FK_MobileBanking_customer_id foreign key references Core.Customers(CustomerID),
DeviceID varchar(50) not null , 
AppVersion varchar(60) not null, 
TransactionType varchar(100) not null ,
Amount decimal (20,2) not null,
Date Datetime default getdate())


--Loans & Credit schema


create schema Loans


--Loans – Stores loan details.



create table Loans.Loans (
LoanID int identity(1,1) constraint PK_Loan_id primary key,
CustomerID int constraint FK_Loan_customer_id foreign key references Core.Customers(Customerid),
LoanType varchar(60) check (loantype in ('Mortgage', 'Personal', 'Auto', 'Business', 'Student')) ,
Amount decimal(35,2) check (amount > 0),
InterestRate decimal(6,2) check (interestrate >= 0 and interestrate <= 100),
StartDate date,
EndDate date, 
Status varchar(50) check  (Status IN ('Approved', 'Pending', 'Rejected', 'Closed')),
Constraint CK_EndDate check (Enddate > startdate)
)


-- LoanPayments – Tracks loan repayments.


create table Loans.LoanPayments(
PaymentID int identity(1,1) constraint PK_Payment_id primary key,
LoanID int constraint FK_LoanPayments_Loan_id foreign key references Loans.Loans(LoanID),
AmountPaid decimal(20,2) check (amountPaid >= 0),
PaymentDate DateTime not null, 
RemainingBalance decimal(20,2) check (RemainingBalance >= 0))


--CreditScores – Customer credit scores.

create table Loans.CreditScores (
CustomerID int constraint FK_CreditScore_Customer_id foreign key references Core.Customers(CustomerId),
CreditScore int check (CreditScore >= 300 and CreditScore <= 850),
UpdatedAt datetime default getdate())


--DebtCollection – Tracks overdue loans.


create table Loans.DebtCollection(
DebtID int identity(1,1) constraint PK_Debt_id primary key, 
CustomerID int constraint FK_DebtCollection_Customer_id foreign key references Core.customers(customerID),
AmountDue decimal(15,2) not null check (amountdue > 0),
DueDate date not null check (duedate < getdate()),
CollectorAssigned varchar(100)
)


-- Compliance & Risk Management (Schema Risk)

create schema Risk

--KYC (Know Your Customer) – Stores customer verification info.

create table Risk.KYC(
KYCID int identity(1,1) constraint PK_kyc_id primary key, 
CustomerID int constraint FK_kyc_customer_id foreign key references Core.Customers(CustomerID),
DocumentType varchar(50) check (DocumentType in 
('Passport', 'National ID', 'Driver License', 'Residence Permit', 'Utility Bill', 'Bank Statement')),
DocumentNumber varchar(100) not null Unique, 
VerifiedBy varchar(50) check (VerifiedBy in 
('Bank Employee', 'Automated System', 'Third-party Agency')))

--FraudDetection – Flags suspicious transactions.


create table Risk.FraudDetection(
FraudID int identity(1, 1) constraint PK_Fraud_id primary key,
CustomerID int constraint FK_FraudDetection_Customer_id references Core.Customers(CustomerID),
TransactionID int constraint FK_FraudDetection_Transaction_id references Core.Transactions, 
RiskLevel varchar(100) check (RiskLevel in ('Low', 'Medium', 'High', 'Critical')) not null,
ReportedDate datetime default getdate() not null)


--AML (Anti-Money Laundering) Cases – Investigates financial crimes.

create table Risk.AML_Cases (
CaseID int identity(1,1) constraint PK_AML_Case_id primary key, 
CustomerID int constraint FK_AML_Customer_id foreign key references Core.Customers(CustomerId),
CaseType varchar(50) check (CaseType in ('Suspicious Transaction', 'Structuring', 'Terrorism Financing', 
                                             'Fraud', 'Identity Theft', 'Tax Evasion', 
                                             'Shell Company Usage', 'Insider Trading')),
Status varchar(50) check (status in ('Open', 'Under Investigation', 'Escalated','Pending Review',
										'Closed - No Action', 'Closed - Action Taken') ) ,
InvestigatorID int not null)


--RegulatoryReports – Stores financial reports for regulators.

create table Risk.RegulatoryReports (
ReportID int identity(1, 1) constraint PK_Report_id primary key ,
ReportType varchar(100) check (ReportType in ('Balance Sheet Report','Income Statement','Liquidity Report',
		'Capital Adequacy Report','AML Compliance Report','Suspicious Transaction Report',
		'Tax Compliance Report','Fraud Investigation Report','Customer Data Protection Report')) ,
SubmissionDate date not null
)


--🧑‍💼 Human Resources & Payroll

create schema HR

--Departments – Stores company departments.

create table HR.Departments (
DepartmentID int identity(1, 1) constraint PK_Department_id primary key,
DepartmentName varchar(100) not null unique,
ManagerID int null constraint FK_Department_Manager_id foreign key references Core.employees(EmployeeID) 
on delete set null
)


-- Salaries – Employee payroll data.

create table HR.Salaries (
SalaryID int identity(1, 1) constraint PK_Salary_id primary Key,
EmployeeID int constraint FK_Salary_Employee_id foreign key references Core.Employees(ID),
BaseSalary decimal(15, 2) not null, 
Bonus decimal (15,2) default 0,
Deductions decimal(15, 2) default 0,    /*Deducations bu ushlab qolinadigan summalar, 
man bonus va deducation larni decimal(15,2)da berdim */
PaymentDate Datetime not null,
PayAfterDeductions decimal(15,2)
)



--EmployeeAttendance – Tracks work hours.

create table HR.EmployeeAttendance(
AttendanceID int identity(1, 1) constraint PK_Attendance_id primary key,
EmployeeID int constraint FK_Attendance_Employee_id references core.employees(employeeid),
CheckInTime datetime not null,	
CheckOutTime datetime,
[TotalHours] as concat(datediff(hour,CheckInTime, CheckOutTime),'h',
					datediff(minute, checkintime, checkouttime) % 60, 'm'),  
Constraint CK_Out_and_In_times check (CheckOutTime is null or CheckOutTime > Checkintime))


--📈 Investments & Treasury

create schema InvestTreasury


--Investments – Stores customer investment details.

create table InvestTreasury.Investments (
InvestmentID int identity(1, 1) constraint PK_Investment_id primary key,
CustomerID int constraint FK_Investment_Customer_id Foreign Key references Core.Customers(CustomerID),
InvestmentType varchar(200) check (InvestmentType in('Stocks','Bonds','Mutual Funds',
				'Real Estate','Fixed Deposits','CryptoCurrency','Commodities','Private Equity')),
Amount decimal(20, 2) not null,
ROI decimal(5,2) not null,
MaturityDate date not null check (MaturityDate > Getdate()))


--StockTradingAccounts – Customers trading stocks via bank.

create table InvestTreasury.StockTradingAccounts (
AccountID int identity(1,1) constraint PK_StockTrading_Account_id primary key, 
CustomerID int constraint FK_StockTrading_Customer_id foreign key references core.customers(CustomerId),
BrokerageFirm varchar(100) not null,
TotalInvested decimal(20,2) check (totalinvested is not null or totalinvested >= 0 ),
CurrentValue Decimal(20,2) check (CurrentValue  >= 0))

--ForeignExchange – Tracks forex transactions.

create table InvestTreasury.ForeignExchange (
FXID int identity(1,1) constraint PK_FX_id primary key, 
CustomerID int constraint FK_fx_customer_id foreign key references core.customers(CustomerID),
CurrencyPair Varchar(20) not null ,
ExchangeRate decimal(10,2) check (ExchangeRate > 0) ,
AmountExchenged decimal(15, 2) check (AmountExchenged > 0)
)


--📜 Insurance & Security

create schema Insurance 

-- InsurancePolicies – Customer insurance plans.

create table Insurance.InsurancePolicies(
PolicyID int identity(1,1) constraint PK_Policy_id primary key,
CustomerID int constraint FK_InsurancePolicy_Customer_id foreign key references Core.customers(CustomerID),
InsuranceType varchar(200),
PremiumAmount decimal (15,2) not null,
CoverageAmount decimal(15,2) not null
)

--Claims – Tracks insurance claims.

create table Insurance.Claims (
ClaimID int identity (1,1) constraint PK_Claim_id primary key ,
PolicyID int constraint FK_Policy_id foreign key references Insurance.InsurancePolicies(PolicyID),
ClaimAmount	decimal (15,2) not null,
Status	varchar(50) check (Status in ('Pending', 'Rejected', 'Approved'))	,
FiledDate Datetime not null)

--UserAccessLogs – Security logs for banking system users.

create table Insurance.UserAccessLogs (
LogID int identity(1,1) constraint PK_Log_id primary key,
UserID int not null,
ActionType varchar(100) not null check (ActionType in 
        ('Login', 'Logout', 'Failed Login Attempt', 'Password Change', 
         'Transaction Initiated', 'Transaction Approved', 'Access Denied')),
TimeStamp DateTime not null default getdate())


--CyberSecurityIncidents – Stores data breach or cyber attack cases.

create table Insurance.CyberSecurityIncidents (
IncidentID int identity(1, 1) constraint PK_Incident_id primary key,
AffectedSystem	varchar(100) not null , /*  (ForExample, Internet Banking, ATM Network, Core Banking System)	*/ 
ReportedDate DateTime default GetDate(), 
ResolutionStatus varchar(50) not null  check (ResolutionStatus in
('Investigating', 'Resolved', 'Unresolved', 'Escalated')))

--New Schema
--🛒 Merchant Services

create schema MerchantServices


--2️9️ Merchants – Stores merchant details for bank partnerships.

create table MerchantServices.Merchants (
MerchantID int identity (1,1) constraint PK_Merchant_id primary key,
MerchantName varchar(100) not null,
Industry	varchar(50) not null,
Location varchar(200) not null,
CustomerID int)


--3️0️ MerchantTransactions – Logs merchant banking transactions.

create table MerchantServices.MerchantTransactions (
TransactionID int identity(1, 1) constraint PK_Merchant_Transaction_id primary key, 
MerchantID int constraint FK_Transaction_Merchant_ID foreign key references MerchantServices.Merchants(MerchantID),
Amount	decimal(15, 2) not null, 
PaymentMethod varchar(50) not null	, 
Date datetime default getdate())



















--Information part

/*
select * from INFORMATION_SCHEMA.TABLES

select * from Core.Transactions

exec sp_help 'Core.Customers'
exec sp_help 'Core.Branches'
exec sp_help 'Core.Employees'
exec sp_help 'Core.Accounts'
exec sp_help 'Core.Transactions'
exec sp_help 'Digitalpay.CreditCards'
exec sp_help 'DigitalPay.CreditCardTransactions'
exec sp_help 'DigitalPay.OnlineBankingUsers'
exec sp_help 'DigitalPay.Billpayments'
exec sp_help 'DigitalPay.MobileBankingTransactions'
exec sp_help 'Loans.Loans'
exec sp_help 'Loans.LoanPayments'
exec sp_help 'Loans.CreditScores'
exec sp_help 'Risk.KYC'
exec sp_help 'Risk.RegulatoryReports'
exec sp_help 'HR.Departments'
exec sp_help 'HR.EmployeeAttendance'
exec sp_help 'InvestTreasury.Investments'
exec sp_help 'InvestTreasury.StockTradingAccounts'
exec sp_help 'InvestTreasury.ForeignExchange'
exec sp_help 'Insurance.InsurancePolicies'
exec sp_help 'Insurance.Claims'
exec sp_help 'Insurance.UserAccessLogs'
exec sp_help 'Insurance.CyberSecurityIncidents'
exec sp_help 'MerchantServices.Merchants'
exec sp_help 'MerchantServices.MerchantTransactions' */
