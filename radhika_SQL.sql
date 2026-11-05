-- Q.1 Bangaluru patients 
select patient_id,concat(first_name,last_name) as full_name,city,blood_group
from patients
where city="bangaluru"
limit 10;

-- Q.2 Doctors who are currently active
select doctor_id, first_name,last_name,department_id
from doctors
where status="active" and
experience_years>10;

-- Q.3 Total number of patient treated bby each doctor
select doctor_id,concat(d.first_name,d.last_name) as doctors_full_name,
 count(patient_id) as patient_id
from patients as p
right join doctors as d
using(doctor_id)
group by doctor_id,doctors_full_name;

-- Q.4 patients payment mode and find how many bills are paid and their net amount
select payment_mode,
 sum(net_amount) as total_netamount,
 count(*) as paid_bills
from bills
where payment_status="paid" 
group by payment_mode;

-- Q.5 top 5 departments with the highest total revenue generated from patient bills
select dp.department_name,
sum(b.net_amount) as total_revenue
from bills as b
join doctors as d
using(doctor_id)
join departments as dp
using(department_id)
where payment_status="paid"
group by department_name
order by total_revenue desc
limit 10;

-- Q.6 Create a view named “vw_doctor_revenue” that displays each 
#doctor’s total revenue collected from paid bills.
create or replace view vw_doctors_revenue as
select doctor_id,
sum(b.net_amount) as total_revenue,
concat(d.first_name,d.last_name) as doctotr_full_name
from bills as b
join doctors as d
using(doctor_id)
join departments as dp
using(department_id)
where payment_status="paid"
group by doctor_id;

select * from vw_doctors_revenue
where total_revenue > 1000;

-- Q.7 Identify the top 5 patients who have paid the highest total amount across all their bills.
#Show patient name and total amount paid.
select p.patient_id,
concat(p.first_name, p.last_name) as patient_name,
    sum(b.net_amount) as total_paid
from patients p
join bills b
using (patient_id)
where b.payment_status = 'Paid'
group by p.patient_id, patient_name
order by total_paid desc
limit 5;

-- Q.8 Show a list of medications prescribed 
#by doctors belonging to departments whose name contains ‘ology’ 
select m.generic_name,m.brand_name,dp.department_name,
concat(d.first_name,last_name) as doctor_name
from medications as m
join doctors as d
using (doctor_id)
join departments as dp
using (department_id)
where dp.department_name like "%ology%";

-- Q.9 Using a window function, list the top 3
# earning patients per city based on total amount paid 
select *
from(
    select p.city,
        concat(p.first_name,p.last_name) as patient_name,
        sum(b.net_amount) as total_paid,
        rank() OVER(
            partition by p.city
            order by sum(b.net_amount) desc
        ) as rank_in_city
    from patients p
    join bills b
    on p.patient_id = b.patient_id
    where b.payment_status = 'Paid'
    group by p.patient_id, patient_name, p.city
) as ranked
where rank_in_city <= 3;

-- Q.10 Increase the discount by 5% for all bills where payment_status = ‘Pending’.
#Before updating:
select count(*)
from bills
where payment_status = 'Pending';
select *
from bills
where payment_status = 'Pending'
limit 5;
update bills
set discount = discount + 5
where payment_status = 'Pending';
select *
from bills
where payment_status = 'Pending';

-- Q.11
delimiter $$

create trigger trg_update_discount
before insert on bills
for each row
begin
    if new.discount is null then
        set new.discount = new.net_amount * 0.10;
    end if;
end $$
delimiter ;

-- Q.12 Create a new database named ‘Hospital_Training_DB’ and inside 
#it create two tables: test_doctors and test_patients.

create database Hospital_Training_DB;

use Hospital_Training_DB;

create table test_doctors (
    doctor_id int auto_increment primary key,
    first_name varchar(30) not null,
    last_name varchar(30) not null,
    specialization varchar(50),
    experience_years int
);

create table test_patients (
    patient_id int auto_increment primary key,
    first_name varchar(30) not null,
    last_name varchar(30) not null,
    doctor_id int,
    city varchar(50),
    foreign key (doctor_id)
    references test_doctors(doctor_id)
);

insert into test_doctors(first_name,last_name,specialization,experience_years)
values
('Amit','Sharma','Cardiology',12),
('Neha','Patel','Neurology',8);

insert into test_patients(first_name,last_name,doctor_id,city)
values
('Rahul','Verma',1,'Mumbai'),
('Priya','Singh',2,'Pune');

select* from test_doctors;
select* from test_patients;

select
    p.patient_id,
    concat(p.first_name,p.last_name) as patient_name,
    concat(d.first_name,d.last_name) as doctor_name,
    d.specialization
from test_patients p
join test_doctors d
on p.doctor_id = d.doctor_id;

