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

----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
-------------------------------------------------------NUMBER 1-------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
with adaptation as (
    select
        id,
        MONTH(datetime) as month,
        IFNULL(department_id, 0) as department_id,
        IFNULL(job_id, 0) as job_id
    from
        mydatabase.hired_employees_mod
),
distincts as (
    select
        department_id,
        job_id
    from
        adaptation
    group by
        1,
        2
),
conteos as (
    select
        department_id,
        job_id,
        month,
        count(*) as conteo
    from
        adaptation
    group by
        1,
        2,
        3
),
quarters as (
    select
        department_id,
        job_id,
        case
            when month between 1
            and 3 then 1
            when month between 4
            and 6 then 2
            when month between 7
            and 9 then 3
            when month between 10
            and 12 then 4
        end as qtr,
        conteo
    from
        conteos
),
sums as (
    select
        department_id,
        job_id,
        qtr,
        sum(conteo) as total
    from
        quarters
    group by
        1,
        2,
        3
),
transpose as (
    select
        a.*,
        IFNULL(b.total, 0) as q1,
        IFNULL(c.total, 0) as q2,
        IFNULL(d.total, 0) as q3,
        IFNULL(e.total, 0) as q4
    from
        distincts a
        left join (
            select
                *
            from
                sums
            where
                qtr = 1
        ) b on a.department_id = b.department_id
        and a.job_id = b.job_id
        left join (
            select
                *
            from
                sums
            where
                qtr = 2
        ) c on a.department_id = c.department_id
        and a.job_id = c.job_id
        left join (
            select
                *
            from
                sums
            where
                qtr = 3
        ) d on a.department_id = d.department_id
        and a.job_id = d.job_id
        left join (
            select
                *
            from
                sums
            where
                qtr = 4
        ) e on a.department_id = e.department_id
        and a.job_id = e.job_id
)
select
    IFNULL(b.department, 'NA') as department,
    IFNULL(c.job, 'NA') as job,
    a.q1,
    a.q2,
    a.q3,
    a.q4
from
    transpose a
    left join mydatabase.departments b on a.department_id = IFNULL(b.id, 0)
    left join mydatabase.jobs c on a.job_id = IFNULL(c.id, 0)
order by
    IFNULL(b.department, 'NA'),
    IFNULL(c.job, 'NA');

----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
-------------------------------------------------------NUMBER 2-------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
with adaptation as (
    select
        id,
        MONTH(datetime) as month,
        IFNULL(department_id, 0) as department_id,
        IFNULL(job_id, 0) as job_id
    from
        mydatabase.hired_employees_mod
),
conteos as (
    select
        department_id,
        count(*) as conteo
    from
        adaptation
    group by
        1
),
promedio as (
    select
        avg(conteo) as prom
    from
        conteos
),
conditions as (
    select
        a.*
    from
        conteos a
    where
        conteo > (
            select
                prom
            from
                promedio
        )
)
select
    a.department_id as id,
    IFNULL(b.department, 'NA') as department,
    conteo as hired
from
    conditions a
    left join mydatabase.departments b on a.department_id = IFNULL(b.id, 0)
order by
    conteo desc
