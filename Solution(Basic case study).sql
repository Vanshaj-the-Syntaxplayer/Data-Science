Create database Sql_cs_2

------------------------------------------------------------Data Preparation and Understanding-------------------------------------------------------

-- Q1. what is the total number of rows in each of the 3 tables in the database.

   select * from Customer                       ---total rows in customer table is 5647 rows----
   select * from prod_cat_info                  ---total rows in customer table is 23 rows----
   select * from Transactions                   ---total rows in customer table is  23,053 rows----

-- Q2. What is the total number of transaction that have a return.
  
  select count(transaction_id) as Number_of_transaction_return 
   from transactions where qty <0 

-- Q3. As you would have noticed, the dates provided across the datasets are not in a correct format.
-- As first steps, pls convert the date variables into valid date formats before procedding ahead. 

   select Dob,
   format(convert(date, dob,121), 'dd-MM-yyyy') as  New_Date
   from Customer

   --AND---

   select tran_date, format(convert(date, tran_date,121), 'dd-MM-yyyy') as New_Trans_Date
   from Transactions

-- Q4.	What is the time range of the transaction data available for analysis?
-- Show the output in number of days, months and years simultaneously in different columns.

   select datediff(day, min(tran_date), max(tran_date)) as Range_of_Day, 
   datediff(month, min(tran_date), max(tran_date)) as Range_of_Month,
   datediff(year, min(tran_date), max(tran_date)) as Range_of_Year
   from transactions

-- Q5. Which product category does the sub-category “DIY” belong to?

   select prod_cat 
   from prod_cat_info 
   where prod_subcat='DIY'


   -----------------------------------------------------------Data Analysis ----------------------------------------------------------------------------------------

--1.	Which channel is most frequently used for transactions?

   select Store_type, count(transaction_id) as Most_Channel_used 
   from Transactions 
   group by Store_type

--2.	What is the count of Male and Female customers in the database?
  select gender, count(customer_id) as Gender_Count  
  from Customer
  group by Gender

--3. From which city do we have the maximum number of customers and how many?
  select city_code, count(customer_id)  as Count_of_customers
  from Customer 
  group by city_code

--4.	How many sub-categories are there under the Books category?
  select prod_subcat as Sub_Categories_of_Books from prod_cat_info
  where prod_cat='books'
  group by prod_cat, prod_subcat

--5.	What is the maximum quantity of products ever ordered?
   select max(qty) as Max_Quantity_Ordered 
   from Transactions

--6.	What is the net total revenue generated in categories Electronics and Books?
   select  prod.prod_cat as category, sum(totaL_amt) as Total_Net_Revenue 
   from Transactions as trans
   inner join prod_cat_info as prod 
   on trans.prod_cat_code = prod.prod_cat_code and trans.prod_subcat_code = prod.prod_sub_cat_code
   where prod.prod_cat in ('electronics' ,'books')
   group by prod.prod_cat

--7.	How many customers have >10 transactions with us, excluding returns?
     select count(*) as Customers_Count
     from (
     select c.customer_id, count(c.customer_Id) as count_of_transaction
	 from customer as c
      inner join Transactions as trans
      on trans.cust_id = C.customer_Id 
      where trans.qty > 0 
      group by c.customer_Id
      having count(c.customer_Id)>10  ) as x 

--8. What is the combined revenue earned from the “Electronics” & “Clothing” categories, from “Flagship stores”?
    select prod.prod_cat as category, store_type ,sum(trans.total_amt) as Revenue_Combined 
    from Transactions as trans
    inner join prod_cat_info as prod
    on trans.prod_cat_code = prod.prod_cat_code and trans.prod_subcat_code = prod.prod_sub_cat_code
    where prod.prod_cat in ('electronics', 'clothing') and trans.Store_type = 'flagship store'
    group by prod.prod_cat, Store_type

--9. What is the total revenue generated from “Male” customers in “Electronics” category? 
-- Output should display total revenue by prod sub-cat.

       Select pci.prod_subcat as product_subcategory,
       sum(trans.total_amt) as total_revenue
       from transactions as  trans
       inner join prod_cat_info as pci  on trans.prod_cat_code = pci.prod_cat_code and trans.prod_subcat_code = pci.prod_sub_cat_code 
       inner join customer c on trans.cust_id = c.customer_id
       where pci.prod_cat = 'Electronics'
        AND c.gender = 'M'
      group by pci.prod_subcat,gender

--10.	What is percentage of sales and returns by product sub category; 
-- display only top 5 sub categories in terms of sales?


    select top 5 * from (
    Select
    pci.prod_subcat AS product_subcategory,
	sum(trans.total_amt) as sum ,
    sum(Case when trans.total_amt > 0 then trans.total_amt else 0 end) as [Total  Sub Category Sales],
    sum(Case when trans.total_amt < 0 then trans.total_amt else 0 end) as [Total  Sub Categoty returns],
    sum(Case when trans.total_amt > 0 then trans.total_amt else 0 end) / (sum(trans.total_amt)) * 100 as [Sales_percentage],
    sum(Case when trans.total_amt < 0 then trans.total_amt else 0 end) / (sum(trans.total_amt)) * 100 as [Returns Percentage]
    from transactions trans
    join prod_cat_info pci ON trans.prod_cat_code = pci.prod_cat_code AND trans.prod_subcat_code = pci.prod_sub_cat_code
    Group by pci.prod_subcat
    ) as x
    order by [Total  Sub Category Sales] desc


-- 11.	For all customers aged between 25 to 35 years find what is the net
-- total revenue generated by these consumers in last 30 days of transactions  from max transaction date available in the data?

  Select  Sum(trans.total_amt) AS Total_Revenue
  from transactions as trans
  Join customer as cust ON trans.cust_id = cust.customer_id
  Where cust.dob Between Dateadd(year, -35, getdate()) and Dateadd(year, -25, getdate())
  and trans.tran_date >= Dateadd(day, -30, (Select max(tran_date) from transactions))

--12.	Which product category has seen the max value of returns in the last 3 months of transactions?
 
  Select top 1 prod.prod_cat , Sum(trans.total_amt) as total_amt from Transactions as trans 
  join prod_cat_info as prod 
  on prod.prod_cat_code = trans.prod_cat_code
  where trans.total_amt < 0 and trans.tran_date >= dateadd(month, -3, ( select max(tran_date) from transactions))
  group by prod.prod_cat
  order by total_amt desc 


--13.	Which store-type sells the maximum products; by value of sales amount and by quantity sold?

    Select Top 1
    trans.store_type as [Type of Store],
    Sum(trans.total_amt) as Total_Sales_Amount,
    Sum(trans.qty) as Total_Quantity_Sold
    From transactions as trans
    Group By trans.store_type
    Order By Total_Sales_Amount Desc, Total_Quantity_Sold Desc


-- 14.	What are the categories for which average revenue is above the overall average.

  Select pro.prod_cat as category
  From prod_cat_info as pro
  Join transactions trans on pro.prod_cat_code = trans.prod_cat_code and trans.prod_subcat_code = pro.prod_sub_cat_code
  group by pro.prod_cat
  having Avg(trans.total_amt) > (Select Avg(total_amt) from transactions)


  --15.  Find the average and total revenue by each subcategory for the categories 
-- which are among top 5 categories in terms of quantity sold.

Select  
    pci.prod_subcat as Product_subcategory,
    Sum(t.total_amt) AS Total_revenue,
    Avg(t.total_amt) AS Average_revenue
From transactions as t
Join prod_cat_info as pci on t.prod_cat_code = pci.prod_cat_code and t.prod_subcat_code = pci.prod_sub_cat_code
Where pci.prod_cat IN (
    Select Top 5
        pci.prod_cat
    From transactions as trans
    Join prod_cat_info pci on trans.prod_cat_code = pci.prod_cat_code and trans.prod_subcat_code = pci.prod_sub_cat_code
    Group By pci.prod_cat
    Order By Sum(trans.qty) Desc
)
Group By  pci.prod_subcat
	