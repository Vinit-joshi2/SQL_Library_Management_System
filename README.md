# Library Management System using SQL Project 

## Project Overview

**Project Title**: Library Management System  
**Database**: `library_db`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/Vinit-joshi2/SQL_Library_Management_System/blob/main/library.jpeg)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/Vinit-joshi2/SQL_Library_Management_System/blob/main/library_erd.png)

- **Database Creation**: Created a database named `library_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
-- Creating branch table
create table branch(
	branch_id varchar(10) primary key,
	manager_id varchar(10),
	branch_address varchar(55),
	contact_no varchar(10)
)

alter table branch
alter column contact_no type varchar(25)

-- Creating employees table
create table employees(
	emp_id varchar(10) primary key,
	emp_name varchar(25),
	position varchar(25),
	salary int,
	branch_id varchar(25)	  -- FK
)

-- Creating books table

create table books(
	isbin varchar(20) primary key,
	book_title varchar(80),
	category varchar(10),
	rental_price float,
	status varchar(45),
	author varchar(35),
	publisher varchar(55)
)

alter TABLE books
alter column category type varchar(20)

-- Creating members table

create table members(
	member_id varchar(30) primary key,
	member_name varchar(45),
	member_address varchar(85),
	reg_date DATE
)

-- Creating issued details table

create table issued_status(
	issued_id varchar(15) primary key,
	issued_member_id varchar(15),  -- FK
	issued_book_name varchar(75),
	issued_date DATE,
	issued_book_isbn varchar(35), -- FK
	issued_emp_id varchar(10)    -- FK
)

-- Creating return status details table

create table return_status(

	return_id varchar(10) primary key,
	issued_id varchar(10),
	return_book_name varchar(75),
	return_date DATE,
	return_book_isbn varchar(20)
)


-- Foreign key 
alter table issued_status
add constraint fk_members
FOREIGN key (issued_member_id)
REFERENCES members(member_id)

alter table issued_status
add constraint fk_book
FOREIGN key (issued_book_isbn)
REFERENCES books(isbin)

alter table issued_status
add constraint fk_employees
FOREIGN key (issued_emp_id)
REFERENCES employees(emp_id)


alter table employees
add constraint fk_branch
FOREIGN key (branch_id)
REFERENCES branch(branch_id)

alter table return_status
add constraint fk_return_status
FOREIGN key (issued_id)
REFERENCES issued_status(issued_id)

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
insert into books(isbin , book_title , category , rental_price , status , author , publisher)
VALUES
('978-1-60129-456-2' ,'To Kill a Mockingbird' , 'Classic' , 6.00 , 'yes' , 'Harpee Lee' , 'J.B . Lippincott & Co.')

```
**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = '125 Main St'
where member_id = 'C101'
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS107' from the issued_status table.

```sql
delete from issued_status
where issued_id = 'IS107'

```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
select * from issued_status
where issued_emp_id = 'E101'

```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
select 
	issued_emp_id,
	count(issued_id) as total_book_issued
from issued_status
group by issued_emp_id
HAVING count(issued_id) > 1
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
create table book_count
as
select 
	b.isbin , 
	b.book_title,
	count(ist.issued_id) as no_issued
from books as b
JOIN
issued_status as ist
on ist.issued_book_isbn = b.isbin
GROUP by 1 , 2

select * from book_count
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
select * from books
where category = 'Classic'
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
select 
	b.category,
	sum(rental_price) as income,
	count(*)
from books as b
JOIN
issued_status as ist
on ist.issued_book_isbn = b.isbin
GROUP by 1 
```

9. **List Members Who Registered in the Last 180 Days**:
```sql
insert into members(member_id , member_name , member_address , reg_date)
VALUES
('C121' , 'sam' , '145 Main St' , '2025-03-21'),
('C122' , 'john' , '125 Main St' , '2025-04-02')

select * 
from members
where  reg_date >= current_date - interval '180 Days'

```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
select 
	e1.*,
	b.manager_id,
	e2.emp_name as manager

from employees as e1
join 
branch as b
on b.branch_id = e1.branch_id
join
employees as e2
on b.manager_id = e2.emp_id
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
create table book_price_greater_7
as
select * from books
where rental_price > 7

select * from book_price_greater_7
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
select  
	distinct ist.issued_book_name

from issued_status as ist
left join
return_status as rs
on ist.issued_id = rs.issued_id
where rs.return_id is NUll
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
select 
	ist.issued_member_id ,
	m.member_name,
	bk.book_title,
	ist.issued_date,
	-- rs.return_date,
	current_date - ist.issued_date as over_dues

from issued_status as ist
join  members as m
on m.member_id = ist.issued_member_id
join 
books as bk
on bk.isbin = ist.issued_book_isbn
left join 
return_status as rs
on rs.issued_id = ist.issued_id
where 
	rs.return_date is null
	and
	(current_date - ist.issued_date) > 30
order by 1
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql

-- Stored procedure
create or replace procedure add_return_record(p_return_id varchar(10) , p_issued_id varchar(10) , p_book_quality varchar(15))
Language plpgsql
as  $$
DECLARE
	
	v_isbn varchar(50);
	v_book_name varchar(80);

BEGIN
	--  inserting itno return based on user input
	insert into return_status(return_id , issued_id , return_date , book_quality)
	values
		(p_return_id ,p_issued_id , CURRENT_DATE , p_book_quality);


	select 
		issued_book_isbn ,
		issued_book_name
		INTO
		v_isbn , 
		v_book_name
	from issued_status
	where issued_id = p_issued_id;
	


	update books
	set status = 'yes'
	where isbin = v_isbn;

	Raise Notice 'Thnak You for returning the book: %', v_book_name;

END ;
$$


--  Test the procedure

select * from issued_status
where issued_id = 'IS135'

select * from books
where isbin = '978-0-307-58837-1'

select * from return_status
where issued_id = 'IS135'

--  Calling the procedure
call add_return_record('RS138' ,'IS135' , 'Good')


```




**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
create table branch_reports
as
select 
	b.branch_id,
	b.manager_id,
	count(ist.issued_id) as number_book_issued,
	count(rs.return_id) as number_book_return,
	sum(bk.rental_price) as total_revenue
	
from issued_status as ist
join employees as e
on e.emp_id = ist.issued_emp_id
join branch as b
on e.branch_id = b.branch_id
left join
return_status as rs
on rs.issued_id = ist.issued_id
join books as bk
on ist.issued_book_isbn = bk.isbin
group by 1 , 2

select * from branch_reports
```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql

create table active_members
as
select * from members
where member_id in (
	select  
		distinct issued_member_id
	from issued_status
	WHERE	
		issued_date >= current_date - interval '2 month'
	)

select * from active_members


```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
select * from employees  -- emp_id + emp_name + branch_id
select * from branch      -- branch_id
select * from issued_status  --- issued_id + issued_emp_id
select * from books   -- isbin + book_title

select 
	e.emp_name,
	b.*,
	count(ist.issued_id) as number_of_book_issued
	
from employees as e
join branch as b 
on e.branch_id = b.branch_id
join issued_status as ist
on ist.issued_emp_id = e.emp_id
join books as bk
on bk.isbin = ist.issued_book_isbn
group by 1,2
order by 3 desc
limit 3
```

**Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    

```sql

select * from members -- member_id  + mamber_name
select * from books -- isbin + book_title
select * from issued_status -- issued_id + issued_member_id + issued_book_isbin
select * from return_status -- issued_id + return_book_isbin + book_quality


select 
	m.member_name,
	bk.book_title,
	rs.book_quality,
	count(rs.issued_id) as issued_book
	
from members as m
join  issued_status as ist
on m.member_id = ist.issued_member_id
join books as bk
on bk.isbin = ist.issued_book_isbn
join return_status as rs
on rs.issued_id = ist.issued_id

group by 1 ,2,3
having 
	rs.book_quality = 'Damaged'


```




**Task 19: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

--Stored Procedure
create or replace procedure issued_book(p_issued_id varchar(10) , p_issued_member_id varchar(30) , p_issued_book_isbn varchar(50), p_employee_id varchar(10))
Language plpgsql
as  $$

DECLARE	
		
	v_status varchar(10);

begin

	-- checking if the book is available 'yes'
	select 
		status  
		into 
		v_status
		
	from books
	where isbin = p_issued_book_isbn;

	if v_status = 'yes' then

		insert into issued_status(issued_id , issued_member_id , issued_date , issued_book_isbn , issued_emp_id)
		values
		(p_issued_id , p_issued_member_id , CURRENT_DATE , p_issued_book_isbn ,p_employee_id);

		update books
			set status = 'no'
		where isbin = p_issued_book_isbn;

		RAISE NOTICE 'Book records added successfully for book isbn : % ' , p_issued_book_isbn;
		

	else
		
		RAISE NOTICE 'Sorry to inform you the book you have  requested is unavailable : % ' , p_issued_book_isbn;

		

	end if;

end 
$$


--Testing the fucntion
select * from books
where isbin = '978-0-553-29698-2'
select * from issued_status

-- "978-0-553-29698-2" - yes
-- "978-0-375-41398-8" - no


-- Calling the procedure
call  issued_book('IS155' , 	'C108' , '978-0-553-29698-2' , 'E104')

-- Calling the procedure
call  issued_book('IS156' , 	'C108' , '978-0-375-41398-8' , 'E104')


```


## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.


Thank you for your interest in this project!
