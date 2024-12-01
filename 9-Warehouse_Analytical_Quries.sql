-- customer top spenders
select oi.customer_id, oi.order_id, sum(oi.price + oi.freight_value) as sums
from Fact_OrderItems oi
group by customer_id, order_id
order by sums desc

-- top location by total revenue
select g.geolocation_state, sum(oi.price+oi.freight_value) as location_revenue 
from Fact_OrderItems oi
join Dim_Geolocation g on oi.customer_location_id = g.warehouse_id 
group by g.geolocation_state
order by location_revenue desc

-- top seller by revenue
select oi.seller_id, 
	count(*) items_sold, 
	count(distinct order_id) orders_delivered, 
	sum(oi.price + oi.freight_value) total_revenue
from Fact_OrderItems oi
group by oi.seller_id
order by total_revenue desc

select min(order_purchase_timestamp), min(order_approved_at), max (order_purchase_timestamp), max(order_approved_at) from Dim_Orders