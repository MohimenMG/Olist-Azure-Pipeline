
-- from the operational database olist we move data to the following tables:

-- customers dimension --
-- geolocation dimenstion --
-- orders dimension --
-- products dimension --
-- sellers dimesnion --

-- the previous menthioned dimension tables will be left as is with no changes from the operational database table--

-- ===================================================================================================== --

-- From the previous tables we build the fact table with:

-- OrderItems dim: id, shipping_limit_date, price, freigt_value, order_id, product_id, order_item_id, seller_id
-- Customesr dim: id
-- Orders dim: id
-- Products dim: id
-- Sellers dim: id
-- Geolocation dim: seller_location_id, customer_location_id

select 
		oi.id AS item_id, 
		o.id AS order_id,
		c.id AS customer_id, 
		gc.id AS customer_location_id, 
		s.id AS seller_id, 
		gs.id AS seller_location_id, 
		p.id AS product_id, oi.shipping_limit_date, oi.price, oi.freight_value
from OrderItems oi
join orders o on o.order_id = oi.order_id
join Customers c on c.customer_id = o.customer_id
join Sellers s on s.seller_id = oi.seller_id
join Products p on p.product_id = oi.product_id
join Geolocation gc on gc.geolocation_zip_code_prefix = c.customer_zip_code_prefix
join Geolocation gs on gs.geolocation_zip_code_prefix = s.seller_zip_code_prefix

-- ===================================================================================================== --

-- note as per kimball warehose tool kit we should perserve the operational keys for auditing purposes 
-- however since relaitonal databases are row based not columnar this will affect performance 
-- so instad we can create a junk dimenson to store the operational keys without affecting the fact table performance

-- order_items dimension --
-- id, order_id as order_operational_id, order_item_id as order_item_operational_id, product_id as product_operaional_id, seller_id as seller_operational_id

-- ===================================================================================================== --

-- Reviews dimension --

-- checking orders with no reviews and if reviews are missing orders
select o.order_id as orders, r.order_id as reviews from orders o
full outer join Reviews r on r.order_id = o.order_id
where o.order_id is null or r.order_id is null
-- 766 orders have  no reviews and no review has no associated order

-- checking for duplicate reviews on the same order
with counter_table as (
select o.order_id as orders, count(*) as count_reviews from orders o
left join Reviews r on r.order_id = o.order_id
group by o.order_id)
select * from counter_table where count_reviews > 1
-- 544 orders have  2 reviews per order, no order has more than 2 only 0, 1, 2 reviews per order


-- I will snowflake the reviews table from the Orders Dimension --

-- ===================================================================================================== --

-- payments dimesnion -- 

-- checking orders with no payments and if a payment is missing an order
select * from orders o
full outer join payments p on p.order_id = o.order_id
where (p.order_id is not null) and (o.order_id is not null)
-- only 1 payment with no matching order id


-- checking multiple payments for the same order
with counter_table as (
select o.order_id, count(*) as count_payments from orders o 
join payments p on p.order_id = o.order_id
group by o.order_id)
select * from counter_table
where count_payments > 1
order by 2 desc,1 asc
-- 2952 orders have more than one payments up to 29 payment's transactions

-- I will snowflake the payments table from the Orders Dimension --

-- ===================================================================================================== --

-- finally add date dimension and replace the shipping linit date with date dim maybe a time dimension too?!