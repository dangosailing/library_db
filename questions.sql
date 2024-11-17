USE library_db;

-- Hämta alla böcker som publicerats före år 1950.
SELECT b.title, b.publication_year FROM books b 
WHERE publication_year < 1950
; 
-- Hämta alla genrer som innehåller ordet "Classic".
SELECT genre_name FROM genres 
WHERE genre_name 
LIKE "%Classic%"
;
-- Hämta alla böcker av en specifik författare, t.ex. "George Orwell".
SELECT CONCAT(a.first_name, " ", last_name) AS author_name, b.title 
FROM authors a 
INNER JOIN books b 
ON a.author_id = b.author_id
HAVING author_name = "George Orwell"
;
-- Hämta alla böcker som publicerats av ett specifikt förlag och ordna dem efter publiceringsår.
SELECT b.title, p.name AS publisher, b.publication_year
FROM books b 
INNER JOIN publishers p 
ON b.publisher_id = p.publisher_id
WHERE p.name = "Penguin Books"
ORDER BY b.publication_year DESC
; 
-- Hämta alla böcker tillsammans med deras författare och publiceringsår.
SELECT 
b.title, 
CONCAT(a.first_name, " ", a.last_name) AS author_name, 
b.publication_year 
FROM books b
INNER JOIN authors a ON b.author_id = a.author_id
;
-- Hämta alla böcker som publicerades efter den första boken som kom ut efter år 2000.
SELECT 
books.title,
books.publication_year 
FROM books
WHERE books.publication_year > (
	SELECT MIN(books.publication_year) 
	FROM books 
	WHERE books.publication_year > 2000
)
;
-- Uppdatera författarens namn i tabellen.
UPDATE authors 
SET first_name = "Stefan" 
WHERE author_id = "10"
;
-- Ta bort en bok från databasen.
-- DS: Måste ta bort book_genre poster för samma id först då denna har ett beroende på boken och kastar fel annars 
DELETE FROM book_genre 
WHERE book_id = "9"
;
DELETE FROM books 
WHERE book_id = "9"
;
-- Hämta alla böcker som publicerats efter år 2000 tillsammans med författarens namn, förlagets namn och genrerna.
-- DS: Utgår från den genre som en stark entitet och hoppas från denna till alla relevanta tabeller
-- Använder en GROUP_CONCAT tillsammans med GROUP BY (på icke-aggregerade columns) för att 
-- slå ihop genre-blandningarna (ex. hunger games - Adventure och Dystopian) för bättre läsbarhet
SELECT 
b.title, 
b.publication_year,
CONCAT(a.first_name, " ", a.last_name) AS author_name, 
p.name AS publisher, 
GROUP_CONCAT(g.genre_name) AS genre 
FROM authors a 
INNER JOIN books b ON b.author_id = a.author_id 
INNER JOIN book_genre bg ON b.book_id = bg.book_id
INNER JOIN genres g ON bg.genre_id = g.genre_id
INNER JOIN publishers p ON b.publisher_id = p.publisher_id 
WHERE publication_year > 2000
GROUP BY title, b.publication_year, p.name, author_name
;
-- Visa författarnas fullständiga namn (förnamn och efternamn), titlarna på deras böcker och vilken genre böckerna tillhör.
-- DS: kör samma GROUP_CONCAT på genres som ovan med en GROUP BY grupperar på de icke-aggregerade kolumnerna
SELECT 
CONCAT(a.first_name, " ", a.last_name) AS author_name, 
b.title, GROUP_CONCAT(g.genre_name) AS genre 
FROM authors a
INNER JOIN books b ON a.author_id = b.author_id 
INNER JOIN book_genre bg ON b.book_id = bg.book_id 
INNER JOIN genres g ON bg.genre_id = g.genre_id
GROUP BY author_name, title
;
-- Antalet böcker varje författare har skrivit, sorterat i fallande ordning.
-- DS: Använder author table för författarens namn, JOIN:ar med books för att kunna
-- köra en COUNT på böcker i books via en gruppering på författarnamnet, 
-- via ORDER DESC så får vi det listat i fallande ordning
SELECT 
CONCAT(a.first_name, " ", a.last_name) AS author_name, 
COUNT(b.book_id) AS number_of_published_books 
FROM authors a
INNER JOIN books b ON a.author_id = b.author_id 
GROUP BY author_name
ORDER BY number_of_published_books 
DESC 
; 
-- Antalet böcker inom varje genre.
-- DS: JOIN:ar genre med book_genre. Grupperar på genre_name för att kunna räkna mängden böcker via COUNT
SELECT 
genre_name, 
COUNT(bg.book_id) AS books_in_genre 
FROM genres g
INNER JOIN book_genre bg ON g.genre_id = bg.genre_id
GROUP BY genre_name 
;
-- Genomsnittligt antal böcker per författare som är publicerade efter år 2000.
-- DS: skapar en sub-query för att få fram en "derived table" för att få fram där mängden böcker grupperad efter författare (publiserade efter 2000)
-- Ger denna table ett alias så att vi kan använda AVG på den i vår SELECT för att få fram ett genomsnittsvärde
SELECT AVG (num_books_after_2000) AS avg_books_per_auth_after_2000
FROM (
SELECT count(books.book_id) AS num_books_after_2000
FROM books 
WHERE books.publication_year > 2000
GROUP BY books.author_id
) 
AS books_after_2000
;
-- Skapa en stored procedure som tar ett årtal som parameter och returnerar alla böcker som publicerats efter detta år. Döp den till get_books_after_year.
-- DS: "variabeln" vi lagrar input_datumet i via IN blir här input_publication_year som sedan används i WHERE clausen. Viktigt att sätta 
-- avsluta delimiters med semi-kolon när man är klar
DELIMITER //
CREATE PROCEDURE get_books_after_year(IN input_publication_year INT)
BEGIN
	SELECT * FROM books WHERE publication_year > input_publication_year;
END //
DELIMITER ;
CALL get_books_after_year(2000)
;
-- Skapa en view som visar varje författares fullständiga namn, bokens titel och publiceringsår. Döp den till author_books. 
-- DS: Använder CREATE VIEW för att ett virtuellt table som vi kan refererra till för easy access utan att behöva köra denna query varje
-- gång vi vill komma åt denna data
CREATE VIEW author_books
AS SELECT 
CONCAT(a.first_name, " ", a.last_name) AS author_name, 
b.title, 
b.publication_year 
FROM authors a
INNER JOIN books b ON a.author_id = b.author_id
;