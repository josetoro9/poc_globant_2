ALTER TABLE
    mydatabase.hired_employees
MODIFY
    id int;

ALTER TABLE
    mydatabase.hired_employees
MODIFY
    department_id int;

ALTER TABLE
    mydatabase.hired_employees
MODIFY
    job_id int;

-------------------------------
ALTER TABLE
    mydatabase.jobs
MODIFY
    id int;

ALTER TABLE
    mydatabase.departments
MODIFY
    id int;

-- whe have to do this table beacause of the main preferences of safe mode
create table mydatabase.hired_employees_mod as
select
    id,
    name,
    cast(LEFT(datetime, 10) as date) as datetime,
    department_id,
    job_id
from
    mydatabase.hired_employees
where
    year(cast(LEFT(datetime, 10) as date)) = 2021;

select
    a.*
from
    mydatabase.hired_employees_mod a
    left join;

