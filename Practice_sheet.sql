use test_db;

-- Create a table named "Employees" with columns for ID, Name, Age, and Salary. 
CREATE TABLE Employees(
ID INT PRIMARY KEY,
Name varchar(20) NOT NULL,
Age INT CHECK(Age>20),
Salary DECIMAL(10,2)
);

DESCRIBE Employees;

-- Add a new column "Department" to the "Employees" table.
ALTER TABLE Employees
ADD COLUMN Department INT;

ALTER TABLE Employees
ADD City VARCHAR(20);

-- Remove the "Department" column from the "Employees" table.
ALTER TABLE Employees 
DROP COLUMN Department;

-- Add a new column "Department" between Salary and City column to the "Employees" table.
ALTER TABLE Employees
ADD Department VARCHAR(20) AFTER Salary; -- Note: There is no BEFORE like keyword to use it over here!

-- Change the data type of the "Salary" column to INTEGER.
ALTER TABLE Employees
MODIFY Salary INT;

-- Add a unique constraint to the "Name" column to ensure no duplicate names in the existing employee table.
ALTER TABLE Employees
ADD CONSTRAINT Uc_Name UNIQUE(Name);

-- Create a new table "Departments" and link it to "Employees" using a foreign key.

CREATE TABLE Departments(
	Did INT PRIMARY KEY,
    Department_name VARCHAR(30)
    );
    
ALTER TABLE Employees
ADD COLUMN Dept_id INT,
ADD CONSTRAINT Depart_ID FOREIGN KEY (Dept_id) REFERENCES Departments(Did);

-- Adding foreign key while creating table
CREATE TABLE Student(
	Rno INT PRIMARY KEY,
    Sname VARCHAR(30),
    Dept_id INT,
    FOREIGN KEY(Dept_id) REFERENCES Departments(Did)
    );
    
-- NOTE: MYSQL doesn't allow inline foreign key definitions whereas Oracle does allow inline foreign key definitions
-- Dept_id INT REFERENCES Departments(Did)  ==> In Student table

-- Create an index on the Employees table "Name" column to improve query performance.

CREATE INDEX Name_Indx ON Employees(Name); -- While fetching the records it secretly uses its index for faster search

EXPLAIN SELECT * FROM Employees WHERE Name='Alice'; -- This query is showing how Name_Indx is used behind the scene

-- Remove the index "Name_Indx" from the "Employees" table.
DROP INDEX Name_Indx ON Employees;

-- Rename the "Employees" table to "Staff".
ALTER TABLE Employees RENAME TO Staff;

-- Set a default value of 0 for the "Salary" column.
SELECT * FROM STAFF;

ALTER TABLE STAFF
ALTER COLUMN Salary SET DEFAULT 0;

-- Remove the unique constraint "UC_Name" from the "Staff" table.
ALTER TABLE Staff
DROP CONSTRAINT Uc_Name;

-- Create a new schema named "HR". ==> // other way to create db
CREATE SCHEMA HR;

-- Move the "Staff" table to the "HR" schema.
RENAME TABLE test_db.Staff TO HR.Staff;
select * from HR.Staff;

-- Moving back Staff to its original DB(test_db)
RENAME TABLE HR.Staff TO test_db.Staff;
select * from test_db.Staff;


-- Insert employees from the "OldStaff" table into the "Staff" table.

	-- alterting staff as OldStaff and then moving it to new Staff
	ALTER TABLE Staff RENAME TO OldStaff;
    
    -- Creating Staff to copy the data from OldStaff
    CREATE TABLE Staff AS
    SELECT * FROM OldStaff
    WHERE 1=0;			-- This condition ensures no data copy while creating copy from OldStaff
    
    SELECT * FROM Staff;

INSERT INTO Staff(ID,Name,Age,Salary)
SELECT ID,Name,Age,Salary FROM OldStaff;

SELECT * FROM Staff;

-- Update salaries based on age: increase by 5000 if age > 30, otherwise increase by 2000.
UPDATE Staff
SET Salary = CASE
	WHEN Age>30 THEN Salary + 5000
    ELSE Salary + 2000
END;

-- Over here i have accedently ran and sql query which has udpated all staff salary to 0

ROLLBACK; -- did rollback but its not working because of auto commit enabled
SET autocommit = 0; -- disabled auto commit temporarily

-- Alternative to udpate the salary without using CASE
UPDATE Staff
SET Salary = Salary + IF(Age>30, 5000,2000);

-- Delete employees who belong to a department that has been marked as inactive.

CREATE TABLE Department_New(
	DepartmentId INT PRIMARY KEY,
    DepartmentName VARCHAR(20),
	IsActive TINYINT(1)
    );
    
CREATE TABLE EMPLOYEES(
	EmployeeId INT PRIMARY KEY,
    Name VARCHAR(20),
    Age INT,
    Salary DECIMAL(10,2),
    DepartmentId INT,
    FOREIGN KEY (DepartmentId) REFERENCES Department_New(DepartmentId)
    );

-- Insert Departments
INSERT INTO Department_New (DepartmentID, DepartmentName, IsActive)
VALUES
(1, 'HR', 1),
(2, 'Finance', 0),
(3, 'Engineering', 1),
(4, 'Support', 0);

-- Insert Employees
INSERT INTO Employees (EmployeeID, Name, Age, Salary, DepartmentID)
VALUES
(101, 'Alice', 28, 50000.00, 1),
(102, 'Bob', 35, 60000.00, 2),     -- Belongs to inactive dept
(103, 'Charlie', 40, 70000.00, 3),
(104, 'David', 30, 55000.00, 4),   -- Belongs to inactive dept
(105, 'Eva', 25, 48000.00, 1);

-- Ans

DELETE E 
FROM Employees E
JOIN Department_New D
ON E.DepartmentId=D.DepartmentId
WHERE IsActive=0;


-- My query (which isn't working)

-- DELETE FROM Employees
-- JOIN Department_New
-- ON Employees.DepartmentId = Department_New.DepartmentId
-- WHERE IsActive = 0;

-- will not work in MySQL because in MySQL, when using a JOIN in a DELETE, 
-- you must explicitly specify which table you're deleting from — especially
-- when multiple tables are involved.
