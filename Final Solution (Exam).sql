create database Exam_solution

select * from CustData
select * from TransactionData
select * from final_Data


alter table final_Data 
alter column dep4Amount float

-------Note: 
-------a. You are required to import the data into SQL Server
-------b. Drop the observations(rows) if MCN is null
-------or storeID is null or Cash_Memo_No
-------c. Join both tables considering Transaction
-------table as base table (Hint: left Join – Key variable is MCN/CustomerID)
-------and name the table as Final_Data
-------d. Calculate the discount variable using formula (Discount = TotalAmount-SaleAmount)
-------d. Filter the Final_Data using sample_flag=1
-------and export this data into Excel File and call this table as sample_data
-------e. Answer the following questions using Final_Data (output after step c)





delete TransactionData where MCN is null or Store_ID is null or Cash_Memo_No is null

select * into final_Data
from TransactionData t 
left join CustData c on t.MCN = c.New_Cust_ID

alter table final_data add discount float
update final_Data set discount =  TotalAmount - SaleAmount

select * into sample_data from (
select * from final_Data
where Sample_flag=1) as x
select * from sample_data

---Q1. Count the number of observations having any of the variables having null value/missing values?

select count(*) as Count_Null from final_Data where ItemCount is null or TransactionDate is null or TotalAmount is null or SaleAmount is null
or Cash_Memo_No is null or Dep1Amount is null or Dep2Amount is null or Dep3Amount is null or Dep4Amount is null or Store_ID is null
or MCN is null or CustID is null or Gender is null or Location is null or Age is null or Cust_seg is null or Sample_flag is null or SalePercent is null

-----Q2. How many customers have shopped? (Hint: Distinct Customers)

select count(Distinct New_Cust_ID) as No_Of_customers_Shopped from final_Data

------Q3.  How many shoppers (customers) visiting more than 1 store?
 select Count(*) as No_of_shoppers 
 from ( select New_Cust_ID
        from final_Data
        where New_Cust_ID IS NOT NULL
        group by New_Cust_ID
        having count(distinct Store_ID) > 1 ) as X

-------Q4.   What is the distribution of shoppers by day of the week? How the customer shopping behavior on each day of week? 
-------(Hint: You are required to calculate number of customers, number of transactions, total sale amount, total quantity etc.. by each week day).
select FORMAT(TransactionDate,'dddd') as Day_of_Week,
       Count(distinct new_cust_id) as NO_OF_Customers,
	   Count(*) as Number_of_Transactions,
	   Sum(saleAmount) as Total_SaleAmount,
	   Sum(ItemCount) as Total_Quantity
from final_Data
group by FORMAT(TransactionDate, 'dddd')
order by FORMAT(TransactionDate, 'dddd')

------ Q5. What is the average revenue per customer/average revenue per customer by each location?

select  new_cust_Id, AVG(TotalAmount) as Average_Revenue_per_customer from final_Data
group by New_Cust_ID
order by Average_Revenue_per_customer 

select location , New_Cust_ID, AVG(TotalAmount) as Revenue_by_Location from final_Data
where Location is not null
group by Location, New_Cust_ID

-------Q6. Average revenue per customer by each store etc?

SELECT STORE_ID, ROUND(AVG(SALEAMOUNT*ITEMCOUNT),2) AS AVG_REVENUE
FROM FINAL_DATA GROUP BY STORE_ID


-------Q7. Find the department spend by store wise?

SELECT
    Store_ID AS Store,
    sum(Dep1Amount) AS Spend_of_Dep1,
    sum(Dep2Amount) AS Spend_of_Dep2,
    sum(Dep3Amount) AS Spend_of_Dep3,
    sum(Dep4Amount) AS Spend_of_Dep4
from
    final_Data
group by
    Store_ID


-------Q8.What is the Latest transaction date and Oldest Transaction date? (Finding the minimum and maximum transaction dates)

select min(transactionDate) as Min_Transaction_Date , max(transactionDate) as Max_Transation_Date from final_Data

-------Q9. How many months of data provided for the analysis?
Select
    Datediff(Month, Min(TransactionDate), Max(TransactionDate)) + 1 As NumberOfMonths
From Final_Data


 -------Q10. Find the top 3 locations interms of spend and total contribution of sales out of total sales?
select Top 3 [location] ,
             sum(saleAmount) as Total_spend_of_location,
			 sum(saleAmount)/ ( select sum(saleAmount) from final_Data) * 100 as Contribution_of_Percentage
			 from final_Data
			 group by Location
			 order by Total_spend_of_location desc


-------Q11.. Find the customer count and Total Sales by Gender?
select gender,count(distinct New_Cust_ID) as Count_of_Customers , sum(saleAmount) as Total_Sales 
from final_Data
where gender is not null
group by Gender 

-------Q12. What is total  discount and percentage of discount given by each location?
select location , sum(Discount) as Total_Discount,( sum(Discount)/sum(totalAmount))*100 as Percentage_of_Discount
from final_Data
where Location is not null
group by Location
       

-------Q13. Which segment of customers contributing maximum sales?

select cust_seg , sum(SaleAmount) as Max_Sales
from final_Data
where Cust_seg is not null
group by Cust_seg
order by Max_Sales desc

-------Q14. What is the average transaction value by location, gender, segment?

select Location, gender, Cust_seg , AVG(SaleAmount) as Average_Transaction 
from final_Data
where location is not null

group by Location,Gender,Cust_seg

--------Q15. Create Customer_360 Table with below columns.
--------
--------Customer_id,
--------Gender,
--------Location,
--------Age,
--------Cust_seg,
--------No_of_transactions,
--------No_of_items,
--------Total_sale_amount,
--------Average_transaction_value,
--------TotalSpend_Dep1,
--------TotalSpend_Dep2,
--------TotalSpend_Dep3,
--------TotalSpend_Dep4,
--------No_Transactions_Dep1,
--------No_Transactions_Dep2,
--------No_Transactions_Dep3,
--------No_Transactions_Dep4,
--------No_Transactions_Weekdays,
--------No_Transactions_Weekends,
--------Rank_based_on_Spend,
--------Decile

--------etc.



select * into Customer_360 from (
select MCN as Customer_Id , gender , [location], age, Cust_seg, count(Cash_Memo_No) as No_of_Transaction, sum(itemcount) as No_of_items,
sum(saleAmount) as Total_sales_Amount,
AVG(saleAmount) as Average_Transaction_Value, sum(dep1Amount) as TotalSpend_Dep1, 
sum(dep2Amount) as TotalSpend_Dep2,  sum(dep3Amount) as  TotalSpend_Dep3,
 sum(dep4Amount) as  TotalSpend_Dep4, 
 SUM(case when Dep1Amount>0 then 1 else 0 end) as No_of_Transaction_dep1,
 SUM(case when Dep2Amount>0 then 1 else 0 end) as No_of_Transaction_dep2,
 SUM(case when Dep3Amount>0 then 1 else 0 end) as No_of_Transaction_dep3,
 SUM(case when Dep4Amount>0 then 1 else 0 end) as No_of_Transaction_dep4,
 sum(Case when FORMAT(TransactionDate, 'dddd') in ('Monday','Tuesday','Wednesday','Thursday','Friday') Then 1 else 0 end) as No_of_Transactions_Weekdays,
 sum(Case when FORMAT(TransactionDate, 'dddd') in ('Saturday','Sunday') Then 1 else 0 end) as No_of_Transactions_Weekends,
 RANK() over (Order by sum(saleamount) desc) as Rank_based_on_spend,
 Ntile(10) over (order by sum(saleamount) desc) as Decile 
 from final_Data
 group by MCN ,gender,location, age , cust_seg  ) as X
 select * from Customer_360
 



   















