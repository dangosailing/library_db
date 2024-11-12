CREATE DATABASE library_db;
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
("George,", "Orwell", 1903),
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
("1984", 1949, 6, 1),
("The Hobbit", 1937, 4, 3),
("The Adventures of Tom Sawyer", 1876, 5, 3),
("Foundation", 1951, 6, 1),
("The Hound of the Baskervilles", 1902, 7, 3),
("Murder on the Orient Express", 1934, 8, 3),
("Do Androids Dream of Electric Sheep?", 1968, 6, 1),
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
(11,2),
(11,6),
(12,2),
(13,4),
(13,8),
(14,8),
(15,10);

-- Hämta alla böcker som publicerats före år 1950.
SELECT * FROM books 
WHERE publication_year < 1950
; 
-- Hämta alla genrer som innehåller ordet "Classic".
SELECT * FROM genres 
WHERE genre_name 
LIKE "%Classic%"
;
-- Hämta alla böcker av en specifik författare, t.ex. "George Orwell".
SELECT CONCAT(a.first_name, " ", last_name) AS author_name, b.title 
FROM authors a 
INNER JOIN books b 
ON a.author_id = b.author_id
HAVING author_name = "Stephen King"
;
-- Hämta alla böcker som publicerats av ett specifikt förlag och ordna dem efter publiceringsår.
SELECT b.title, p.name , b.publication_year publication_year 
FROM books b 
INNER JOIN publishers p 
ON b.publisher_id = p.publisher_id
WHERE p.name = "Penguin Books"
ORDER BY b.publication_year DESC
; 
-- Hämta alla böcker tillsammans med deras författare och publiceringsår.
SELECT b.title, CONCAT(a.first_name, " ", a.last_name) AS author_name, b.publication_year FROM books b
INNER JOIN authors a ON b.author_id = a.author_id
;
-- Hämta alla böcker som publicerades efter den första boken som kom ut efter år 2000.
SELECT * FROM books WHERE books.publication_year > (SELECT MIN(books.publication_year) FROM books WHERE books.publication_year > 2000)
;
-- Uppdatera författarens namn i tabellen.
UPDATE authors SET first_name = "Stephen" WHERE author_id = "10";
SELECT * FROM book_genre
;
-- Ta bort en bok från databasen.
-- Måste ta bort book_genre poster för samma id först då denna har ett beroende på boken och kastar fel annars 
DELETE FROM book_genre WHERE book_id = "9"
DELETE FROM books WHERE book_id = "9"
;
-- Hämta alla böcker som publicerats efter år 2000 tillsammans med författarens namn, förlagets namn och genrerna.
-- DS: Utgår från den genre som en stark entitet och hoppas från denna till alla relevanta tabeller
-- Tar chansen att använda en GROUP_CONCAT tillsammans med GROUP BY (på icke-aggregerade columns) för att 
-- slå ihop genre-blandningarna (ex. hunger games - Fantasy och Dystopian) för bättre läsbarhet
SELECT b.title, CONCAT(a.first_name, " ", a.last_name) AS author_name, p.name AS publisher, GROUP_CONCAT(g.genre_name) AS genre FROM authors a 
INNER JOIN books b ON b.author_id = a.author_id 
INNER JOIN book_genre bg ON b.book_id = bg.book_id
INNER JOIN genres g ON bg.genre_id = g.genre_id
INNER JOIN publishers p ON b.publisher_id = p.publisher_id 
WHERE publication_year > 2000
GROUP BY title, p.name, author_name
;
-- Visa författarnas fullständiga namn (förnamn och efternamn), titlarna på deras böcker och vilken genre böckerna tillhör.
-- DS: kör samma GROUP_CONCAT på genres som ovan med en GROUP BY som tar hänsyn till icke-aggregerade columns
SELECT CONCAT(a.first_name, " ", a.last_name) AS author_name, b.title, GROUP_CONCAT(g.genre_name) AS genre FROM authors a
INNER JOIN books b ON a.author_id = b.author_id 
INNER JOIN book_genre bg ON b.book_id = bg.book_id 
INNER JOIN genres g ON bg.genre_id = g.genre_id
GROUP BY author_name, title
;
-- Antalet böcker varje författare har skrivit, sorterat i fallande ordning.
--
SELECT CONCAT(a.first_name, " ", a.last_name) AS author_name, count(b.book_id) AS number_of_published_books FROM authors a
INNER JOIN books b ON a.author_id = b.author_id 
GROUP BY author_name
ORDER BY number_of_published_books DESC 
; 
-- Antalet böcker inom varje genre.
--
SELECT genre_name, COUNT(b.book_id) AS books_in_genre FROM genres g
INNER JOIN book_genre bg ON g.genre_id = bg.genre_id
INNER JOIN books b ON bg.book_id = b.book_id 
GROUP BY genre_name 
;
-- Genomsnittligt antal böcker per författare som är publicerade efter år 2000.
-- DS: ska dubbelkolla, inte säker på hur rätt avg ligger här
SELECT avg(b.book_id / a.author_id)  AS avg_books_per_author_after_2000 FROM authors a 
INNER JOIN books b ON a.author_id = b.author_id
WHERE b.publication_year > 2000
;
-- Skapa en stored procedure som tar ett årtal som parameter och returnerar alla böcker som publicerats efter detta år. Döp den till get_books_after_year.
-- DS: "variabeln" vi lagrar input_datumet i via IN blir här input_publication_year som sedan används i WHERE clausen. Viktigt att sätta 
-- avsluta delimiters med semi-kolon när man är klar
DELIMITER //
CREATE PROCEDURE get_books_after_year(
IN input_publication_year INT
)
BEGIN
	SELECT * FROM books WHERE publication_year > input_publication_year;
END //
DELIMITER ;
CALL get_books_after_year(2000)
;
-- Skapa en view som visar varje författares fullständiga namn, bokens titel och publiceringsår. Döp den till author_books. --
CREATE VIEW author_books
AS
SELECT CONCAT(a.first_name, " ", a.last_name) AS author_name, b.title, b.publication_year FROM authors a
INNER JOIN books b ON a.author_id = b.author_id;
SELECT * FROM author_books
;