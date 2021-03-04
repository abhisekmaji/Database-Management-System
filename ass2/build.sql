---first database---

CREATE TABLE airports(
    airportid BIGINT NOT NULL,
    city TEXT,
    state TEXT,
    name TEXT,
    CONSTRAINT airportid_key PRIMARY KEY (airportid)
);

CREATE TABLE flights(
    flightid BIGINT NOT NULL,
    originairportid BIGINT,
    destairportid BIGINT,
    carrier TEXT,
    dayofmonth BIGINT,
    dayofweek BIGINT,
    departuredelay BIGINT,
    arrivaldelay BIGINT,
    CONSTRAINT flightid_key PRIMARY KEY (flightid),
    CONSTRAINT originairportid_ref FOREIGN KEY (originairportid) REFERENCES airports(airportid),
    CONSTRAINT destairportid_ref FOREIGN KEY (destairportid) REFERENCES airports(airportid),
    CONSTRAINT dayweekrange CHECK (dayofweek BETWEEN 1 AND 7),
    CONSTRAINT daymonthrange CHECK (dayofmonth BETWEEN 1 AND 31)
);

---second daatabase---

CREATE TABLE authordetails(
    authorid BIGINT NOT NULL,
    authorname TEXT,
    city TEXT,
    gender TEXT,
    age BIGINT,
    CONSTRAINT authorid_key PRIMARY KEY (authorid) 
);

CREATE TABLE paperdetails(
    paperid BIGINT NOT NULL,
    papername TEXT,
    conferencename TEXT,
    score BIGINT,
    CONSTRAINT paperid_key PRIMARY KEY (paperid)
);

CREATE TABLE authorpaperlist(
    authorid BIGINT NOT NULL,
    paperid BIGINT,
    CONSTRAINT authorid_key2 PRIMARY KEY (authorid, paperid),
    CONSTRAINT paperid_ref FOREIGN KEY (paperid) REFERENCES paperdetails(paperid)
);

CREATE TABLE citationlist(
    paperid1 BIGINT NOT NULL,
    paperid2 BIGINT NOT NULL,
    CONSTRAINT citationlist_key PRIMARY KEY (paperid1, paperid2)
);

\copy airports from '/home/abhisek/Documents/iit/pdfs/sem6/col362/ass2/airports.csv' DELIMITER ',' CSV HEADER;
\copy flights from '/home/abhisek/Documents/iit/pdfs/sem6/col362/ass2/flights.csv' DELIMITER ',' CSV HEADER;
--\copy authordetails from '.../authordetails.csv' DELIMITER ',' CSV HEADER;
--\copy paperdetails from '.../paperdetails.csv' DELIMITER ',' CSV HEADER;
--\copy authorpaperlist from '.../authorpaperlist.csv' DELIMITER ',' CSV HEADER;
--\copy citationlist from '.../citationlist.csv' DELIMITER ',' CSV HEADER;
