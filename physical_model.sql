DROP TABLE IF EXISTS Host CASCADE;
CREATE TABLE Host (
	id_host SERIAL,
	url VARCHAR(255),
	name VARCHAR(255),
	since DATE,
	about TEXT,
	response_time VARCHAR(255),
	response_rate VARCHAR(255),
	is_superhost BOOLEAN,
	picture_url VARCHAR(255),
	listings_count INT,
	identity_verified BOOLEAN,
	host_id INT,
	PRIMARY KEY (id_host)
);

DROP TABLE IF EXISTS Verification CASCADE;
CREATE TABLE Verification (
	id_verification SERIAL,
	name VARCHAR(255),
	PRIMARY KEY (id_verification)
);

DROP TABLE IF EXISTS Gets CASCADE;
CREATE TABLE Gets (
	id_host INT,
	id_verification INT,
	PRIMARY KEY (id_host, id_verification),
	FOREIGN KEY (id_host) REFERENCES Host(id_host),
	FOREIGN KEY (id_verification) REFERENCES Verification(id_verification)
);

DROP TABLE IF EXISTS Address CASCADE;
CREATE TABLE Address (
	id_address SERIAL, 
	street VARCHAR(255),
	neighborhood VARCHAR(255),
	zipcode VARCHAR(255),
	city VARCHAR(255),
	state CHAR(3),
	country_code CHAR(2),
	country VARCHAR(255),
	PRIMARY KEY (id_address)
);

DROP TABLE IF EXISTS PropertyType CASCADE;
CREATE TABLE PropertyType (
	id_property SERIAL,
	name VARCHAR(255),
	PRIMARY KEY (id_property)
);

DROP TABLE IF EXISTS Apartment CASCADE;
CREATE TABLE Apartment (
	id_apartment SERIAL,
	listing_url VARCHAR(255),
	name VARCHAR(255),
	description TEXT,
	picture_url VARCHAR(255),
	accommodates INT,
	bathrooms REAL,
	bedrooms INT,
	beds INT,
	square_feet INT,
	price VARCHAR(255),
	weekly_price VARCHAR(255),
	monthly_price VARCHAR(255),
	security_deposit VARCHAR(255),
	cleaning_fee VARCHAR(255),
	minimum_nights INT, 
	maximum_nights INT,
	id_host INT,
	id_property INT,
	id_address INT,
	id INT,
	PRIMARY KEY (id_apartment),
	FOREIGN KEY (id_host) REFERENCES Host(id_host),
	FOREIGN KEY (id_property) REFERENCES PropertyType(id_property),
	FOREIGN KEY (id_address) REFERENCES Address(id_address)
);	

DROP TABLE IF EXISTS Amenity CASCADE;
CREATE TABLE Amenity (
	id_amenity SERIAL,
	name VARCHAR(255),
	PRIMARY KEY (id_amenity)
);

DROP TABLE IF EXISTS Has CASCADE;
CREATE TABLE Has (
	id_apartment INT,
	id_amenity INT,
	PRIMARY KEY (id_apartment, id_amenity),
	FOREIGN KEY (id_apartment) REFERENCES Apartment(id_apartment),
	FOREIGN KEY (id_amenity) REFERENCES Amenity(id_amenity)
);

DROP TABLE IF EXISTS Reviewer CASCADE;
CREATE TABLE Reviewer (
	id_reviewer SERIAL,
	name VARCHAR(255),
	reviewer_id INT,
	PRIMARY KEY (id_reviewer)
);

DROP TABLE IF EXISTS Review CASCADE;
CREATE TABLE Review (
	id_review SERIAL,
	id_apartment INT,
	id_reviewer INT,
	date DATE,
	comment TEXT,
	PRIMARY KEY (id_review),
	FOREIGN KEY (id_apartment) REFERENCES Apartment(id_apartment),
	FOREIGN KEY (id_reviewer) REFERENCES Reviewer(id_reviewer)
);

INSERT INTO Host(url, name, since, about, response_time, response_rate, is_superhost, picture_url, 
				 listings_count, identity_verified, host_id) 
SELECT DISTINCT host_url, host_name, host_since, host_about, host_response_time, host_response_rate, 
host_is_superhost, host_picture_url, host_listings_count, host_identity_verified, host_id
FROM Hosts;

UPDATE Host
SET response_rate = TRIM('%' FROM response_rate);

UPDATE Host
SET response_rate = NULL
WHERE response_rate LIKE 'N/A';

ALTER TABLE Host 
ALTER COLUMN response_rate TYPE REAL USING response_rate::REAL;

UPDATE Host
SET response_rate = response_rate/100;

DROP TABLE IF EXISTS Verifications;
CREATE TABLE Verifications (
	name VARCHAR(255),
	host_id INT
);

INSERT INTO Verifications(name, host_id)
SELECT REGEXP_SPLIT_TO_TABLE(host_verifications, E','), host_id
FROM Hosts;

UPDATE Verifications
SET name = REPLACE(name, '''', '');

UPDATE Verifications
SET name = TRIM('[ ]' FROM name);

INSERT INTO Verification(name)
SELECT DISTINCT name
FROM Verifications;

INSERT INTO Gets (id_host, id_verification)
SELECT DISTINCT id_host, id_verification
FROM Host, Verification, Verifications
WHERE host.host_id = verifications.host_id AND verification.name = verifications.name;

DROP TABLE Verifications;

UPDATE Apartments
SET zipcode = TRIM('QWERTYUIOPASDFGHJKLZXCVBNM ' FROM zipcode);

UPDATE Apartments
SET state = SUBSTRING(state, 1, 3);

UPDATE Apartments
SET state = UPPER(state);

INSERT INTO Address (street, neighborhood, zipcode, state, city, country_code, country)
SELECT DISTINCT street, neighbourhood_cleansed, zipcode, state, city, country_code, country
FROM Apartments;

INSERT INTO PropertyType (name)
SELECT DISTINCT property_type
FROM Apartments;

INSERT INTO Apartment (listing_url, name, description, picture_url, accommodates, bathrooms, bedrooms, beds, 
					   square_feet, price, weekly_price, monthly_price, security_deposit, cleaning_fee, 
					   minimum_nights, maximum_nights, id_host, id_property, id_address, id)
SELECT ap.listing_url, ap.name, ap.description, ap.picture_url, accommodates, bathrooms, bedrooms, beds, 
square_feet, price, weekly_price, monthly_price, security_deposit, cleaning_fee, minimum_nights, maximum_nights,
id_host, id_property, id_address, ap.id
FROM Apartments AS ap, Host, PropertyType, Hosts, Address AS ad
WHERE ap.property_type = propertytype.name AND hosts.listing_url = ap.listing_url
AND hosts.host_id = host.host_id AND (ap.street = ad.street OR (ad.street IS NULL AND ap.street IS NULL))
AND (ap.neighbourhood_cleansed = ad.neighborhood OR (ad.neighborhood IS NULL 
													 AND ap.neighbourhood_cleansed IS NULL)) 
AND (ap.city = ad.city OR (ad.city IS NULL AND ap.city IS NULL)) 
AND (ap.zipcode = ad.zipcode OR (ad.zipcode IS NULL AND ap.zipcode IS NULL)) 
AND (ap.state = ad.state OR (ad.state IS NULL AND ap.state IS NULL)) 
AND (ap.country_code = ad.country_code OR (ad.country_code IS NULL AND ap.country_code IS NULL)) 
AND (ap.country = ad.country OR (ad.country IS NULL AND ap.country IS NULL));

ALTER TABLE Host
DROP host_id;

DROP TABLE IF EXISTS Amenities;
CREATE TABLE Amenities (
	name VARCHAR(255),
	id INT
);

INSERT INTO Amenities(name, id)
SELECT DISTINCT REGEXP_SPLIT_TO_TABLE(amenities, E','), id
FROM Apartments;

UPDATE Amenities
SET name = TRIM('{"} ' FROM name);

INSERT INTO Amenity(name)
SELECT DISTINCT name
FROM Amenities;

INSERT INTO Has (id_apartment, id_amenity)
SELECT DISTINCT id_apartment, id_amenity
FROM Apartment, Amenity, Amenities
WHERE apartment.id = amenities.id AND amenities.name = amenity.name;

ALTER TABLE Apartment
DROP id;

DROP TABLE Amenities;

INSERT INTO Reviewer (name, reviewer_id)
SELECT DISTINCT reviewer_name, reviewer_id
FROM Reviews;

INSERT INTO Review (id_apartment, id_reviewer, date, comment)
SELECT id_apartment, id_reviewer, date_review, comments
FROM Apartment, Reviewer, Reviews
WHERE apartment.listing_url = reviews.listing_url AND reviewer.reviewer_id = reviews.reviewer_id;

ALTER TABLE Reviewer
DROP reviewer_id;

UPDATE Apartment
SET price = REPLACE(price, ',', '');

UPDATE Apartment
SET price = TRIM('$' FROM price);

ALTER TABLE Apartment
ALTER COLUMN price TYPE DECIMAL(10,2) USING price::numeric(10,2);

UPDATE Apartment
SET price = 0
WHERE price IS NULL;

UPDATE Apartment
SET weekly_price = REPLACE(weekly_price, ',', '');

UPDATE Apartment
SET weekly_price = TRIM('$' FROM weekly_price);

ALTER TABLE Apartment
ALTER COLUMN weekly_price TYPE DECIMAL(10,2) USING weekly_price::numeric(10,2);

UPDATE Apartment
SET weekly_price = price * 7
WHERE weekly_price IS NULL;

UPDATE Apartment
SET monthly_price = REPLACE(monthly_price, ',', '');

UPDATE Apartment
SET monthly_price = TRIM('$' FROM monthly_price);

ALTER TABLE Apartment
ALTER COLUMN monthly_price TYPE DECIMAL(10,2) USING monthly_price::numeric(10,2);

UPDATE Apartment
SET monthly_price = price * 30
WHERE monthly_price IS NULL;

UPDATE Apartment
SET security_deposit = REPLACE(security_deposit, ',', '');

UPDATE Apartment
SET security_deposit = TRIM('$' FROM security_deposit);

ALTER TABLE Apartment
ALTER COLUMN security_deposit TYPE DECIMAL(10,2) USING security_deposit::numeric(10,2);

UPDATE Apartment
SET security_deposit = 0
WHERE security_deposit IS NULL;

UPDATE Apartment
SET cleaning_fee = REPLACE(cleaning_fee, ',', '');

UPDATE Apartment
SET cleaning_fee = TRIM('$' FROM cleaning_fee);

ALTER TABLE Apartment
ALTER COLUMN cleaning_fee TYPE DECIMAL(10,2) USING cleaning_fee::numeric(10,2);

UPDATE Apartment
SET cleaning_fee = 0
WHERE cleaning_fee IS NULL;