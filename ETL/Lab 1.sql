-- 1. Selecciona todos los registros de empleados.
SELECT * from Employee e 

-- 2. Selecciona el ID, el nombre, el apellido y la compañía de todos los clientes de Estados Unidos.
Select CustomerId, FirstName, LastName , Company  FROM Customer c WHERE Country == 'USA';


-- 3. Selecciona los diferentes países de facturación que podemos encontrar en la BBDD.
SELECT DISTINCT BillingCountry from Invoice i 

-- 4. Seleccionaelnombre,apellido,ciudadypaísdelosclientesdeEstados
	--Unidos, España, Canadá y Brasil ordenados alfabéticamente en función
	--del nombre (de manera ascendente).
select FirstName , LastName , City , Country  from Customer c 
WHERE Country IN ('Spain', 'Canada', 'Brazil') 
ORDER BY  FirstName ASC  


--5. Transformaladuracióndetodoslostemasdemúsicademsaminutos,
	--trayendo en la consulta su Id y su nombre.
(SELECT TrackId , Name , (Milliseconds/60000) as Minutes from Track t)

--6. Partiendo de la consulta anterior, crea una columna adicional que nos
	--diga el tiempo de tema que es según su longitud Largo/medio/corto. 
	--(Si el tema es de 5 minutos o más será largo, si es de 3 a 4 minutos será medio y si es inferior a 3 será corto).
SELECT *,
CASE 
	when Minutes >= 5 then "Largo"
	when Minutes >= 3 then "Medio"
	Else "Corto"
end as TrackLength
from (SELECT TrackId , Name , (Milliseconds/60000) as Minutes from Track t) 


--7. Calcula el precio total de los álbumes de U2.
SELECT a.Title, a2.Name, SUM(t.UnitPrice) as TotalPrice
FROM Album a 
LEFT JOIN Track t  ON a.AlbumId  = t.AlbumId 
RIGHT JOIN Artist a2 on a2.ArtistId = a.ArtistId 
WHERE a2.Name = "U2"
GROUP by a2.Name, a.AlbumId 



--8. Para el género rock, saca el precio medio de los discos de todos los
	--artistas. Ordena la consulta de mayor a menor en función de dicho
	--precio medio.
SELECT Artista , AVG(TotalPrice) 
FROM 
(SELECT a.Title as Album, a2.Name as Artista, g.Name , SUM(t.UnitPrice) as TotalPrice
FROM Album a 
LEFT JOIN Track t  ON a.AlbumId  = t.AlbumId 
RIGHT JOIN Artist a2 on a2.ArtistId = a.ArtistId
LEFT JOIN Genre g on g.GenreId = t.GenreId
WHERE g.Name LIKE  "%Rock%"
GROUP by a.AlbumId 
)
GROUP BY Artista
ORDER by AVG(TotalPrice) DESC 




--9. Selecciona el número de clientes distintos, en función de su país, que
	--han comprado álbumes de U2.
SELECT c.Country, COUNT(DISTINCT c.CustomerId) 
from Customer c 
INNER JOIN Invoice i on i.CustomerId  = c.CustomerId 
LEFT JOIN InvoiceLine il on il.InvoiceId = i.InvoiceId 
LEFT JOIN Track t on t.TrackId = il.TrackId 
LEFT JOIN Album a on a.AlbumId = t.AlbumId 
LEFT JOIN Artist a2 on a2.ArtistId = a.ArtistId 
WHERE a2.Name = "U2"
GROUP BY c.Country 

--10. Selecciona (con la sentencia LIMIT):
	--a. El Top 10 de artistas en función de sus ventas, así como el montante total de dichas ventas.
	SELECT a2.Name , sum(il.UnitPrice * il.Quantity)
	FROM InvoiceLine il 
	LEFT JOIN Track t on t.TrackId = il.TrackId 
	LEFT JOIN Album a on a.AlbumId = t.AlbumId 
	LEFT JOIN Artist a2 on a2.ArtistId = a.ArtistId 
	GROUP BY a2.ArtistId 
	ORDER BY sum(il.UnitPrice * il.Quantity) DESC LIMIT 10

	--b. El Top 10 de álbumes, el artista y las ventas totales
	SELECT a.Title , a2.Name , sum(il.UnitPrice * il.Quantity)
	FROM InvoiceLine il 
	LEFT JOIN Track t on t.TrackId = il.TrackId 
	LEFT JOIN Album a on a.AlbumId = t.AlbumId 
	LEFT JOIN Artist a2 on a2.ArtistId = a.ArtistId 
	GROUP BY a.AlbumId  
	ORDER BY sum(il.UnitPrice * il.Quantity) DESC LIMIT 10
	
	--c. El Top 10 de álbumes en función del número de clientes y su
		--artista.
	SELECT a.Title , a2.Name , COUNT(DISTINCT i.CustomerId)
	FROM InvoiceLine il
	LEFT JOIN Invoice i on i.InvoiceId = il.InvoiceId 
	LEFT JOIN Track t on t.TrackId = il.TrackId 
	LEFT JOIN Album a on a.AlbumId = t.AlbumId 
	LEFT JOIN Artist a2 on a2.ArtistId = a.ArtistId 
	GROUP BY a.AlbumId  
	ORDER BY COUNT(DISTINCT i.CustomerId) DESC LIMIT 10
	
	
	--d. El top 10 de artistas en función del número de clientes.
	SELECT a2.Name , COUNT(DISTINCT i.CustomerId)
	FROM InvoiceLine il
	LEFT JOIN Invoice i on i.InvoiceId = il.InvoiceId 
	LEFT JOIN Track t on t.TrackId = il.TrackId 
	LEFT JOIN Album a on a.AlbumId = t.AlbumId 
	LEFT JOIN Artist a2 on a2.ArtistId = a.ArtistId 
	GROUP BY a2.ArtistId 
	ORDER BY COUNT(DISTINCT i.CustomerId) DESC LIMIT 10



