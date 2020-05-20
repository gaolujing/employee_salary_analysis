#find the average salary of female and male employees in each department

USE employees_mod;

SELECT 
	e.gender,
    AVG(s.salary) AS avg_salary,
    d.dept_name
FROM
	t_employees e
    JOIN 
    t_salaries s ON e.emp_no = s.emp_no
    JOIN
    t_dept_emp de ON s.emp_no = de.emp_no
    JOIN
    t_departments d ON de.dept_no = d.dept_no
GROUP BY e.gender, d.dept_no
ORDER BY d.dept_no;

#Find the lowest department number encountered in the 'dept_emp' table. Then, find the highest department number

SELECT MIN(de.dept_no) FROM t_dept_emp de;
SELECT MAX(de.dept_no) FROM t_dept_emp de;

SELECT COUNT(de.emp_no) 
FROM t_dept_emp de;  #answer is 331723

SELECT COUNT(distinct de.emp_no) 
FROM t_dept_emp de; #answer is 300144

#exercise 3

SELECT
    e.emp_no,  	
    (SELECT 
		MIN(dept_no) 
      FROM t_dept_emp de
      WHERE e.emp_no = de.emp_no) AS dept_no,
    CASE
		WHEN e.emp_no <= 10020 THEN 110022
		WHEN e.emp_no >= 10021 AND e.emp_no <= 10040 THEN 110039
        END AS manager
	
FROM t_employees e
WHERE e.emp_no <= 10040;
    
#Retrieve a list of all employees that have been hired in 2000.

SELECT * FROM t_employees e
WHERE YEAR(e.hire_date) = 2000;

#Retrieve a list of all employees from the ‘titles’ table who are engineers.

SELECT * FROM titles 
WHERE title LIKE '%Engineer%';

SELECT * FROM titles
WHERE title = 'Senior Engineer';

#Create a procedure that asks you to insert an employee number and that will obtain an output containing
#the same number, as well as the number and name of the last department the employee has worked in.
DELIMITER $$
CREATE procedure work_history(IN p_emp_no INTEGER) 
BEGIN
SELECT 
	e.emp_no,
    s.dept_no, 
	d.dept_name
FROM
employees e
JOIN
dept_emp s ON s.emp_no = e.emp_no
JOIN 
departments d ON s.dept_no = d.dept_no
WHERE p_emp_no = e.emp_no
	AND s.to_date = (SELECT 
				MAX(to_date)
	  FROM dept_emp 
      WHERE emp_no = p_emp_no);
END$$

DELIMITER ;

#How many contracts have been registered in the ‘salaries’ table with duration of more than one year and
#of value higher than or equal to $100,000? 

#Create a trigger that checks if the hire date of an employee is higher than the current date. If true, set the
#hire date to equal the current date. Format the output appropriately (YY-mm-dd).
Delimiter $$

CREATE TRIGGER check_hire_date
BEFORE insert on employees
FOR EACH ROW
BEGIN 
	IF NEW.hire_date > CURDATE() THEN
	SET NEW.hire_date = CURDATE();
	END IF;

END$$

Delimiter ;

DROP TRIGGER check_hire_date;

INSERT INTO employees VALUES('20000345', '1972-10-1', 'Lisa', 'Jones', 'F', '2020-5-20' );

SELECT * FROM employees
WHERE emp_no = 20000345;

#Define a function that retrieves the largest contract salary value of an employee. Apply it to employee
#number 11356
Delimiter $$
CREATE FUNCTION f_highest_salary(f_emp_no INT) RETURNS INT
DETERMINISTIC
BEGIN
DECLARE highest_salary INTEGER;
SELECT MAX(s.salary) INTO highest_salary
From salaries s
WHERE s.emp_no = f_emp_no;
RETURN highest_salary;
END$$

DELIMITER ;

# create a third function that also accepts a second
#parameter. Let this parameter be a character sequence. Evaluate if its value is 'min' or 'max' and based on
#that retrieve either the lowest or the highest salary, respectively (using the same logic and code structure
#from Exercise 9). If the inserted value is any string value different from ‘min’ or ‘max’, let the function
#return the difference between the highest and the lowest salary of that employee

DELIMITER $$

CREATE FUNCTION f_salary_query(f_emp_no INT, f_salary_limit VARCHAR(10)) RETURNS INT
DETERMINISTIC
BEGIN
DECLARE f_query_result INT;
SELECT 
	CASE
    WHEN f_salary_limit = 'min' THEN MIN(s.salary)
    WHEN f_salary_limit = 'max' THEN MAX(s.salary)
    ELSE MAX(s.salary) - MIN(s.salary)
    END AS query_result
INTO f_query_result
FROM salaries s
WHERE s.emp_no = f_emp_no;
RETURN f_query_result;
END$$
DELIMITER ;

SELECT f_salary_query(11356, 'min');
SELECT f_salary_query(11356, 'max');
SELECT f_salary_query(11356, 'n');