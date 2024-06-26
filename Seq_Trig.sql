-- Create sequence and trigger pairs  for the required tables  

SET SERVEROUTPUT ON
Declare 

-- Declare a temp variable to store sequence start 
            v_temp number(6);
            v_count number(2) := 0;
                
-- Get a cursor with all table names and their corresponding primary key column if it's numeric 
            cursor tables_cursor is
                select user_tab_columns.table_name as table_name, user_tab_columns.column_name as primary_key_column
                from user_tab_columns
                join user_cons_columns
                on user_tab_columns.table_name = user_cons_columns.table_name
                and user_tab_columns.column_name = user_cons_columns.column_name
                join user_constraints
                on user_cons_columns.constraint_name = user_constraints.constraint_name -- constraint name is unique on the level of the schema 
                where user_constraints.constraint_type = 'P'
                and user_tab_columns.table_name in ('LOCATIONS','DEPARTMENTS','EMPLOYEES') -- choose the specific tables 
                and user_tab_columns.data_type = 'NUMBER' -- make sure that the primary key column is numeric 
                and user_cons_columns.constraint_name in (select constraint_name from user_cons_columns group by constraint_name having count(*) = 1); -- exclude composite primary keys 

Begin 

-- Create a sequence and trigger for each table 
            for table_rec in tables_cursor loop
                
                -- drop sequence if it exists 
                select count(*)
                into v_count
                from USER_SEQUENCES
                where sequence_name = table_rec.table_name || '_SEQ';
                
                if v_count > 0 then
                        execute immediate 'DROP SEQUENCE ' || table_rec.table_name || '_SEQ';
                        v_count := 0;
                 end if ;
                 
                -- get the max value for each primary key 
                execute immediate 'SELECT NVL(MAX(' || table_rec.primary_key_column || '), 0) + 1 FROM ' || table_rec.table_name
                into v_temp;
                
                -- create a sequence for each table with max value and increment by 1
                execute immediate 'CREATE SEQUENCE ' || table_rec.table_name || '_SEQ ' ||
                                  'START WITH ' || v_temp ||
                                  ' INCREMENT BY 1';
                -- create or replace a trigger for each primary key 
                execute immediate 'CREATE OR REPLACE TRIGGER ' || table_rec.table_name || '_TREG ' ||
                                  'BEFORE INSERT ON ' || table_rec.table_name ||
                                  ' FOR EACH ROW ' ||
                                  'BEGIN ' ||
                                  '   :new.' || table_rec.primary_key_column || ' := ' || table_rec.table_name || '_SEQ.NEXTVAL; ' ||
                                  'END;';
                                  
                 dbms_output.put_line(table_rec.table_name || ', ' || table_rec.primary_key_column||', Start Value: '|| v_temp);
                 
            end loop;

End;
