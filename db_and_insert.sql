CREATE DATABASE IF NOT EXISTS library_db;
USE library_db;

CREATE TABLE authors (
author_id INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(50),
last_name VARCHAR(50),
birth_year INT
);

CREATE TABLE publishers (
publisher_id INT PRIMARY KEY AUTO_INCREMENT, 
name VARCHAR(100),
location VARCHAR(100)
);

CREATE TABLE genres(
genre_id INT PRIMARY KEY AUTO_INCREMENT,
genre_name VARCHAR(50)
);

CREATE TABLE books (
book_id INT PRIMARY KEY AUTO_INCREMENT,
title VARCHAR(100),
publication_year INT,
author_id INT,
publisher_id INT,
FOREIGN KEY (author_id) REFERENCES authors(author_id),
FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id)
);

CREATE TABLE book_genre (
book_id INT,
genre_id INT,
FOREIGN KEY (book_id) REFERENCES books(book_id),
FOREIGN KEY (genre_id) REFERENCES genres(genre_id),
PRIMARY KEY (book_id, genre_id)
);

INSERT INTO authors (first_name, last_name, birth_year) VALUES 
("Jane", "Austen", 1775),
("J.K.", "Rowling", 1965),
("George", "Orwell", 1903),
("J.R.R.", "Tolkien", 1892),
("Mark", "Twain", 1835),
("Isaac", "Asimov", 1920),
("Arthur", "Conan Doyle", 1859),
("Agatha", "Christie", 1890),
("Philip", "K. Dick", 1928),
("Stephen", "King", 1947),
("Suzanne", "Collins", 1962),
("George", "R.R. Martin", 1948),
("Harlan", "Coben", 1962),
("Arthur", "Golden", 1956);

INSERT INTO publishers (name, location) VALUES
("Penguin Books","New York"),
("HarperCollins","London"),
("Vintage Books","San Francisco");

INSERT INTO genres (genre_name) VALUES
("Classical Romance"),
("Fantasy"),
("Adventure"),
("Detective Fiction"),
("Horror"),
("Dystopian"),
("Science Fiction"),
("Thriller"),
("Mystery"),
("Historical Fiction");

INSERT INTO books (title, publication_year, author_id, publisher_id) VALUES
("Pride and Prejudice", 1813, 1, 3),
("Harry Potter and the Philosopher's Stone", 1997, 2, 1),
("1984", 1949, 3, 1),
("The Hobbit", 1937, 4, 3),
("The Adventures of Tom Sawyer", 1876, 5, 3),
("Foundation", 1951, 6, 1),
("The Hound of the Baskervilles", 1902, 7, 3),
("Murder on the Orient Express", 1934, 8, 3),
("Do Androids Dream of Electric Sheep?", 1968, 9, 1),
("The Shining", 1977, 10, 1),
("The Hunger Games", 2008, 11 , 1),
("A Game of Thrones", 1996, 12, 1),
("The Stranger", 2015, 13, 2),
("The Woods", 2007, 13, 2),
("Memoirs of a Geisha", 1997, 14, 1);

INSERT INTO book_genre (book_id, genre_id) VALUES
(1,1),
(2,2),
(3,4),
(4,2),
(5,3),
(6,7),
(7,4),
(8,4),
(9,7),
(10,5),
(10,2),
(11,3),
(11,6),
(12,2),
(13,4),
(13,8),
(14,8),
(14,9),
(15,10);