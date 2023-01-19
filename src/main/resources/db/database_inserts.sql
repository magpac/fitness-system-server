INSERT INTO People (FirstName, LastName, PhoneNumber, Email) VALUES 
('Jan', 'Kowalski', '515657963', 'janek.kowalski@mail.com'),
('Anna', 'Nowak', '505207155', 'anna.nowak@mail.com'),
('Antoni', 'Nowakowski', '798505321', 'antek.nowakowski@mail.com')

INSERT INTO Customers (PersonID) VALUES (2),(3)

INSERT INTO EmployeeCategories (JobPosition) VALUES 
('Trainer'), ('Club manager'), ('Receptionist'), ('Cleaning/repair service')

INSERT INTO Employees (PersonID, EmployDate, EndEmployDate, EmployeeCategoryID) VALUES 
(1, '2020-02-02', '2024-12-31', 1)

INSERT INTO ClassIntensities(ClassIntensityID, Intensity) VALUES 
(1,'Low'),
(2, 'Medium'),
(3, 'High')

INSERT INTO Classes (Name, Details, Duration, ClassIntensityID, MaxSeats) VALUES 
('Bodypump', 'Exercises with a barbell, during which all muscle parts are shaped', '50 minutes', 2, 15),
('Pilates', 'Exercises that strengthen, tone and stretch all the muscles of the body', '55 minutes', 1, 1)

INSERT INTO ClassHarmonograms (ClassID, PersonID, StartDate, EndDate, DayOfTheWeek, Hour) VALUES
(1, 1, '2023-01-02', '2023-03-02', 1, '18:00'),
(2, 1, '2023-01-04', '2023-04-04', 3, '19:30')

INSERT INTO ClassDetails (ClassID, Date, PersonID) VALUES 
(1, '2023-01-02', 1),
(2, '2023-01-04', 1)

INSERT INTO ClassRegistrations (PersonID, ClassDetailsID) VALUES 
(2, 1),
(3, 1),
(3, 2)

INSERT INTO TicketTypes(TicketTypeID, Type) VALUES 
(1, 'Periodic'), (2, 'Quantitative')

INSERT INTO Tickets (TicketTypeID, Name, Details, Price) VALUES 
(1, 'Basic1M', 'Ticket for 1 month. Access to gym, swimming pool and all classes.', 129.00),
(1, 'Pro3M', 'Ticket for 3 month. Access to gym, swimming pool and all classes.', 299.00),
(1, 'Best12', 'Ticket for 12 months. Access to gym, swimming pool and all classes.', 999.00),
(2, 'Disposable', 'Single entry ticket. Access to gym, swimming pool and all classes.', 59.00),
(2, 'Lucky13', 'Ticket for 13 entries. Access to gym, swimming pool and all classes.', 389.00)

INSERT INTO TicketsPeriodic (TicketID, ValidityPeriod) VALUES 
(1, 1),
(2, 3),
(3, 12)

INSERT INTO TicketsQuantitative (TicketID, EntrancesLimit) VALUES 
(4, 1),
(5, 13)

INSERT INTO CustomerTickets(PersonID, TicketTypeID, TicketName, PurchaseDate, TicketStartDate, ExpirationDate, EntrancesLimit, Price) VALUES 
(2, 1, 'Basic1M', '2021-01-05', '2021-01-05', '2021-02-05', NULL, 129.00),
(3, 2, 'Disposable', '2021-01-10', NULL, NULL, 1, 59.00),
(3, 2, 'Lucky13', '2021-01-10', NULL, NULL, 13, 389.00),
(3, 1, 'Basic1M', '2023-01-05', '2023-01-06', '2023-02-06', NULL, 129.00)

INSERT INTO Entrances (PersonID, CustomerTicketID, EntranceDate) VALUES 
(2, 1, '2021-01-20'),
(2, 1, '2021-01-24'),
(3, 2, '2021-01-12'),
(3, 3, '2022-01-12')