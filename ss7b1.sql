create schema ss7b1;
create table ss7b1.book (
book_id serial primary key,
title varchar(255),
author varchar(100),
genre varchar(50),
price decimal(10,2),
description text,
created_at timestamp default current_timestamp
);

insert into ss7b1.book (title, author, genre, price, description)
select 
'Book Title ' || i,
case when i % 10 = 0 then 'J.K. Rowling' else 'Author ' || i end,
case when i % 5 = 0 then 'Fantasy' else 'Description ' || i end,
(random() * 100)::decimal(10,2),
'Detailed description for book number ' || i from generate_series(1, 100000) as i;

explain analyze select * from ss7b1.book where author ilike '%Rowling%';
explain analyze select * from ss7b1.book where genre = 'Fantasy';
create index idx_book_author on ss7b1.book using btree (author);
create index idx_book_genre on ss7b1.book using btree (genre);
explain analyze select * from ss7b1.book where author ilike '%Rowling%';
explain analyze select * from ss7b1.book where genre = 'Fantasy';
create index idx_book_description_gin on ss7b1.book using gin (to_tsvector('english', description));
create index idx_book_genre_cluster on ss7b1.book (genre);
cluster ss7b1.book using idx_book_genre_cluster;
explain analyze select * from ss7b1.book where genre = 'Fantasy';

-- Báo cáo giải thích
/*
a.
- B-tree hiệu quả nhất cho các truy vấn so sánh bằng (=) trên genre và tìm kiếm mẫu trên author. 
- GIN index là lựa chọn tối ưu cho tìm kiếm từ khóa trong cột description dài.
- Clustered index giúp tăng tốc các truy vấn lọc theo nhóm (genre) do dữ liệu được sắp xếp vật lý cạnh nhau.
b. Hash index không được khuyến khích trong Postgres vì chỉ hỗ trợ phép bằng (=), không hỗ trợ tìm kiếm khoảng, 
  không hỗ trợ sắp xếp và ít an toàn hơn B-tree trong các phiên bản cũ.
*/