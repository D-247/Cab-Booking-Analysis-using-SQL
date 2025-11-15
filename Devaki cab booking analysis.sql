CREATE DATABASE cb;
USE cb;

CREATE TABLE Customers (
 CustomerID INT PRIMARY KEY,
 Name VARCHAR(100),
 Email VARCHAR(100),
 RegistrationDate DATE
);

INSERT INTO Customers (CustomerID, Name, Email, RegistrationDate) VALUES
(1, 'Alice Johnson', 'alice@example.com', '2023-01-15'),
(2, 'Bob Smith', 'bob@example.com', '2023-02-20'),
(3, 'Charlie Brown', 'charlie@example.com', '2023-03-05'),
(4, 'Diana Prince', 'diana@example.com', '2023-04-10');

CREATE TABLE Drivers (
 DriverID INT PRIMARY KEY,
 Name VARCHAR(100),
 JoinDate DATE
);

INSERT INTO Drivers (DriverID, Name, JoinDate) VALUES
(101, 'John Driver', '2022-05-10'),
(102, 'Linda Miles', '2022-07-25'),
(103, 'Kevin Road', '2023-01-01'),
(104, 'Sandra Swift', '2022-11-11');

CREATE TABLE Cabs (
 CabID INT PRIMARY KEY,
 DriverID INT,
 VehicleType VARCHAR(20),
 PlateNumber VARCHAR(20),
 FOREIGN KEY (DriverID) REFERENCES Drivers(DriverID)
);

INSERT INTO Cabs (CabID, DriverID, VehicleType, PlateNumber) VALUES
(1001, 101, 'Sedan', 'ABC1234'),
(1002, 102, 'SUV', 'XYZ5678'),
(1003, 103, 'Sedan', 'LMN8901'),
(1004, 104, 'SUV', 'PQR3456');

CREATE TABLE Bookings (
 BookingID INT PRIMARY KEY,
 CustomerID INT,
 CabID INT,
 BookingDate DATETIME,
 Status VARCHAR(20),
 PickupLocation VARCHAR(100),
 DropoffLocation VARCHAR(100),
 FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
 FOREIGN KEY (CabID) REFERENCES Cabs(CabID)
);

INSERT INTO Bookings (BookingID, CustomerID, CabID, BookingDate,
Status, PickupLocation, DropoffLocation) VALUES
(201, 1, 1001, '2024-10-01 08:30:00', 'Completed', 'Downtown',
'Airport'),
(202, 2, 1002, '2024-10-02 09:00:00', 'Completed', 'Mall',
'University'),
(203, 3, 1003, '2024-10-03 10:15:00', 'Canceled', 'Station',
'Downtown'),
(204, 4, 1004, '2024-10-04 14:00:00', 'Completed', 'Suburbs',
'Downtown'),
(205, 1, 1002, '2024-10-05 18:45:00', 'Completed', 'Downtown',
'Airport'),
(206, 2, 1001, '2024-10-06 07:20:00', 'Canceled', 'University',
'Mall');

CREATE TABLE TripDetails (
 TripID INT PRIMARY KEY,
 BookingID INT,
 StartTime DATETIME,
 EndTime DATETIME,
 DistanceKM FLOAT,
 Fare FLOAT,
 FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);

INSERT INTO TripDetails (TripID, BookingID, StartTime, EndTime,
DistanceKM, Fare) VALUES
(301, 201, '2024-10-01 08:45:00', '2024-10-01 09:20:00', 18.5,
250.00),
(302, 202, '2024-10-02 09:10:00', '2024-10-02 09:40:00', 12.0,
180.00),
(303, 204, '2024-10-04 14:10:00', '2024-10-04 14:40:00', 10.0,
150.00),
(304, 205, '2024-10-05 18:50:00', '2024-10-05 19:30:00', 20.0,
270.00);

CREATE TABLE Feedback (
 FeedbackID INT PRIMARY KEY,
 BookingID INT,
 Rating FLOAT,
 Comments TEXT,
 FeedbackDate DATE,
 FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);

INSERT INTO Feedback (FeedbackID, BookingID, Rating, Comments,
FeedbackDate) VALUES
(401, 201, 4.5, 'Smooth ride', '2024-10-01'),
(402, 202, 3.0, 'Driver was late', '2024-10-02'),
(403, 204, 5.0, 'Excellent service', '2024-10-04'),
(404, 205, 2.5, 'Cab was not clean', '2024-10-05');

select * from Customers;
select * from Drivers;
select * from Cabs;
select * from Bookings;
select * from TripDetails;
select * from Feedback;

-- Customer and Booking Analysis

-- 1. Identify customers who have completed the most bookings. What insights can you draw about their behavior?
select CustomerID,count(CustomerID) as count_customer_trip from bookings where status='Completed'group by CustomerID order by count(CustomerID) desc;

-- insight : Customers with the most bookings are highly engaged and loyal, often relying on the service regularly for daily or frequent travel.

-- 2. Find customers who have canceled more than 30% of their total bookings. What could be the reason for frequent cancellations?
select customerid,sum(status = 'canceled'),count(*) as total,round(sum(status = 'canceled') / count(*) * 100, 2) as cancellation_rate from bookings group by customerid having cancellation_rate > 30;

-- insight : Customers canceling more than 30% may face issues like changing schedules, poor cab availability, or dissatisfaction with service quality.

-- 3. Determine the busiest day of the week for bookings. How can the company optimize cab availability on peak days?
select dayname(bookingdate) as day_of_week, count(*) as total_bookings from bookings group by dayname(bookingdate) order by total_bookings desc;

-- insight : The most active booking day shows peak demand patterns, so the company should increase cab availability and driver incentives on that day to meet demand efficiently.

use cb;
-- Driver Performance & Efficiency

-- 1. Identify drivers who have received an average rating below 3.0 in the past three months. What strategies can be implemented to improve their performance?
select d.driverid, d.name, avg(f.rating) as avg_rating from drivers d join cabs c on d.driverid = c.driverid join bookings b on c.cabid = b.cabid join feedback f on b.bookingid = f.bookingid group by d.driverid, d.name having avg_rating < 3;

-- insight: Spot underperforming drivers who need training or monitoring to improve service quality.

-- 2. Find the top 5 drivers who have completed the longest trips in terms of distance. What does this say about their working patterns?
select d.driverid, d.name, sum(t.distancekm) as totaldistance from drivers d join cabs c on d.driverid=c.driverid join bookings b on c.cabid=b.cabid join tripdetails t on b.bookingid=t.bookingid where b.status='completed' group by d.driverid, d.name order by totaldistance desc limit 5;

-- insight : Identify the most active drivers to reward or incentivize their dedication.

-- 3. Identify drivers with a high percentage of canceled trips. Could this indicate driver unreliability?
select d.driverid, d.name, sum(case when b.status='canceled' then 1 else 0 end)*1.0/count(*) as cancelrate from drivers d join cabs c on d.driverid=c.driverid join bookings b on c.cabid=b.cabid group by d.driverid, d.name having cancelrate > 0.25;

-- insight : Detect unreliable drivers whose cancellations affect service consistency and need corrective action.

-- Revenue & Business Metrics

-- 1. Calculate the total revenue generated by completed bookings in the last 6 months. How has the revenue trend changed over time?
select date_format(bookingdate,'%Y-%m') as month, sum(fare) as total_revenue from bookings b join tripdetails t on b.bookingid=t.bookingid where b.status='completed' and bookingdate between '2024-10-01' and '2024-10-31' group by date_format(bookingdate,'%Y-%m') order by month;

-- insight: Revenue from completed trips is 850, showing income trends and helping optimize cab allocation and business planning.

-- 2. Identify the top 3 most frequently traveled routes based on PickupLocation and DropoffLocation. Should the company allocate more cabs to these routes?
select pickuplocation, dropofflocation, count(*) as trips from bookings where status='completed' group by pickuplocation, dropofflocation order by trips desc limit 3;

-- insight: The most popular routes show high demand, so the company should allocate more cabs to reduce wait times and increase efficiency.

-- 3. Determine if higher-rated drivers tend to complete more trips and earn higher fares. Is there a direct correlation between driver ratings and earnings?
select d.driverid, d.name, avg(f.rating) as avg_rating, count(b.bookingid) as total_trips, sum(t.fare) as total_earnings from drivers d join cabs c on d.driverid=c.driverid join bookings b on c.cabid=b.cabid join tripdetails t on b.bookingid=t.bookingid join feedback f on b.bookingid=f.bookingid where b.status='completed' group by d.driverid, d.name order by avg_rating desc;

-- insight : Higher-rated drivers tend to complete more trips and earn higher fares, showing a positive correlation between driver quality and earnings.

-- Operational Efficiency & Optimization

-- 1. Analyze the average waiting time (difference between booking time and trip start time) for different pickup locations. How can this be optimized to reduce delays?
select pickuplocation, avg(time_to_sec(starttime - bookingdate)/60) as avg_wait from bookings b join tripdetails t on b.bookingid=t.bookingid where b.status='completed' group by pickuplocation;

-- insight: Pickup locations with higher average waiting times indicate potential delays; allocating cabs strategically can reduce customer wait time.

-- 3. Find out whether shorter trips (low-distance) contribute significantly to revenue. Should the company encourage more short-distance rides?
select case when distancekm<5 then 'short' else 'long' end as triptype, count(*) as numtrips, sum(fare) as totalrevenue from tripdetails group by case when distancekm<5 then 'short' else 'long' end;

-- insight: Short-distance trips contribute a significant portion of revenue, so promoting quick rides can boost overall earnings and utilization.

-- Comparative & Predictive Analysis
-- 1. Compare the revenue generated from 'Sedan' and 'SUV' cabs. Should the company invest more in a particular vehicle type?
select c.vehicletype, sum(t.fare) as total_revenue from cabs c join bookings b on c.cabid=b.cabid join tripdetails t on b.bookingid=t.bookingid where b.status='completed' group by c.vehicletype;

-- insight: Comparing revenue shows which cab type earns more; the company can invest more in the higher-earning vehicle type to maximize profits.

-- 2. Predict which customers are likely to stop using the service based on their last booking date and frequency of rides. How can customer retention be improved?
select customerid, max(bookingdate) as last_booking, count(*) as total_bookings from bookings group by customerid having datediff(curdate(), max(bookingdate))>30 and total_bookings<3;

-- insight: Customers with old last bookings and few rides are at risk of leaving; targeted offers, discounts, or personalized communication can improve retention.

-- 3. Analyze whether weekend bookings differ significantly from weekday bookings. Should the company introduce dynamic pricing based on demand?
select case when dayofweek(bookingdate) in (1,7) then 'weekend' else 'weekday' end as day_type, count(*) as total_bookings from bookings group by day_type;

-- insight: Weekend booking patterns may differ from weekdays; introducing dynamic pricing during high-demand periods can optimize revenue.










