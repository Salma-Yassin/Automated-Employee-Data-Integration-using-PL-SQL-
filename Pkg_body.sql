-- Create a package body 
create or replace package body EMP_CHECK
is 
        Procedure INSERT_JOB(emp_record employees_temp%rowtype)
        is 
                V_JOB_ID jobs.job_id%type;
        begin
                -- Primary Key is Character -- so  create primary key from job title 
                 V_JOB_ID := upper(substr(emp_record.JOB_TITLE,1,3));
                        
                 INSERT INTO jobs
                            (JOB_ID, JOB_TITLE, MIN_SALARY, MAX_SALARY)
                 VALUES 
                            (V_JOB_ID , emp_record.JOB_TITLE, emp_record.salary, emp_record.salary); 
        end;
        
        Function GET_JOB_ID(emp_record employees_temp%rowtype) 
        RETURN jobs.job_id%type
        is
                    V_FLAG_JOB number(2);
                    V_JOB_ID jobs.job_id%type;
        begin 
                     -- Check on job title and get the job id 
                    SELECT COUNT(*)
                    INTO V_FLAG_JOB
                    FROM jobs
                    WHERE job_title = emp_record.JOB_TITLE;
                
                    IF V_FLAG_JOB = 0 THEN 
                        -- insert job into jobs table 
                           INSERT_JOB(emp_record);
                    END IF; 
                    
                    SELECT job_id
                    INTO V_JOB_ID
                    FROM jobs
                    WHERE job_title = emp_record.JOB_TITLE;
                    
                    return V_JOB_ID;
        end;
        
        Procedure INSERT_CITY(emp_record employees_temp%rowtype)
        is 
        begin 
                 INSERT INTO locations 
                             (CITY)
                 VALUES 
                             (emp_record.city);
        end;
        
        Function GET_LOCATION_ID(emp_record employees_temp%rowtype)
        Return LOCATIONS.Location_id%type
        is
                    V_FLAG_CITY  number(2);
                    V_LOCATION_ID      LOCATIONS.Location_id%type;
        begin 
                    -- Check that the city exist 
                    SELECT COUNT(*)
                    INTO V_FLAG_CITY
                    FROM locations
                    WHERE city = emp_record.city;
                        
                    IF V_FLAG_CITY = 0 THEN
                           -- Insert the city into locations table 
                           INSERT_CITY(emp_record);
                    END IF; 
                        
                    SELECT location_id
                    INTO V_LOCATION_ID
                    FROM locations
                    WHERE city = emp_record.city;
                        
                    return V_LOCATION_ID;
                        
        end;
        
        Procedure INSERT_DEPARTMENT(emp_record employees_temp%rowtype ,  V_LOCATION_ID   LOCATIONS.Location_id%type)
        is
        begin
                      INSERT INTO  departments
                                (DEPARTMENT_NAME, LOCATION_ID)
                        VALUES
                                (emp_record.department_name, V_LOCATION_ID);
        end;
        
        Function GET_DEPARTMENT_ID(emp_record employees_temp%rowtype)
        RETURN DEPARTMENTS.DEPARTMENT_ID%type
        is 
                    V_FLAG_DEPT number(2);
                    V_LOCATION_ID      LOCATIONS.Location_id%type;
                    V_DEPARTMENT_ID DEPARTMENTS.DEPARTMENT_ID%type;
        begin
                -- check on the department 
                    SELECT COUNT(*)
                    INTO V_FLAG_DEPT
                    FROM departments 
                    WHERE department_name = emp_record.department_name;
                
                    IF V_FLAG_DEPT = 0 THEN 
                        -- Get the Location Id first 
                        V_LOCATION_ID := GET_LOCATION_ID(emp_record);
                        -- Insert Department
                        INSERT_DEPARTMENT(emp_record ,  V_LOCATION_ID );   
                    end if;

                    SELECT department_id 
                    INTO V_DEPARTMENT_ID
                    FROM departments
                    WHERE department_name = emp_record.department_name;
                    
                    return V_DEPARTMENT_ID;
                         
        end;
        
end;
show errors
 
