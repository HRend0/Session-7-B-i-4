create schema ss7b4;
create table ss7b4.customer (
customer_id serial primary key,
full_name varchar(100),
region varchar(50)
);
create table ss7b4.orders (
order_id serial primary key,
customer_id int references ss7b4.customer(customer_id),
total_amount decimal(10,2),
order_date date,
status varchar(20)
);

insert into ss7b4.customer (full_name, region) values
('Nguyễn Văn A', 'North'),
('Trần Thị B', 'Central'),
('Lê Văn C', 'South'),
('Phạm Thị D', 'North'),
('Hoàng Văn E', 'South');
insert into ss7b4.orders (customer_id, total_amount, order_date, status) values
(1, 5000000, '2026-01-10', 'Completed'),
(2, 3000000, '2026-01-15', 'Completed'),
(3, 8000000, '2026-02-01', 'Completed'),
(4, 2000000, '2026-02-20', 'Pending'),
(5, 4500000, '2026-03-05', 'Processing');

create or replace view ss7b4.v_revenue_by_region as 
select 
c.region, 
sum(o.total_amount) as total_revenue 
from ss7b4.customer c 
join ss7b4.orders o on c.customer_id = o.customer_id 
group by c.region;

select * from ss7b4.v_revenue_by_region 
order by total_revenue desc 
limit 3;

create materialized view ss7b4.mv_monthly_sales as 
select 
date_trunc('month', order_date) as month, 
sum(total_amount) as monthly_revenue 
from ss7b4.orders 
group by date_trunc('month', order_date);

create or replace view ss7b4.v_order_status_update as
select order_id, customer_id, total_amount, status
from ss7b4.orders
where status != 'Cancelled'
with check option;

update ss7b4.v_order_status_update 
set status = 'Shipped' 
where order_id = 4;

update ss7b4.orders
set status = 'Cancelled' 
where order_id = 4;

create or replace view ss7b4.v_revenue_above_avg as
select region, total_revenue
from ss7b4.v_revenue_by_region
where total_revenue > (select avg(total_revenue) from ss7b4.v_revenue_by_region);

select * from ss7b4.v_revenue_above_avg;