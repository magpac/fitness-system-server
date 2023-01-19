-- 15/10 TABEL
DROP TABLE Entrances
DROP TABLE CustomerTickets
DROP TABLE TicketsQuantitative
DROP TABLE TicketsPeriodic
DROP TABLE Tickets
DROP TABLE TicketTypes
DROP TABLE ClassRegistrations
DROP TABLE ClassDetails
DROP TABLE ClassHarmonograms
DROP TABLE Classes
DROP TABLE ClassIntensities
DROP TABLE Employees
DROP TABLE EmployeeCategories
DROP TABLE Customers
DROP TABLE People
-- 8/10 WIDOK�W LUB FUNKCJI
DROP FUNCTION hasAvailableSeats
DROP FUNCTION freeEntrances
DROP FUNCTION hasActiveTicket
DROP VIEW CustomerActiveTickets
DROP VIEW ClassDetailsView
DROP VIEW EmployeesView
DROP VIEW CustomersView
DROP VIEW AllTickets
-- 4/5 PROCEDUR
DROP PROCEDURE DisableCustomer
DROP PROCEDURE AddEntrance
DROP PROCEDURE TicketPurchase
DROP PROCEDURE AddClassToHarmonogram
-- 2/5 WYZWALACZY
DROP TRIGGER CustomersViewInsertTrigger
DROP TRIGGER ClassRegistrationsInsertTrigger