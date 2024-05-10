-- Create a package specification 
create or replace package EMP_CHECK
is 
         Function GET_JOB_ID(emp_record employees_temp%rowtype ) RETURN jobs.job_id%type;
         
         Function GET_DEPARTMENT_ID(emp_record employees_temp%rowtype) RETURN DEPARTMENTS.DEPARTMENT_ID%type;
end;
show errors;