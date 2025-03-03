create database uber;
use uber;

CREATE TABLE Driver (
    ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Car_No VARCHAR(20),
    DoB DATE,
    Location VARCHAR(255)
);

CREATE TABLE Customer (
    CID INT PRIMARY KEY,
    Name VARCHAR(100),
    Login_Info VARCHAR(255)
);

CREATE TABLE Rating (
    ID INT PRIMARY KEY,
    Car_No VARCHAR(20),
    Login_Info VARCHAR(255),
    Name VARCHAR(100)
);

CREATE TABLE Payment (
    ID INT PRIMARY KEY,
    Trip_No INT,
    Payment_Method VARCHAR(50),
    Amount DECIMAL(10,2)
);

CREATE TABLE Trip (
    DID INT,
    CID INT,
    Payment_ID INT,
    Status VARCHAR(50),
    Distance DECIMAL(10,2),
    Start_Point VARCHAR(255),
    End_Point VARCHAR(255),
    Trip_ID INT PRIMARY KEY,
    FOREIGN KEY (DID) REFERENCES Driver(ID),
    FOREIGN KEY (CID) REFERENCES Customer(CID),
    FOREIGN KEY (Payment_ID) REFERENCES Payment(ID)
);

CREATE TABLE Uber (
    ID INT PRIMARY KEY,
    Driver_ID INT,
    Customer_ID INT,
    FOREIGN KEY (Driver_ID) REFERENCES Driver(ID),
    FOREIGN KEY (Customer_ID) REFERENCES Customer(CID)
);
# adding required feilds to calculate distance  
ALTER TABLE Trip
ADD COLUMN Start_Lat DECIMAL(10,6),
ADD COLUMN Start_Lon DECIMAL(10,6),
ADD COLUMN End_Lat DECIMAL(10,6),
ADD COLUMN End_Lon DECIMAL(10,6);

#creating a stored function to calculate distance
DELIMITER //

CREATE FUNCTION CalculateDistance(
    lat1 DECIMAL(10,6), lon1 DECIMAL(10,6),
    lat2 DECIMAL(10,6), lon2 DECIMAL(10,6)
) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE r DECIMAL(10,6);
    DECLARE dlat DECIMAL(10,6);
    DECLARE dlon DECIMAL(10,6);
    DECLARE a DECIMAL(10,6);
    DECLARE c DECIMAL(10,6);

    SET r = 6371; -- Earth's radius in kilometers

    -- Difference in latitudes and longitudes
    SET dlat = RADIANS(lat2 - lat1);
    SET dlon = RADIANS(lon2 - lon1);

    -- Haversine formula
    SET a = SIN(dlat / 2) * SIN(dlat / 2) +
            COS(RADIANS(lat1)) * COS(RADIANS(lat2)) *
            SIN(dlon / 2) * SIN(dlon / 2);

    SET c = 2 * ATAN2(SQRT(a), SQRT(1 - a));

    -- Final distance calculation
    RETURN r * c;
END //

DELIMITER ;



#automation of distance calculation 
DELIMITER //

CREATE TRIGGER before_trip_insert
BEFORE INSERT ON Trip
FOR EACH ROW
BEGIN
    SET NEW.Distance = CalculateDistance(NEW.Start_Lat, NEW.Start_Lon, NEW.End_Lat, NEW.End_Lon);
END;

//

DELIMITER ;

#sample data 
INSERT INTO Driver (ID, Name, Car_No, DoB, Location)
VALUES
(1, 'John Doe', 'ABC123', '1985-06-15', 'New York'),
(2, 'Jane Smith', 'XYZ456', '1990-04-22', 'Los Angeles'),
(3, 'Mike Johnson', 'LMN789', '1987-11-30', 'Chicago'),
(4, 'Emily Davis', 'OPQ101', '1993-03-12', 'San Francisco'),
(5, 'David Wilson', 'RST202', '1984-08-05', 'Miami');

INSERT INTO Customer (CID, Name, Login_Info)
VALUES
(1, 'Alice Brown', 'alice_brown@example.com'),
(2, 'Bob Green', 'bob_green@example.com'),
(3, 'Charlie White', 'charlie_white@example.com'),
(4, 'Diana Black', 'diana_black@example.com'),
(5, 'Eve Grey', 'eve_grey@example.com');

INSERT INTO Rating (ID, Car_No, Login_Info, Name)
VALUES
(1, 'ABC123', 'alice_brown@example.com', 'John Doe'),
(2, 'XYZ456', 'bob_green@example.com', 'Jane Smith'),
(3, 'LMN789', 'charlie_white@example.com', 'Mike Johnson'),
(4, 'OPQ101', 'diana_black@example.com', 'Emily Davis'),
(5, 'RST202', 'eve_grey@example.com', 'David Wilson');

INSERT INTO Payment (ID, Trip_No, Payment_Method, Amount)
VALUES
(1, 101, 'Credit Card', 20.50),
(2, 102, 'PayPal', 15.75),
(3, 103, 'Credit Card', 25.00),
(4, 104, 'Cash', 30.25),
(5, 105, 'Credit Card', 18.90);

INSERT INTO Trip (DID, CID, Payment_ID, Status, Distance, Start_Point, End_Point, Trip_ID, Start_Lat, Start_Lon, End_Lat, End_Lon)
VALUES
(1, 1, 1, 'Completed', 15.2, 'New York', 'Brooklyn', 101, 40.7128, -74.0060, 40.6782, -73.9442),
(2, 2, 2, 'Completed', 8.5, 'Los Angeles', 'Santa Monica', 102, 34.0522, -118.2437, 34.0219, -118.4957),
(3, 3, 3, 'Completed', 12.3, 'Chicago', 'Wicker Park', 103, 41.8781, -87.6298, 41.9110, -87.6778),
(4, 4, 4, 'Completed', 10.1, 'San Francisco', 'Mission District', 104, 37.7749, -122.4194, 37.7596, -122.4148),
(5, 5, 5, 'Completed', 7.8, 'Miami', 'South Beach', 105, 25.7617, -80.1918, 25.7737, -80.1883);




#updating distance column
SET SQL_SAFE_UPDATES = 0;

UPDATE Trip
SET Distance = CalculateDistance(Start_Lat, Start_Lon, End_Lat, End_Lon)
WHERE Start_Lat IS NOT NULL AND Start_Lon IS NOT NULL
  AND End_Lat IS NOT NULL AND End_Lon IS NOT NULL;
SET SQL_SAFE_UPDATES = 1;

select * from trip;

SELECT CalculateDistance(40.712800, -74.006000, 40.678200, -73.944200);










