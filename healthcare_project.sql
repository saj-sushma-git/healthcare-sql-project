/* Project Title: Healthcare SQL Project */

--------------------------------------------------
/* 
TABLE CREATION
Purpose: To create tables for storing patients, doctors, and appointment details.
Tables: Patients, Doctors, Appointments
*/
--------------------------------------------------
DROP TABLE IF EXISTS Patients;

CREATE table Patients (
	patient_id INTEGER PRIMARY KEY,
  	name TEXT,
  	age INT,
  	gender TEXT,
  	city TEXT
);

DROP TABLE IF EXISTS Doctors;

CREATE TABLE Doctors (
	doctor_id INTEGER PRIMARY KEY,
  	name TEXT,
  	specialization TEXT
  );
  
DROP TABLE IF EXISTS Appointments;

CREATE table Appointments (
	appointment_id INTEGER PRIMARY KEY,
  	patient_id INT,
  	doctor_id INT,
  	appointment_date DATE,
  	status TEXT,
  	FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
  	FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id)
);

/* 
Key Concepts Used:
Primary Key: A unique identifier for each record (cannot be NULL)
Foreign Key: Links two tables by referencing a primary key
Auto Increment: Auto matically generates unique values
*/
-------------------------------------------------------------------------------------------------------

-------------------------------------------
-- TABLES INSERTION
-------------------------------------------

INSERT INTO Patients (name, age, gender, city) VALUES
('Amit', 30, 'Male', 'Delhi'),
('Priya', 25, 'Male', 'Mumbai'),
('Rahul', 40, 'Male', 'Hyderabad'),
('Sneha', 35, 'Female', 'Chennai'),
('Sara', 46, 'Female', 'Chennai' );

SELECT * 
FROM Patients;

----------------------------------------------------------

INSERT into Doctors (name, specialization) VALUES
('Dr.Sharma', 'Cardiology'),
('Dr.Reddy', 'Dermatology'),
('Dr.Khan', 'Neurology'),
('Dr.Sushma', 'Dentist');

SELECT * 
FROM Doctors;

----------------------------------------------------------

INSERT into Appointments (patient_id, doctor_id, appointment_date, status) VALUES
(1, 1, '2024-03-01', 'Completed'),
(2, 2, '2024-03-02', 'Pending'),
(3, 1, '2024-03-03','Completed'),
(1, 3, '2024-03-04', 'Cancelled'),
(4, 2, '2024-03-05', 'Completed');

SELECT *
FROM Appointments;

----------------------------------------------------------------
/* 
Query 1. Total appointments per Doctor
Purpose: Find total number of appointments for each doctor.
*/
----------------------------------------------------------------
-- SQL Query:
SELECT d.name, COUNT(a.appointment_id) as Total_appointments
FROM Doctors d
left join Appointments a
on d.doctor_id = a.doctor_id
GROUP by d.doctor_id, d.name;

/*
Explanation: Used Left join to join the Doctors and Appointment tables,
Grouped by doctor_id and name, counted total appointments usign COUNT()
*/

----------------------------------------------------------------
/*
Query 2. Patients with more than one appointment
Purpose: Find patients who have more than one appointment
*/
----------------------------------------------------------------

-- SQL Query:
SELECT p.name, COUNT(a.appointment_id) as Total_visits
FROM Patients p
JOIN Appointments a
ON p.patient_id = a.patient_id
GROUP by p.patient_id, p.name
HAVING COUNT(a.appointment_id) > 1;

/*
Explanation: Joined Patients and Appointments tables using INNER JOIN,
Grouped data by patient_id and name, 
Used COUNT() to calculate the total appointments per patient,
Applied HAVING clause to filter patients with more than one appointment
*/

------------------------------------------------------------------
/*
Query 3: Patient and Doctor mapping
Purpose: Display the relationship between patients and the doctors they visited.
*/

-- SQL Query
SELECT p.name as patient_name, d.name as doctor_name
FROM Appointments a 
JOIN Patients p
ON a.patient_id = p.patient_id
JOIN Doctors d 
on a.doctor_id = d.doctor_id;

/*
Explanation:
Joined Appointments with Patients using patient_id,
Joined Appointments with Doctors using doctor_id,
Retrieved patient and doctor names
*/

-------------------------------------------------------------------
/*
Query 4: Doctors with No Appointments
Purpose: Find Doctors who do not have any appointments.
*/

-- SQL Query
SELECT d.name, a.appointment_id
FROM Doctors d
left join Appointments a
on d.doctor_id = a.doctor_id
WHERE a.appointment_id is NULL;

/*
Explanation:
Used LEFT JOIN to include all the doctors
If no matching appointment -> NULL values appear
Filtered NULL to get doctors with no appointments
*/
------------------------------------------------------------------------------------------------
/*
Query 5: Total number of appointments per patient (Including zero)
Purpose: Find the total number of appointments for each patient, including those who have no appointments.
*/

-- SQL Query
SELECT p.name, COUNT(a.appointment_id) as total_appointments
FROM Patients p
LEFT JOIN Appointments a
on p.patient_id = a.patient_id
GROUP by p.patient_id, p.name;

/*
Explanation:
Used LEFT JOIN to include all patients
COUNT() counts only non-null appointment IDs
Patients with no appointments return count as 0
GROUP BY groups results per patient
*/

------------------------------------------------------------------------------------------
/*
Query 6: Most visited Doctor
Purpose: Find the most visited doctor (doctor with highest number of appointments)
*/
------------------------------------------------------------------------------------------

SELECT d.name, COUNT(a.appointment_id) as total_appointments
FROM Doctors d
join Appointments a
on d.doctor_id = a.doctor_id
GROUP by d.doctor_id, d.name
ORDER by total_appointments DESC
limit 1;

/* The above query shows only one doctor with highest number of appointments, but it is not showing the ties!
So let's find the highest number of appointments and then show the respective doctor names... */

-- SQL Query handling ties

SELECT d.name, COUNT(a.appointment_id) AS total_appointments
FROM Doctors d
JOIN Appointments a
ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.name
HAVING COUNT(a.appointment_id) = (
    SELECT MAX(count_appointments)
    FROM (
        SELECT COUNT(a.appointment_id) AS count_appointments
        FROM Doctors d
        JOIN Appointments a
        ON d.doctor_id = a.doctor_id
        GROUP BY d.doctor_id
    ) sub
);

------------------------------------------------------------------------------
/*
Query 7: Total appointments by city
Purpose: Find the total number of appointments for each city.
*/

-- SQL Query
SELECT p.city, COUNT(a.appointment_id) as Total_appointments
FROM Patients p
LEFT JOIN Appointments a
on p.patient_id = a.patient_id
GROUP by p.city;

/*
Explanation:
Used LEFT JOIN to include all cities from Patients table,
COUNT() counts appointment IDs for each city,
GROUP BY groups data based on city,
Cities with no appointments return 0.
*/


------------------------------------------------------------------------------
/*
Query 8: Completed appointments per Doctor
Purpose: Find the number of completed appointments for each doctor, including those
with 0 appointments.
*/

-- SQL Query
SELECT d.doctor_id, d.name, COUNT(a.appointment_id) as Completed_Appointments
FROM Doctors d
join Appointments a
ON d.doctor_id = a.doctor_id
WHERE a.status = 'Completed'
GROUP by d.doctor_id, d.name;

-- The below query shows the doctors even with 0 completed appointments

SELECT d.doctor_id, d.name, COUNT(a.appointment_id) AS completed_appointments
FROM Doctors d
LEFT JOIN Appointments a
ON d.doctor_id = a.doctor_id 
AND a.status = 'Completed'
GROUP BY d.doctor_id, d.name;

/*
Explanation:
Used LEFT JOIN to include all doctors
Applied condition status = 'Completed' inside JOIN
COUNT() counts only completed appointments
Doctors with no completed appointments return 0
*/
----------------------------------------------------------------------------------

/*
Query 9: Doctor(s) with Highest number of Completed Appointments 
Purpose: Find the doctor(s) who have the highest number of Completed appointments, including handling ties.
*/

-- SQL Query
SELECT DoctorID, Name, total_appointments
FROM (
    SELECT D.DoctorID, D.Name,
           COUNT(A.AppointmentID) AS total_appointments,
           RANK() OVER (ORDER BY COUNT(A.AppointmentID) DESC) AS rnk
    FROM Doctors D
    INNER JOIN Appointments A
        ON D.DoctorID = A.DoctorID
    WHERE A.Status = 'Completed'
    GROUP BY D.DoctorID, D.Name
) sub
WHERE rnk = 1;

/*
Explanation:
Filtered only completed appointments
Counted total appointments per doctor
Applied RANK() to assign ranking based on count
Selected doctors with rank = 1 to handle ties
*/

-----------------------------------------------------------------------------

---------------------------------------------------------------------
-- 10. Find the doctors with completed appointments?
---------------------------------------------------------------------

SELECT d.doctor_id, d.name
FROM Doctors d
WHERE doctor_id IN (
	SELECT doctor_id
  	FROM Appointments a
  	WHERE a.status = 'Completed'
);

---------------------------------------------------------------
-- WINDOW FUNCTIONS ----------
--------------------------------------------------------------

-- Give each doctor a unique number 
SELECT name, 
	   row_number() over (ORDER by name) as row_num
FROM Doctors;   

-- Rank the doctors based on number of appointments
SELECT d.name, COUNT(a.appointment_id) as total_appointments,
		RANK() OVER(ORDER BY COUNT(a.appointment_id) desc) as rnk
FROM Doctors d
LEFT JOIN Appointments a
on d.doctor_id = a.doctor_id
GROUP by d.doctor_id, d.name;

---------------------------------------------------------------
/* 
Query 10. Unique cities
Purpose: Find all unique cities from patient table
*/

-- SQL QUERY
SELECT DISTINCT city
FROM Patients;
/*
Explanation: DICTINCT removes duplicate city values,
 			 Returns only unique list
*/

----------------------------------------------------------------------------
/*
Query 11: Completed vs Pending appointments
Purpose: Count number of completed and pending appointments
*/

-- SQL Query
SELECT 
	COUNT(CASE WHEN status = 'Completed'
         		THEN 1 end) as completed_count,
    COUNT(CASE WHEN status = 'Pending'
         		THEN 1 end) as pending_count
FROM Appointments;
/*
Explanation: CASE WHEN filters rows inside COUNT, Counts based on condition
*/

-------------------------------------------------------------------------------
/*
Query 12: Doctors with NO appointments
Purpose: Find doctors who don't have any appointments
*/

-- SQL Query
SELECT d.doctor_id, d.name
FROM Doctors d
LEFT JOIN Appointments a
on d.doctor_id = a.doctor_id
WHERE a.appointment_id is NULL;
/*
Explanation: LEFT JOIN includes all doctors, NULL means no matching appointment
*/
--------------------------------------------------------------------------------

/*
Query 13: Patients with more than one appointment
Purpose: Find patients who have more than one appointment
*/

-- SQL Query
SELECT p.patient_id, p.name, COUNT(a.appointment_id) as total_appointments
FROM Patients p
LEFT JOIN Appointments a 
on p.patient_id = a.patient_id
GROUP by p.patient_id, p.name
having COUNT(a.appointment_id) > 1;

/* 
Explanation: GROUP BY groups by patient, HAVING filters grouped results
*/
-----------------------------------------------------------------------------------

/* 
Query 14: Combine Patient and Doctor names
Purpose: Combine names from Patients and Doctors tables and understand the difference between UNION and UNION ALL.
*/

-- SQL Query UNION
SELECT name FROM Patients
UNION
SELECT name FROM Doctors;

-- SQL Query UNION ALL
SELECT name FROM Patients
UNION ALL
SELECT name FROM Doctors;

/* 
Explanation: 
UNION: Removes duplicate values, Returns only unique names
UNION ALL: Includes all values (duplicates also), Faster than UNION
*/
--------------------------------------------------------------------------------------------------------------------------
/*
Query 15: Patients from cities having appointments
Purpose: Find patients who belong to cities where atleast one appointment exists, using subquery and DISTINCT.
*/

-- SQL Query
SELECT name, city
FROM Patients 
WHERE city in (
		SELECT DISTINCT(p.city)
  		FROM Patients p
  		JOIN Appointments a
  		on a.patient_id = p.patient_id
);

/*
Explanation:
Inner query: It joins Patients and Appointments,
			It uses DISTINCT to get unique cities with appointments
Outer query: Filters patients whose city is in that list
*/
---------------------------------------------------------------------------------------------------------------------------

/*
CONCLUSION: This project demonstrates SQL concepts such as joins, aggregation, filtering, subqueries, and window functions
using a healthcare dataset
*/
