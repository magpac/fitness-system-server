CREATE TABLE People (
	PersonID INT IDENTITY(1,1),
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	PhoneNumber CHAR(11) NOT NULL,
	Email NVARCHAR(50) UNIQUE NOT NULL,
	PRIMARY KEY(PersonID)
)

CREATE TABLE Customers (
	PersonID INT,
	RegistrationDate DATETIME DEFAULT GETDATE() NOT NULL,
	IsActive BIT DEFAULT 1 NOT NULL,
	PRIMARY KEY (PersonID),
	FOREIGN KEY (PersonID) REFERENCES People(PersonID)
)
GO
	CREATE VIEW CustomersView AS
		SELECT C.PersonID, P.FirstName, P.LastName, P.PhoneNumber, P.Email, C.RegistrationDate, C.IsActive
		FROM Customers C JOIN People P ON C.PersonID = P.PersonID
GO

GO
	CREATE TRIGGER CustomersViewInsertTrigger ON CustomersView
		INSTEAD OF INSERT
	AS BEGIN
		DECLARE @outputTbl TABLE(PersonID INT)

		INSERT People(FirstName, LastName, PhoneNumber, Email)
			OUTPUT INSERTED.PersonID INTO @outputTbl
		SELECT i.FirstName, i.LastName, i.PhoneNumber, i.Email
		FROM INSERTED i

		INSERT Customers(PersonID)
		SELECT PersonID
		FROM @outputTbl
	END
GO

CREATE TABLE EmployeeCategories (
	EmployeeCategoryID INT IDENTITY(1,1),
	JobPosition NVARCHAR(50) NOT NULL,
	PRIMARY KEY (EmployeeCategoryID)
)

CREATE TABLE Employees (
	PersonID INT,
	EmployDate DATE NOT NULL,
	EndEmployDate DATE,
	EmployeeCategoryID INT NOT NULL,
	PRIMARY KEY (PersonID),
	FOREIGN KEY (PersonID) REFERENCES People(PersonID),
	FOREIGN KEY (EmployeeCategoryID) REFERENCES EmployeeCategories(EmployeeCategoryID)
)

GO
	CREATE VIEW EmployeesView AS
		SELECT E.PersonID, E.EmployeeCategoryID, EC.JobPosition, P.FirstName, P.LastName, P.PhoneNumber, P.Email, E.EmployDate, E.EndEmployDate
		FROM Employees E JOIN People P ON E.PersonID = P.PersonID
		JOIN EmployeeCategories EC ON EC.EmployeeCategoryID = E.EmployeeCategoryID
GO

CREATE TABLE ClassIntensities (
	ClassIntensityID INT,
	Intensity NVARCHAR(11) NOT NULL,
	PRIMARY KEY(ClassIntensityID)
)

CREATE TABLE Classes (
	ClassID INT IDENTITY(1,1),
	Name NVARCHAR(50) NOT NULL,
	Details NVARCHAR(256) NOT NULL,
	Duration NVARCHAR(50) NOT NULL,
	ClassIntensityID INT NOT NULL,
	MaxSeats INT NOT NULL,
	PRIMARY KEY(ClassID),
	FOREIGN KEY (ClassIntensityID) REFERENCES ClassIntensities(ClassIntensityID)
)

CREATE TABLE ClassHarmonograms (
	ClassHarmonogramID INT IDENTITY(1,1),
	ClassID INT NOT NULL,
	PersonID INT NOT NULL,
	StartDate DATE NOT NULL,
	EndDate DATE NOT NULL,
	DayOfTheWeek INT CHECK(DayOfTheWeek >= 1 AND DayOfTheWeek <= 7) NOT NULL,
	Hour TIME NOT NULL,
	PRIMARY KEY(ClassHarmonogramID),
	FOREIGN KEY (ClassID) REFERENCES Classes(ClassID),
	FOREIGN KEY (PersonID) REFERENCES Employees(PersonID)	
)

CREATE TABLE ClassDetails (
	ClassDetailsID INT IDENTITY(1,1),
	ClassID INT NOT NULL,
	Date DATETIME NOT NULL,
	PersonID INT NOT NULL,
	PRIMARY KEY (ClassDetailsID),
	FOREIGN KEY (ClassID) REFERENCES Classes(ClassID),
	FOREIGN KEY (PersonID) REFERENCES Employees(PersonID)
)

GO
	CREATE PROCEDURE AddClassToHarmonogram(@dateToCheck DATE) AS
		SET DATEFIRST 1

		INSERT ClassDetails(ClassID, Date, PersonID)
		SELECT ClassID, CAST (@dateToCheck AS DATETIME) + CAST(HOUR AS DATETIME), PersonID
		FROM ClassHarmonograms
		WHERE @dateToCheck >= StartDate AND @dateToCheck <= EndDate
			AND DayOfTheWeek = DATEPART(weekday, @dateToCheck)
GO

CREATE TABLE ClassRegistrations (
	PersonID INT,
	ClassDetailsID INT,
	PRIMARY KEY (ClassDetailsID, PersonID),
	FOREIGN KEY (ClassDetailsID) REFERENCES ClassDetails(ClassDetailsID),
	FOREIGN KEY (PersonID) REFERENCES Customers(PersonID)
)

GO
	CREATE PROCEDURE DisableCustomer(@personID INT) AS
		UPDATE Customers
		SET IsActive = 0
		WHERE PersonID = @personID

		DELETE CR FROM ClassRegistrations CR
		JOIN ClassDetails CD ON CD.ClassDetailsID = CR.ClassDetailsID
		WHERE CR.PersonID = @personID AND CD.Date > GETDATE()
GO

GO
	CREATE VIEW ClassDetailsView AS
		SELECT CD.ClassID, CD.ClassDetailsID, C.Name, C.Details, C.Duration, 
			CONCAT(P.FirstName, ' ', P.LastName) Instructor, CD.Date, CI.Intensity, C.MaxSeats, IIF(CR.OccupiedSeats IS NULL, 0, CR.OccupiedSeats) OccupiedSeats 
		FROM ClassDetails CD 
		JOIN Classes C ON CD.ClassID = C.ClassID
		JOIN People P ON CD.PersonID = P.PersonID
		JOIN ClassIntensities CI ON C.ClassIntensityID = CI.ClassIntensityID
		LEFT JOIN (
			SELECT ClassDetailsID, COUNT(*) OccupiedSeats FROM ClassRegistrations
			GROUP BY ClassDetailsID
		) CR ON CD.ClassDetailsID = CR.ClassDetailsID
GO

GO
	CREATE FUNCTION hasAvailableSeats(@classDetailsID INT) RETURNS BIT BEGIN
		DECLARE @isAvailable BIT

		SELECT @isAvailable = (CASE WHEN OccupiedSeats < MaxSeats THEN 1 ELSE 0 END)
		FROM ClassDetailsView
		WHERE ClassDetailsID = @classDetailsID

		IF @isAvailable IS NULL BEGIN
			SET @isAvailable = 0
		END

		RETURN @isAvailable
	END
GO

GO
	CREATE TRIGGER ClassRegistrationsInsertTrigger ON ClassRegistrations
		INSTEAD OF INSERT
	AS BEGIN
		DECLARE @isAvailable BIT

		SELECT @isAvailable = dbo.hasAvailableSeats(i.ClassDetailsID)
		FROM INSERTED i

		IF (@isAvailable = 1) BEGIN
			INSERT ClassRegistrations(PersonID, ClassDetailsID)
			SELECT i.PersonID, i.ClassDetailsID
			FROM INSERTED i
		END ELSE BEGIN;
			THROW 50050, 'No available free seats in this class.', 1
		END
	END
GO

CREATE TABLE TicketTypes (
	TicketTypeID INT,
	Type NVARCHAR(20) NOT NULL,
	PRIMARY KEY (TicketTypeID)
)

CREATE TABLE Tickets (
	TicketID INT IDENTITY(1,1),
	TicketTypeID INT NOT NULL,
	Name NVARCHAR(50) NOT NULL,
	Details NVARCHAR(256) NOT NULL,
	Price MONEY NOT NULL,
	PRIMARY KEY (TicketID),
	FOREIGN KEY (TicketTypeID) REFERENCES TicketTypes(TicketTypeID)
)

CREATE TABLE TicketsPeriodic (
	TicketID INT,
	ValidityPeriod INT NOT NULL,
	PRIMARY KEY(TicketID),
	FOREIGN KEY (TicketID) REFERENCES Tickets(TicketID)
)

CREATE TABLE TicketsQuantitative (
	TicketID INT,
	EntrancesLimit SMALLINT NOT NULL,
	PRIMARY KEY(TicketID),
	FOREIGN KEY (TicketID) REFERENCES Tickets(TicketID)
)

CREATE TABLE CustomerTickets (
	CustomerTicketID INT IDENTITY(1, 1),
	PersonID INT NOT NULL,
	TicketTypeID INT NOT NULL,
	TicketName NVARCHAR(50) NOT NULL,
	PurchaseDate DATETIME DEFAULT GETDATE() NOT NULL,
	TicketStartDate DATE,
	ExpirationDate DATE,
	EntrancesLimit SMALLINT,
	Price MONEY NOT NULL,
	PRIMARY KEY(CustomerTicketID),
	FOREIGN KEY (PersonID) REFERENCES Customers(PersonID),
	FOREIGN KEY (TicketTypeID) REFERENCES TicketTypes(TicketTypeID),
	CONSTRAINT maxStartDateCheck CHECK (TicketStartDate IS NULL OR TicketStartDate <=  DATEADD(DAY, 7, PurchaseDate)),
	CONSTRAINT ticketTypeCheck CHECK ((TicketTypeID = 1 AND TicketStartDate IS NOT NULL AND ExpirationDate IS NOT NULL AND EntrancesLimit IS NULL) 
		OR (TicketTypeID = 2 AND TicketStartDate IS NULL AND ExpirationDate IS NULL AND EntrancesLimit IS NOT NULL))
)

CREATE TABLE Entrances ( 
	PersonID INT,
	CustomerTicketID INT NOT NULL,
	EntranceDate DATETIME DEFAULT GETDATE() NOT NULL, -- symulacja odbicia karty na recepcji silowni przy wchodzeniu
	PRIMARY KEY (PersonID, EntranceDate),
	FOREIGN KEY (PersonID) REFERENCES Customers(PersonID),
	FOREIGN KEY (CustomerTicketID) REFERENCES CustomerTickets(CustomerTicketID)
)

GO
	CREATE FUNCTION freeEntrances(@customerTicketID INT) RETURNS INT BEGIN 
		DECLARE @entrancesLimit INT 
		DECLARE @entrancesAmount INT

		SELECT @entrancesLimit = EntrancesLimit
		FROM CustomerTickets CT
		WHERE CT.CustomerTicketID = @customerTicketID 
	
		SELECT @entrancesAmount = COUNT(*) 
		FROM Entrances 
		WHERE CustomerTicketID = @customerTicketID

		RETURN @entrancesLimit - @entrancesAmount
	END
GO

GO
	CREATE VIEW CustomerActiveTickets AS
		-- periodic
		SELECT CustomerTicketID, PersonID, TicketTypeID, IIF(ExpirationDate < GETDATE(), 0, 1) IsActive
		FROM CustomerTickets
		WHERE TicketTypeID = 1
			UNION
		-- quantitative
		SELECT CustomerTicketID, PersonID, TicketTypeID, IIF(dbo.freeEntrances(CustomerTicketID) > 0, 1, 0) IsActive
		FROM CustomerTickets
		WHERE TicketTypeID = 2
GO

GO
	CREATE FUNCTION hasActiveTicket(@personID INT) RETURNS BIT BEGIN
		DECLARE @isActive BIT

		SELECT @isActive = (CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END)
		FROM CustomerActiveTickets
		WHERE PersonID = @personID AND IsActive = 1

		IF @isActive IS NULL BEGIN
			SET @isActive = 0
		END

		RETURN @isActive
	END
GO

GO
	CREATE PROCEDURE AddEntrance(@personID INT) AS
		DECLARE @isActive BIT

		SELECT @isActive = dbo.hasActiveTicket(@personID)

		IF (@isActive = 0) BEGIN;
			THROW 50060, 'Person with no active ticket.', 1
		END

		INSERT Entrances(PersonID, CustomerTicketID)
		SELECT TOP 1 PersonID, CustomerTicketID
		FROM CustomerActiveTickets
		WHERE PersonID = @personID AND IsActive = 1
		ORDER BY TicketTypeID ASC
GO

GO
	CREATE VIEW AllTickets AS
		SELECT T.TicketID, T.TicketTypeID, T.Name, T.Details, T.Price, TP.ValidityPeriod, TQ.EntrancesLimit
		FROM Tickets T
		LEFT JOIN TicketsPeriodic TP ON TP.TicketID = T.TicketID
		LEFT JOIN TicketsQuantitative TQ ON TQ.TicketID = T.TicketID
GO

GO
	CREATE PROCEDURE TicketPurchase (@personID INT, @ticketID INT, @ticketStartDate DATE) AS
		INSERT CustomerTickets (PersonID, TicketTypeID, TicketName, Price, TicketStartDate, ExpirationDate, EntrancesLimit)
		SELECT @personID, TicketTypeID, Name, Price, @ticketStartDate, IIF(TicketTypeID = 1, DATEADD(MONTH, ValidityPeriod, @ticketStartDate), NULL), EntrancesLimit
		FROM AllTickets
		WHERE TicketID = @ticketID
GO
