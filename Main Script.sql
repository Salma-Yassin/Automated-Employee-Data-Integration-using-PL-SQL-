-- Anonymous Block to insert the employees into Employees table 
Declare 
        cursor emp_cursor is
                    select * from employees_temp;
                    
          V_JOB_ID jobs.job_id%type;
          V_DEPARTMENT_ID DEPARTMENTS.DEPARTMENT_ID%type;
begin
        for emp_record in emp_cursor loop

            -- Email Validation 
             IF emp_record.email like '%@%' then

                    -- Convert hire date column into Date type 
                    emp_record.hire_date := to_date(emp_record.hire_date,'dd,mm,yyyy');
                    
                    -- Get Job Id
                    V_JOB_ID := EMP_CHECK.GET_JOB_ID(emp_record); 
                    
                    -- Get Department Id
                    V_DEPARTMENT_ID := EMP_CHECK.GET_DEPARTMENT_ID(emp_record);
                    
                     -- Insert Record into Employees Table 
                    INSERT INTO Employees 
                            ( FIRST_NAME, LAST_NAME, EMAIL, HIRE_DATE, JOB_ID, SALARY, DEPARTMENT_ID)
                    VALUES 
                            (emp_record.first_name , emp_record.last_name ,emp_record.email , EMP_RECORD.HIRE_DATE, V_JOB_ID, emp_record.salary, V_DEPARTMENT_ID );

             else 
                    dbms_output.put_line('Not a valid Email: '|| emp_record.first_name||' '||emp_record.last_name); -- don't insert the employee 
             end if; 
             
        end loop;
end;

--  Print Employees 
SELECT
    e.first_name,
    e.last_name,
    e.hire_date,
    j.job_title,
    e.salary,
    e.email,
    d.department_name,
    l.city
FROM (
    SELECT
        emp.first_name,
        emp.last_name,
        emp.hire_date,
        emp.job_id,
        emp.salary,
        emp.email,
        emp.department_id,
        ROW_NUMBER() OVER (ORDER BY emp.employee_id DESC) AS rn
    FROM
        employees emp
) e
JOIN jobs j ON e.job_id = j.job_id
JOIN departments d ON e.department_id = d.department_id
JOIN locations l ON d.location_id = l.location_id
WHERE e.rn <= 9;



