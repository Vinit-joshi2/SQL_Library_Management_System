select count(*) from books
select * from members
select * from issued_status
select * from books
-- Project JSON_QUERY


-- CRUD operation
--  Q1 - Create a New book Record - "978-1-60129-456-2" , "To Kill a Mockingbird" , "Classic" , 6.00 , "yes" ,"Harpee Lee" 
--                                   "J.B . Lippincott & Co."


insert into books(isbin , book_title , category , rental_price , status , author , publisher)
VALUES
('978-1-60129-456-2' ,'To Kill a Mockingbird' , 'Classic' , 6.00 , 'yes' , 'Harpee Lee' , 'J.B . Lippincott & Co.')



--  Q2 -- Update am Existing Member's address
UPDATE members
SET member_address = '125 Main St'
where member_id = 'C101'


--  Q3 - Delete a record from the Issued status TABLE
--       objective - Delete the record with issued_id = ISOO7 from the isuued table

delete from issued_status
where issued_id = 'IS107'


-- Q4 - Retrieve all books issued by a specific employee -- objective  select all books issued by the employee with emp_id = "E101"

select * from issued_status
where issued_emp_id = 'E101'


-- Q5 - List members who have issued More than book -- Objective -- use Group By to find members who have issued more than one books.book_title

select 
	issued_emp_id,
	count(issued_id) as total_book_issued
from issued_status
group by issued_emp_id
HAVING count(issued_id) > 1

-- CTAS
-- Q6 - create summay tables -- used CTAS to generate new tables based on query results - each book and total_book_issued_cnt


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


--  Q7  - Retrieve All Books in a specifc category

select * from books
where category = 'Classic'

--  Q8  Find Total Rental income by category
select 
	b.category,
	sum(rental_price) as income,
	count(*)
from books as b
JOIN
issued_status as ist
on ist.issued_book_isbn = b.isbin
GROUP by 1 

-- Q9 Members who Registered in the last 180 Days

insert into members(member_id , member_name , member_address , reg_date)
VALUES
('C121' , 'sam' , '145 Main St' , '2025-03-21'),
('C122' , 'john' , '125 Main St' , '2025-04-02')

select * 
from members
where  reg_date >= current_date - interval '180 Days'


--  Q10 List Employees with Their Branch Mnanager's Name and their branch details

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


--  Q11 -- create a table of books with rental price above a certain threshold 7 USD

create table book_price_greater_7
as
select * from books
where rental_price > 7

select * from book_price_greater_7


-- Q12  -- Retrieve the list of Books Not yet Returned
select  
	distinct ist.issued_book_name

from issued_status as ist
left join
return_status as rs
on ist.issued_id = rs.issued_id
where rs.return_id is NUll

-- --------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------
select * from books
select * from members
select * from employees
select * from branch
select * from issued_status
select * from return_status

/* Q13 -- 
 	Identify Members with Overdue Books
	Write a query to identify members who have overdue books (assume a 30-day return period). 
	Display the member's_id, member's name, book title, issue date, and days overdue.

*/

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


/*
		Q14 --
		Update Book Status on Return**  
		Write a query to update the status of books in the books table to "Yes" 
		when they are returned (based on entries in the return_status table).
		
*/

select * from books
where isbin = '978-0-451-52994-2'



update books
set status = 'no'
where isbin = '978-0-451-52994-2'

select  * from return_status
where issued_id = 'IS130'

insert into return_status(return_id , issued_id , return_date , book_quality)
VALUES	
	('RS125' , 'IS130' , CURRENT_DATE , 'Good')


update books
set status = 'yes'
where isbin = '978-0-451-52994-2'

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




/*
		Q15 --
		Branch Performance Report**  
		Create a query that generates a performance report for each branch, 
		showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

		
*/

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


/*

	Q16 --
	CTAS: Create a Table of Active Members**  
	Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members 
	who have issued at least one book in the last 2 months.

*/

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


/*
		Q17 --
		Find Employees with the Most Book Issues Processed**  
		Write a query to find the top 3 employees who have processed the most book issues. 
		Display the employee name, number of books processed, and their branch.

*/

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


/*
	Q18 --
	Identify Members Issuing High-Risk Books**  
	Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. 
	Display the member name, book title, and the number of times they've issued damaged books.    

*/

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




/*
	Q19 --
		Stored Procedure
		Objective:
		Create a stored procedure to manage the status of books in a library system.
		
		Description:
		
			Write a stored procedure that updates the status of a book in the library based on its issuance. 
			The procedure should function as follows:
			The stored procedure should take the book_id as an input parameter.
			The procedure should first check if the book is available (status = 'yes').
			If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
			If the book is not available (status = 'no'), the procedure should return an error message indicating 
			that the book is currently not available.


*/

select * from books
select * from issued_status

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

