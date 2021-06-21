--#&&
SELECT city AS name, AVG(((price - (weekly_price/7))/price) * 100) AS savings_percentage
FROM Address AS ad, Apartment AS ap, Host AS h
WHERE ad.id_address = ap.id_address AND ap.id_host = h.id_host AND identity_verified = true AND price <> 0
GROUP BY city
ORDER BY savings_percentage DESC
LIMIT 3;

--#&&
SELECT ap.name, CONCAT('$', CAST(price /(square_feet) AS DECIMAL (10,2))) AS price_m2, COUNT(id_review) AS reviews
FROM Apartment AS ap, Review as r, PropertyType AS pt
WHERE r.id_apartment = ap.id_apartment AND pt.id_property = ap.id_property AND pt.name LIKE 'Guesthouse'
AND square_feet IS NOT NULL AND square_feet <> 0
GROUP BY ap.id_apartment 
HAVING COUNT(id_review) > 200
ORDER BY price_m2
LIMIT 1;

--#&&
SELECT ap.name, listing_url AS url, CONCAT('$', CAST ((price * 6 * 5 + cleaning_fee + security_deposit * 0.1)
										   AS DECIMAL (10,2))) AS total_price
FROM Apartment AS ap, Address AS ad, Host AS ho, Amenity AS am, Has AS ha
WHERE ap.id_address = ad.id_address AND ho.id_host = ap.id_host AND am.id_amenity = ha.id_amenity 
AND ha.id_apartment = ap.id_apartment AND neighborhood LIKE 'Port Phillip' AND am.name LIKE 'Balcony' 
AND bathrooms > 1.5 AND response_rate > 0.9 AND accommodates = 6 AND maximum_nights >= 5 AND minimum_nights <= 5
ORDER BY (price * 6 * 5 + cleaning_fee + security_deposit * 0.1)
LIMIT 1;

--#&&
UPDATE Host
SET is_superhost = false
WHERE since > CURRENT_DATE - 5 * 365;

UPDATE Host
SET is_superhost = true
WHERE since <= CURRENT_DATE - 5 * 365;

--#&&
SELECT DISTINCT street, COUNT(id_apartment) AS num, CONCAT('$', CAST(AVG(price) AS DECIMAL (10,2)))  AS price
FROM Address AS ad, Apartment AS ap
WHERE ad.id_address = ap.id_address
GROUP BY street
HAVING AVG(price) < 100
ORDER BY num DESC
LIMIT 3;

--#&&
SELECT rer.name AS name_reviewer, listing_url, COUNT(id_review) AS num_reviews
FROM Reviewer AS rer, Review AS r, Apartment AS ap
WHERE rer.id_reviewer = r.id_reviewer AND ap.id_apartment = r.id_apartment
GROUP BY r.id_reviewer, listing_url, rer.name
ORDER BY num_reviews DESC 
LIMIT 3;
--It is most likely Cameron since he has the most reviews and they look too good to be true. Also looking 
--at where the apartment is and where he states he lives, he doesn't live far from the apartment, which would 
--make it more unlikely that he would rent that place.

--#&&
SELECT ap.id_apartment AS id, ap.name, CONCAT('$', CAST((price * 2 * 2 + cleaning_fee + 0.1 * security_deposit)
													 AS DECIMAL (10,2))) AS total_price
FROM Apartment AS ap, Amenity AS am, Host AS ho, Has AS ha, Gets AS g, Verification AS v, Address AS ad
WHERE (price * 2 * 2 + cleaning_fee + 0.1 * security_deposit) < 5000 AND accommodates >= 2 AND beds >= 2 
AND city LIKE 'Saint Kilda' AND am.id_amenity = ha.id_amenity AND ap.id_apartment = ha.id_apartment 
AND ho.id_host = ap.id_host AND am.name LIKE 'Kitchen' AND g.id_host = ho.id_host 
AND v.id_verification = g.id_verification AND v.name LIKE 'phone' AND ad.id_address = ap.id_address 
AND minimum_nights <= 2 AND maximum_nights >= 2
ORDER BY (price * 2 * 2 + cleaning_fee + 0.1 * security_deposit) DESC;

--#&&
DROP TABLE IF EXISTS Sumatori;
CREATE TABLE Sumatori (
	id_host INT,
	suma REAL
);

INSERT INTO Sumatori (id_host, suma)
SELECT h.id_host, SUM(1/price)
FROM Apartment AS a, Host AS h
WHERE a.id_host = h.id_host AND price <> 0
GROUP BY h.id_host;

SELECT h.id_host, h.name,
(suma * (1 + is_superhost::int) * COUNT(DISTINCT v.id_verification) * COUNT(DISTINCT id_apartment)) AS score
FROM Apartment AS a, Host AS h, Verification AS v, Gets AS g, Sumatori AS s
WHERE g.id_verification = v.id_verification AND g.id_host = h.id_host AND h.id_host = a.id_host 
AND s.id_host = h.id_host AND h.name IS NOT NULL
GROUP BY h.id_host, suma
ORDER BY score DESC
LIMIT 3;

DROP TABLE Sumatori;

--#&&
SELECT re.id_reviewer, re.name, SUM(CASE WHEN LENGTH(comment) < 100 THEN 10 ELSE 15 END) AS points
FROM Review AS r, Reviewer AS re
WHERE r.id_reviewer = re.id_reviewer
GROUP BY re.id_reviewer
ORDER BY points DESC
LIMIT 10;

--#&&
--What are the 5 most expensive property types and what is their average price.
SELECT pt.name, CONCAT('$', CAST(AVG(price) AS DECIMAL (10,2))) AS property_price
FROM PropertyType AS pt, Apartment AS ap
WHERE pt.id_property = ap.id_property 
GROUP BY pt.id_property
ORDER BY AVG(price) DESC
LIMIT 5;