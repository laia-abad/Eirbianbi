DROP TABLE IF EXISTS Hosts;
CREATE TABLE Hosts (
	listing_url VARCHAR(255),
	name VARCHAR(255),
	description TEXT,
	picture_url VARCHAR(255),
	host_id INT,
	host_url VARCHAR(255),
	host_name VARCHAR(255),
	host_since DATE,
	host_about TEXT,
	host_response_time VARCHAR(255),	
	host_response_rate VARCHAR(255),
	host_is_superhost BOOLEAN,
	host_picture_url VARCHAR(255),
	host_listings_count INT,
	host_verifications VARCHAR(255),
	host_identity_verified BOOLEAN
);

DROP TABLE IF EXISTS Apartments;
CREATE TABLE Apartments (
	id INT,
	listing_url VARCHAR(255),
	name VARCHAR(255),
	description TEXT,
	picture_url VARCHAR(255),
	street VARCHAR(255),
	neighbourhood_cleansed VARCHAR(255),
	city VARCHAR(255),
	state VARCHAR(255),
	zipcode VARCHAR(255),
	country_code CHAR(2),
	country VARCHAR(255),
	property_type VARCHAR(255),
	accommodates INT,
	bathrooms REAL,
	bedrooms INT,
	beds INT,
	amenities TEXT,
	square_feet INT,
	price VARCHAR(255),
	weekly_price VARCHAR(255),
	monthly_price VARCHAR(255),
	security_deposit VARCHAR(255),
	cleaning_fee VARCHAR(255),
	minimum_nights INT,
	maximum_nights INT
);

DROP TABLE IF EXISTS Reviews;
CREATE TABLE Reviews (
	id INT,
	listing_url VARCHAR(255),
	name VARCHAR(255),
	description TEXT,
	picture_url VARCHAR(255),
	street VARCHAR(255),
	neighbourhood_cleansed VARCHAR(255),
	city VARCHAR(255),
	date_review DATE,
	reviewer_id INT,
	reviewer_name VARCHAR(255),
	comments TEXT
);

COPY Hosts FROM 'C:\Users\Public\BBDD\P1\hosts.csv' CSV HEADER DELIMITER ',' ;
COPY Apartments FROM 'C:\Users\Public\BBDD\P1\apartments.csv' CSV HEADER DELIMITER ',' ;
COPY Reviews FROM 'C:\Users\Public\BBDD\P1\review.csv' CSV HEADER DELIMITER ',' ;