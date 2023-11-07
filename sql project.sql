/* Q1. who is the senior most employee based on job title? */

use music_data_analysis;
select * from employee;
select * from employee order by levels desc limit 1;

/* q2. which countries have the most Invoices? */

select * from invoice;
select count(*) as c, billing_country from invoice group by billing_country order by c desc;

/*q3. what are top 3 values of total invoice */

select total from invoice order by total desc limit 3;

/* q4. which city has the best customers? We would like to throw a  promtional music festival in the city we made the most money. Write a 
query that return one city that has the highest  sum of invoice totals. Return both the city name and sum of all invoice totals */

select sum(total) as invoice_total, billing_city from invoice group by billing_city order by invoice_total desc;

/* who is the best customer? the customer who has spent the most money will be declared the best customer. write a query that returns the person who has spent the most money */

select * from customer;
-- select customer.customer_id, customer.first_name, customer.last_name,sum(invoice.total)  from customer 
-- join invoice on customer.customer_id= invoice.customer_id  group by customer.customer_id
-- order by total desc limit 1;

/*q5. write query to return the email , first name,last name, and genre of all rock music listeners. Return your list
 ordered alphabetically by email starting with A */
 
 use music_data_analysis;
 select * from genre;
 select distinct email, first_name, last_name from customer
 join invoice on customer.customer_id=invoice.customer_id
 join invoice_line on invoice.invoice_id=invoice_line.invoice_id
 where track_id in (select track_id from track join genre on track.genre_id=genre.genre_id 
					where genre.name like 'Rock')
order by email;
                  
/* q5. let's invite the artist who have written the most rock music in our dataset . write a query that 
return s the artist name an total track cout of the top 10 rock bands */

select * from artist;
select * from album2;
select artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs from track
join album2 on album2.album_id=track.album_id
join artist on artist.artist_id=album2.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock' 
GROUP BY artist.artist_id
order by number_of_songs desc
limit 10;

/* Q6. return all the track names that have a song length longer than the average song length. return the name
and milliseconds for each track. order by the song length with the longest songs listed first */

select * from playlist_track;
select * from track;
select name,milliseconds from track where milliseconds > ( select avg(milliseconds) as avg_track_length from track)
order by milliseconds desc;

/* Q7. Find how much amount spent by each cusomer on artists? 
write a query to return customer name, artist name an d total spent */

select * from invoice_line;
with best_selling_artist as (
	select artist.artist_id as artist_id, artist.name as artist_name, sum(invoice_line.unit_price*invoice_line.quantity) from invoice_line as total_sales
    join track on track.track_id = invoice_line.track_id
    join album2 on album2.album_id = track.album_id
    join artist on artist.artist_id = album2.artist_id
    group by 1
    order by 3 desc
    limit 1
    )
select c.cusotmer_id, c.first_name, c. last_name, bsa.artist_name, sum(il.unit_price*il.quantity) as amount_spent from invoice as i
join customer as c on c. customer_id= i.customer_id
join invoice_line as il on il.invoice_id= i.invoice_id
join track as t on t.track_id = t.album_id
join album2 as alb on alb.album_id = t.album_id
join best_selling_artist as bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;

/* q8. we want to find out he most popular music genre for each country. we determine the most popular genre as the genre with the 
highest  amount of purchases. write a query that return each country along with the top genre. 
For countries where the maoximum number of purchases is shared return all generes. */

with popular_genre as 
(
select count(invoice_line.quantity) as purchases , customer.country, genre.name, genre.genre_id, 
row_number() over (partition by customer.country order by count(invoice_line.quantity)desc) as RowNO from invoice_line 
join invoice on invoice.invoice_id = invoice_line.invoice_id
join customer on customer.customer_id = invoice.customer_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
group by 2,3,4
order by 2 asc , 1 desc
)
select * from  pupular_genre where RowNo <= 1;