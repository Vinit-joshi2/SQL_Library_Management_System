-- Library Management System

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


