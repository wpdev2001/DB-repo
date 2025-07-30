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

-- fetching the details of employees with IDs that appear only once in the table.(with considering duplicate employee ids)
SELECT *
FROM Employees
WHERE EmployeeID IN (
    SELECT EmployeeID
    FROM Employees
    GROUP BY EmployeeID
    HAVING COUNT(*) = 1
);

-- creating new employees table to understand LIKE operator
CREATE TABLE Employees_New (
    ID INT,
    Name VARCHAR(50),
    Department VARCHAR(50)
);

INSERT INTO Employees_New (ID, Name, Department) VALUES
(1, 'Alice Johnson', 'Marketing'),
(2, 'Bob Smith', 'Sales'),
(3, 'Charlie Brown', 'HR'),
(4, 'David Lee', 'Finance'),
(5, 'Eva Thomas', 'Sales'),
(6, 'Frank Jones', 'HR'),
(7, 'George Martin', 'Engineering'),
(8, 'Helen Ford', 'Marketing'),
(9, 'Ian Black', 'Sales'),
(10, 'Julia Scott', 'Engineering');

SELECT * FROM Employees_New;

-- Name starts with 'A'
SELECT * FROM Employees_New WHERE Name LIKE 'A%';

-- Name ends with 'son'
SELECT * FROM Employees_New WHERE Name LIKE '%son';

-- Name contains 'Lee'
SELECT * FROM Employees_New WHERE Name LIKE '%Lee%';

-- Name starts with any 5-letter word and ends in 'Scott'
SELECT * FROM Employees_New WHERE Name LIKE '_____%Scott';

-- Department starts with 'Mar'
SELECT * FROM Employees_New WHERE Department LIKE 'Mar%';

-- Department ends with 'ing'
SELECT * FROM Employees_New WHERE Department LIKE '%ing';

-- Department has exactly 5 letters
SELECT * FROM Employees_New WHERE Department LIKE '_____';

-- Name starts with 'B' and ends with 'h'
SELECT * FROM Employees_New WHERE Name LIKE 'B%h';

-- Name has ‘o’ as second letter
SELECT * FROM Employees_New WHERE Name LIKE '_o%';

-- Finding Names that starts from letters A-D 
-- SELECT * FROM Employees_New WHERE Name LIKE '[A-C]%';

-- NOTE :
-- The pattern '[A-D]%' only works in SQL Server (T-SQL).
-- But in Oracle, MySQL, or PostgreSQL, this syntax is not supported by LIKE.
-- So in order to do that we need to use REGEXP
SELECT * FROM Employees_New
WHERE Name REGEXP '^[A-D]';

-- Adding 3 extra columns to learn REGEXP
ALTER TABLE Employees_New
ADD COLUMN Age INT AFTER Name,
ADD COLUMN Email VARCHAR(40),
ADD COLUMN Salary DECIMAL(10,2);

SELECT * FROM Employees_New;


UPDATE Employees_New
SET Age = 28, Email = 'alice@example.com', Salary = 100000
WHERE ID = 1;

-- In order to perform REGEXP operations we need the Age,Salary and Email fields data in the existing table
UPDATE Employees_New
SET Age = CASE ID 
			WHEN 1 THEN 28
            WHEN 2 THEN 30
            WHEN 3 THEN 26
            WHEN 4 THEN 29
            WHEN 5 THEN 31
            WHEN 6 THEN 32
            WHEN 7 THEN 27
            WHEN 8 THEN 33
            WHEN 9 THEN 25
            WHEN 10 THEN 30
            END,
	Email =  CASE ID
			WHEN 1 THEN 'alice@example.com'
            WHEN 2 THEN 'bob@example.com'
            WHEN 3 THEN 'charlie@example.com'
            WHEN 4 THEN 'david@example.com'
            WHEN 5 THEN 'emma@example.com'
            WHEN 6 THEN 'frank@example.com'
            WHEN 7 THEN 'grace@example.com'
            WHEN 8 THEN 'hank@example.com'
            WHEN 9 THEN 'ivy@example.com'
            WHEN 10 THEN 'john@example.com'
            END,
	Salary = CASE ID
              WHEN 1 THEN 100000
              WHEN 2 THEN 95000
              WHEN 3 THEN 90000
              WHEN 4 THEN 85000
              WHEN 5 THEN 88000
              WHEN 6 THEN 92000
              WHEN 7 THEN 87000
              WHEN 8 THEN 91000
              WHEN 9 THEN 86000
              WHEN 10 THEN 94000
           END
WHERE ID BETWEEN 1 AND 10;
