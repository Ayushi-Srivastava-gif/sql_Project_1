-- Create employee database
/*
1.Create a database named employee, then import data_science_team.csv proj_table.csv and emp_record_table.csv into the employee database from the given resources.
*/

CREATE DATABASE IF NOT EXISTS employee;
USE employee;

SELECT * FROM employee.data_science_team;

SELECT * FROM employee.emp_record_table;

SELECT * FROM employee.proj_table;

/*
3.Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, and DEPARTMENT from the employee record table, 
and make a list of employees and details of their department.
*/

SELECT  EMP_ID, FIRST_NAME, LAST_NAME, GENDER,DEPT
FROM emp_record_table;

/*
4.Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPARTMENT, and EMP_RATING 
if the EMP_RATING is: 
⦁	less than two
⦁	greater than four 
⦁	between two and four
*/

-- less than two
SELECT  EMP_ID, FIRST_NAME, LAST_NAME, GENDER,DEPT,EMP_RATING  FROM emp_record_table
WHERE EMP_RATING>2;

-- greater than four
SELECT  EMP_ID, FIRST_NAME, LAST_NAME, GENDER,DEPT,EMP_RATING  FROM emp_record_table
WHERE EMP_RATING<4;

-- between two and four
SELECT  EMP_ID, FIRST_NAME, LAST_NAME, GENDER,DEPT,EMP_RATING  FROM emp_record_table
WHERE EMP_RATING BETWEEN 2 AND 4;

/*
5.Write a query to concatenate the FIRST_NAME and the LAST_NAME of employees in the Finance department 
from the employee table and then give the resultant column alias as NAME.
*/


select empl_id, concat(first_name,' ',last_name) as name1, concat_ws(‘-’, first_name,last_name) 
as name2 from emp_record_table where dept='Finance';

-- concat_ws() deal with null, separate symbol(space, comma,semicolon)




/*
6.Write a query to list only those employees who have someone reporting to them. 
Also, show the number of reporters (including the President).
*/

SELECT employee.EMP_ID,
       CONCAT(employee.FIRST_NAME, ' ', employee.LAST_NAME) AS Employee_Name,
       manager.MANAGER_ID,
       CONCAT(manager.FIRST_NAME, ' ', manager.LAST_NAME) AS Manager_Name,
       manager.ROLE AS ROLE
FROM emp_record_table AS employee
JOIN emp_record_table AS manager ON employee.MANAGER_ID = manager.EMP_ID;

/*
7.Write a query to list down all the employees from the healthcare and 
finance departments using union. Take data from the employee record table.
*/




SELECT EMP_ID
FROM emp_record_table
WHERE department = 'Healthcare'
UNION
SELECT EMP_ID
FROM employee_record
WHERE department = 'Finance';


/*
8.Write a query to list down employee details such as EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPARTMENT, and EMP_RATING grouped by dept. 
Also include the respective employee rating along with the max emp rating for the department.
*/

SELECT  m.EMP_ID,m.FIRST_NAME,m.LAST_NAME,m.ROLE,m.DEPT,m.EMP_RATING,max(m.EMP_RATING)
OVER(PARTITION BY m.DEPT)
AS "MAX_DEPT_RATING"
FROM emp_record_table m
ORDER BY DEPT;

/*
9.Write a query to calculate the minimum and the maximum salary of the employees in each role. 
Take data from the employee record table.
*/

SELECT EMP_ID, FIRST_NAME, LAST_NAME, ROLE, MAX(SALARY), MIN(SALARY)
FROM emp_record_table
WHERE ROLE IN("PRESIDENT","LEAD DATA SCIENTIST","SENIOR DATA SCIENTIST","MANAGER","ASSOCIATE DATA SCIENTIST","JUNIOR DATA SCIENTIST")
GROUP BY EMP_ID, FIRST_NAME, LAST_NAME, ROLE;

/*
10.Write a query to assign ranks to each employee based on their experience. 
Take data from the employee record table.
*/

SELECT EMP_ID,FIRST_NAME,LAST_NAME,EXP,
RANK() OVER(ORDER BY EXP) EXP_RANK
FROM emp_record_table;

/*
11.Write a query to create a view that displays employees in various countries whose salary is more than six thousand. 
Take data from the employee record table.
*/

CREATE VIEW new_employees_in_various_countries AS
SELECT EMP_ID, FIRST_NAME, LAST_NAME, COUNTRY, SALARY
FROM emp_record_table
WHERE SALARY > 6000;

SELECT *FROM employees_in_various_countries;

/*
12.Write a nested query to find employees with experience of more than ten years. Take data from the employee record table.
*/

select EMP_ID,FIRST_NAME,LAST_NAME, DEPT,ROLE
from emp_record_table 
where EMP_ID in (select EMP_ID
from emp_record_table 
where EXP > 10) ;


or 

select EMP_ID,FIRST_NAME,LAST_NAME, DEPT,ROLE
from emp_record_table 
where EMP_ID = ANY (select EMP_ID
from emp_record_table 
where EXP > 10) ;


/*
13.Write a query to create a stored procedure to retrieve the details of the employees whose experience is more than three years. 
Take data from the employee record table.
*/

DELIMITER //
CREATE procedure EMP_EXP_MAX()
BEGIN
SELECT EMP_ID, FIRST_NAME,LAST_NAME,EXP, ROLE, DEPT
FROM emp_record_table 
WHERE EXP > 3 ;
END //
DELIMITER ;

CALL EMP_EXP_MAX ;


/*
14.Write a query using stored functions in the project table to check whether the job profile assigned to each employee in the data science 
team matches the organization’s set standard.
*/

-- Deterministic: same input always get same output

DELIMITER $$ 
CREATE FUNCTION EMP_PROFILE(EXP int)
returns varchar(255)
DETERMINISTIC  
begin
DECLARE Emp_Exp_Level VARCHAR(255);
#declaring an O/P variable to save the answer
IF EXP <= 2 THEN SET Emp_Exp_Level = 'JUNIOR DATA SCIENTIST';
ELSEIF EXP <= 5 THEN SET Emp_Exp_Level =  'ASSOCIATE DATA SCIENTIST';
ELSEIF EXP <= 10 THEN SET Emp_Exp_Level = 'SENIOR DATA SCIENTIST';  
ELSEIF EXP <= 12 THEN SET Emp_Exp_Level = 'LEAD DATA SCIENTIST';
ELSEIF EXP <= 20 THEN SET Emp_Exp_Level = 'MANAGER';
END IF; 
RETURN (Emp_Exp_Level) ;
END $$
DELIMITER ;

SELECT EMP_ID, DEPT, EXP, EMP_PROFILE(EXP) AS DESIGNATION
FROM data_science_team ;


/*
15.Create an index to improve the cost and performance of the query to find the employee whose FIRST_NAME is ‘Eric’ in the employee table after checking the execution plan.
*/

CREATE INDEX idx_first_name
ON emp_record_table(FIRST_NAME(20));
SELECT * FROM emp_record_table
WHERE FIRST_NAME='Eric';

/*
16.Write a query to calculate the bonus for all the employees, based on their ratings and salaries (Use the formula: 5% of salary * employee rating).
*/

SELECT emp_id, first_name, salary, emp_rating, (0.05 * salary * emp_rating) AS bonus
FROM emp_record_table;

/*
17.Write a query to calculate the average salary distribution based on the continent and country. Take data from the employee record table.
*/

select country, continent, roung(avg(salary),1) as avg_salary from emp_record_table group by country,continent
order by avg_salary;

or 
select country, continent, roung(avg(salary),1) as avg_salary from emp_record_table group by country, continent with rollup   # add sub total by country, continent
order by avg_salary;

or 
SELECT CONTINENT, COUNTRY, 
    ROUND(AVG(SALARY),1) AS AVG_SAL
FROM emp_record_table
GROUP BY CONTINENT, COUNTRY WITH ROLLUP
HAVING CONTINENT IS NOT NULL OR COUNTRY IS NULL
ORDER BY CONTINENT, COUNTRY;

