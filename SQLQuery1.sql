alter database Petadoptionplatform modify name=PetPals_AdoptionPlatform

create table Pets(
PetID int primary key identity(1,1),
Name varchar(50) not null,
age int not null,
Breed Varchar(50) not null,
type varchar(20),
AvailableForAdoption bit default 0)

create table Shelters(
ShelterId int primary key identity(20,5),
Name varchar(255) not null,
Location Varchar(255) not null)

Create table Donations(
DonationID int primary key identity(100,2),
DonorName varchar(50) not null,
DonationType varchar(50) not null,
DonationAmount decimal(10,2),
DonationItem varchar(50),
DonationDate datetime not null)

alter table donations 
add constraint donation_ck check(donationtype in('cash','item','card'))

create table AdoptionEvents(
EventID int Primary Key identity(1,1),
EventName varchar(50) NOT  NULL,
EventDate datetime not null,
Location varchar(50) not null)

create table Participants(
ParticipantID int primary key identity(10,10),
ParticipantName varchar(50) not null,
ParticipantType varchar(50) not null,
EventID  int foreign key references adoptionevents(eventId))

INSERT INTO Pets(Name, Age, Breed, Type, AvailableForAdoption)
VALUES
('Buddy', 2, 'Labrador', 'Dog', 1),
('Fluffy', 1, 'Persian', 'Cat', 0),
('Max', 3, 'Golden Retriever', 'Dog', 1),
('Whiskers', 2, 'Siamese', 'Cat', 0),
('Rocky', 4, 'German Shepherd', 'Dog', 1)

-- Insert records into Shelters table
INSERT INTO Shelters (Name, Location)
VALUES
('Happy Tails Shelter', '123 Main St'),
('Rescue Haven', '456 Elm St'),
('Paws and Claws', '789 Oak St'),
('Forever Friends Rescue', '321 Maple St'),
('Second Chance Shelter', '987 Pine St')

-- Insert records into Donations table
INSERT INTO Donations (DonorName, DonationType, DonationAmount, DonationItem, DonationDate)
VALUES
('John Smith', 'cash', 100.00, NULL, '2023-05-10'),
('Alice Johnson', 'item', NULL, 'Pet Food', '2023-07-20'),
('Emily Brown', 'card', 150.00, NULL, '2023-11-10'),
('Michael Wilson', 'cash', 200.00, NULL, '2023-01-05'),
('Sarah Davis', 'item', NULL, 'Toys', '2023-12-30')

alter table donations 
add shelterid int foreign key references shelters(shelterid)

update donations set shelterid=20 where donationid=100
select *from donations

-- Insert records into AdoptionEvents table
INSERT INTO AdoptionEvents (EventName, EventDate, Location)
VALUES
('Adoption Day', '2023-05-15', 'City Park'),
('Pet Expo', '2023-08-20', 'Convention Center'),
('Rescue Run', '2023-10-25', 'Local Park'),
('Furry Friends Festival', '2023-11-05', 'Downtown Plaza'),
('Paws in the Park', '2023-12-10', 'Community Center')

alter table participants 
add constraint CK_participant check(participantType in('adopter','shelter'))

-- Insert records into Participants table
INSERT INTO Participants (ParticipantName, ParticipantType, EventID)
VALUES
('Volunteer Group A', 'adopter', 1),
('Sponsor Company B', 'Sponsor', 2),
('Pet Owner C', 'shelter', 3),
('Animal Advocate D', 'adopter', 4),
('Rescue Organization E', 'shelter', 5)


--5.Write an SQL query that retrieves a list of available pets (those marked as available for adoption) 
--from the "Pets" table. Include the pet's name, age, breed, and type in the result set. Ensure that 
--the query filters out pets that are not available for adoption.
select * from pets where availableforadoption=1

--6.Write an SQL query that retrieves the names of participants (shelters and adopters) registered 
--for a specific adoption event. Use a parameter to specify the event ID. Ensure that the query 
--joins the necessary tables to retrieve the participant names and types
declare @Specific_event_id int
set @Specific_event_id=3
select e.eventid,p.participantname,e.eventname from participants p join AdoptionEvents e
on p.eventid=e.eventid where e.eventid=@Specific_event_id

--7.Create a stored procedure in SQL that allows a shelter to update its information (name and 
--location) in the "Shelters" table. Use parameters to pass the shelter ID and the new information. 
--Ensure that the procedure performs the update and handles potential errors, such as an invalid 
--shelter ID
CREATE PROCEDURE UpdateShelterInformation
    @ShelterID INT,
    @NewName VARCHAR(255),
    @NewLocation VARCHAR(255)
AS 
BEGIN IF NOT EXISTS (SELECT 1 FROM Shelters WHERE ShelterId = @ShelterID)
    BEGIN
        RAISERROR('Invalid shelter ID. Shelter not found.',16,1)
    END
 BEGIN TRY
 UPDATE Shelters
 SET Name = @NewName,
        Location = @NewLocation
        WHERE ShelterId = @ShelterID;
       
	   PRINT 'Shelter information updated successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'An error occurred while updating shelter information: ' + ERROR_MESSAGE();
    END CATCH
END

EXEC UpdateShelterInformation 
@ShelterID = 20, @NewName = 'puppy shelter', @NewLocation = 'chennai'

select * from shelters

--8. Write an SQL query that calculates and retrieves the total donation amount for each shelter (by 
--shelter name) from the "Donations" table. The result should include the shelter name and the 
--total donation amount. Ensure that the query handles cases where a shelter has received no 
--donations.select s.shelterid,s.name as sheltername,d.donationamount from donations d join shelters s 
on s.shelterid=d.shelterid 
where d.donationamount is not null
order by DonationAmount desc

--9. Write an SQL query that retrieves the names of pets from the "Pets" table that do not have an 
--owner (i.e., where "OwnerID" is null). Include the pet's name, age, breed, and type in the result 
--set
create table owners(
ownerId int primary key identity(2,2),
ownerName varchar(50) not null,
petid int foreign key references pets(petId))

INSERT INTO owners (ownerName, petid)
VALUES
('Alice Johnson', 4), 
('Michael Wilson', 5),  
('Emily Brown', 2)

select p.petid,p.name,p.age,p.breed,p.type,p.Availableforadoption from pets p join owners o on o.petid=p.petid

--10. Write an SQL query that retrieves the total donation amount for each month and year (e.g., 
--January 2023) from the "Donations" table. The result should include the month-year and the 
--corresponding total donation amount. Ensure that the query handles cases where no donations 
--were made in a specific month-year.
SELECT DATEADD(MONTH, DATEDIFF(MONTH, 0, DonationDate), 0) AS MonthYear,SUM(DonationAmount) AS TotalDonationAmount
FROM Donations
WHERE DONATIONAMOUNT IS NOT NULL
GROUP BY DATEADD(MONTH, DATEDIFF(MONTH, 0, DonationDate), 0)
ORDER BY MonthYear;

--11.Retrieve a list of distinct breeds for all pets that are either aged between 1 and 3 years or older
--than 5 years.
SELECT NAME,AGE,BREED FROM PETS WHERE (AGE BETWEEN 1 and 3) or (age>5) order by age desc

--12. Retrieve a list of pets and their respective shelters where the pets are currently available for 
--adoption.

SELECT * FROM SHELTERS
ALTER TABLE SHELTERS 
ADD PETID INT FOREIGN KEY REFERENCES PETS(PETID)

UPDATE SHELTERS SET PETID =3 WHERE SHELTERID=20
UPDATE SHELTERS SET PETID =1 WHERE SHELTERID=25
UPDATE SHELTERS SET PETID =4 WHERE SHELTERID=30
UPDATE SHELTERS SET PETID =2 WHERE SHELTERID=35
UPDATE SHELTERS SET PETID =5 WHERE SHELTERID=40

SELECT P.PETID,P.NAME,P.BREED,P.AGE,P.TYPE,P.AVAILABLEFORADOPTION,SH.Name AS SHELTER_NAME,SH.Location FROM PETS P
JOIN SHELTERS SH ON P.PETID=SH.PETID WHERE P.AVAILABLEFORADOPTION=1

--13. Find the total number of participants in events organized by shelters located in specific city.
--Example: City=Chennai
SELECT * FROM shelters
SELECT * FROM AdoptionEvents


DECLARE @EventCity VARCHAR(100)
SET @EventCity = 'downtown plaza'

SELECT COUNT(*) AS No_participants,p.ParticipantName,p.ParticipantType,ae.EventName,ae.Location 
FROM Participants p 
JOIN AdoptionEvents ae ON p.EventID = ae.EventID 
WHERE ae.location = @EventCity 
GROUP BY p.ParticipantName,p.ParticipantType,ae.EventName,ae.Location

--14. Retrieve a list of unique breeds for pets with ages between 1 and 5 years.select distinct breed,age from pets where age between 1 and 5--15. Find the pets that have not been adopted by selecting their information from the 'Pet' tableselect *from pets where AvailableForAdoption=0--16. Retrieve the names of all adopted pets along with the adopter's name from the 'Adoption' and 
--'User' tables
CREATE TABLE users (
    userid INT PRIMARY KEY IDENTITY(10,20),
    username VARCHAR(50) NOT NULL,
    petid INT FOREIGN KEY REFERENCES pets(petid)
)
INSERT INTO users (username, petid)
VALUES
    ('John', 4),  
    ('Alice', 1), 
    ('Michael', 5),
    ('Emily', 3), 
    ('Sarah', 2)


SELECT P.Name AS PetName,p.breed,p.type,U.userName AS AdopterName
FROM pets p 
JOIN Users U ON u.PetID = P.PetID
where p.availableforadoption=1

--17. Retrieve a list of all shelters along with the count of pets currently available for adoption in each shelter
SELECT 
    S.ShelterID,
    S.Name AS ShelterName,
    COUNT(P.PetID) AS AvailablePetsCount
FROM Shelters S
JOIN Pets P ON S.petID = P.petID
WHERE P.AvailableForAdoption = 1 OR P.AvailableForAdoption IS NULL
GROUP BY S.ShelterID,S.Name

--18. Find pairs of pets from the same shelter that have the same breed.
--i DIDNT CREATE ANYTHING FOR PETS TABLE WITH SAME BREED
SELECT p1.Name AS PetName1,p1.Breed AS Breed,p2.Name AS PetName2
FROM Pets p1
JOIN Pets p2 ON p1.PetID <> p2.PetID AND p1.Breed = p2.Breed
ORDER BY p1.Breed,p1.PetID,p2.PetID

select * from PETS
--19. List all possible combinations of shelters and adoption events.SELECT S.ShelterID,S.Name AS ShelterName,AE.EventID,AE.EventName,AE.Location AS EventLocation
FROM Shelters S
CROSS JOIN AdoptionEvents AE

--20.Determine the shelter that has the highest number of adopted pets
SELECT * FROM SHELTERS
SELECT S.SHELTERID,S.NAME,COUNT(*) AS ADOPTEDPETSCOUNT FROM SHELTERS S JOIN PETS P ON S.PETID=P.PETID
WHERE P.AVAILABLEFORADOPTION=1 GROUP BY S.NAME
