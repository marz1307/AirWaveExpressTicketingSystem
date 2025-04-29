-- Create the database
CREATE DATABASE AirWaveExpressTicketingSystem;
GO

USE AirWaveExpressTicketingSystem;
GO

-- Create the Employee table
CREATE TABLE Employee (
    EmployeeID VARCHAR(10) PRIMARY KEY,  
    Name NVARCHAR(100) NOT NULL,         
    Username NVARCHAR(50) NOT NULL UNIQUE,
    Password NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    Role NVARCHAR(20) NOT NULL CHECK (Role IN ('Ticketing Staff', 'Ticketing Supervisor')),
    LastLogin DATETIME NULL
);
GO

-- Create a new sequence for generating unique EmployeeID
CREATE SEQUENCE EmployeeSeq
    START WITH 200  -- Start from 200 to avoid conflict with existing EmployeeID
    INCREMENT BY 1;
GO
-- Create a new trigger to generate the EmployeeID using the sequence
CREATE TRIGGER trgGenerateEmployeeID
ON Employee
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NextID INT;

    -- Get the next value from the sequence
    SELECT @NextID = NEXT VALUE FOR EmployeeSeq;

    -- Insert the new employee with the generated EmployeeID (prefix 'EM' + sequence number)
    INSERT INTO Employee (EmployeeID, Username, Password, Name, Email, Role, LastLogin)
    SELECT 'EM' + RIGHT('000' + CAST(@NextID AS VARCHAR(10)), 3), Username, Password, Name, Email, Role, LastLogin
    FROM INSERTED;
END;
GO
-- Create Passenger Table
CREATE TABLE Passenger (
    PassengerID INT PRIMARY KEY IDENTITY(2000,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    DateOfBirth DATE NOT NULL,
    MealPreference NVARCHAR(20) CHECK (MealPreference IN ('Vegetarian', 'Non-Vegetarian')),
    EmergencyContact NVARCHAR(50) NULL
);
GO

-- Create Flight Table
CREATE TABLE Flight (
    FlightID INT PRIMARY KEY IDENTITY(3000,1),
   FlightNumber VARCHAR(10),
    DepartureTime DATETIME NOT NULL,
    ArrivalTime DATETIME NOT NULL,
    Origin NVARCHAR(50) NOT NULL,
    Destination NVARCHAR(50) NOT NULL,
    CONSTRAINT CHK_ArrivalAfterDeparture CHECK (ArrivalTime > DepartureTime)
);
GO

-- Create sequence to generate numeric part of FlightNumber
CREATE SEQUENCE FlightSeq
    START WITH 100  -- Starting value for FlightNumber
    INCREMENT BY 1; -- Increment by 1
GO

-- Create trigger to automatically generate FlightNumber based on FlightSeq
CREATE TRIGGER trgGenerateFlightNumber
ON Flight
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @NextID INT;

    -- Get the next value from the sequence
    SELECT @NextID = NEXT VALUE FOR FlightSeq;

    -- Insert the record with the generated FlightNumber
    INSERT INTO Flight (FlightNumber, DepartureTime, ArrivalTime, Origin, Destination)
    SELECT 'AW' + RIGHT('000' + CAST(@NextID AS VARCHAR(3)), 3), DepartureTime, ArrivalTime, Origin, Destination
    FROM INSERTED;
END;
GO

-- Create Reservation Table
CREATE TABLE Reservation (
    PNR CHAR(10) PRIMARY KEY,
    PassengerID INT NOT NULL,
    BookingDate DATETIME NOT NULL,
    Status NVARCHAR(20) NOT NULL CHECK (Status IN ('Confirmed', 'Pending', 'Cancelled')),
    FOREIGN KEY (PassengerID) REFERENCES Passenger(PassengerID)
);
GO

-- Create Ticket Table
CREATE TABLE Ticket (
    TicketID INT PRIMARY KEY IDENTITY(4000,1),
    PNR CHAR(10) NOT NULL,
    FlightID INT NOT NULL,
    IssueDate DATE NOT NULL DEFAULT GETDATE(),
    IssueTime TIME NOT NULL DEFAULT CONVERT(TIME, GETDATE()),
    Fare DECIMAL(10,2) NOT NULL,
    SeatNumber NVARCHAR(10) NULL,
    Class NVARCHAR(20) NOT NULL CHECK (Class IN ('Economy', 'Business', 'FirstClass')),
    IssuedBy VARCHAR(10) NOT NULL,
    EBoardingNumber NVARCHAR(20) UNIQUE NOT NULL,
    FOREIGN KEY (PNR) REFERENCES Reservation(PNR),
    FOREIGN KEY (FlightID) REFERENCES Flight(FlightID),
    FOREIGN KEY (IssuedBy) REFERENCES Employee(EmployeeID)
);
GO

-- AdditionalServices Table
CREATE TABLE AdditionalServices (
    ServiceID INT PRIMARY KEY IDENTITY(5000,1),
    TicketID INT NOT NULL,
    ExtraBaggageKG DECIMAL(5,2) NULL DEFAULT 0,
    UpgradedMeal BIT NULL DEFAULT 0,
    PreferredSeat BIT NULL DEFAULT 0,
    ServiceFee DECIMAL(10,2) NOT NULL DEFAULT 0,
    FOREIGN KEY (TicketID) REFERENCES Ticket(TicketID)
);
GO

-- Create Baggage Table
CREATE TABLE Baggage (
    BaggageID VARCHAR(15) PRIMARY KEY,  -- Alphanumeric BaggageID (BG + PassengerID)
    PassengerID INT NOT NULL,           -- Foreign Key referencing PassengerID
    TicketID INT NOT NULL,
    Weight DECIMAL(5,2) NOT NULL,
    Status NVARCHAR(20) NOT NULL CHECK (Status IN ('CheckedIn', 'Loaded')),
    Fee DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (PassengerID) REFERENCES Passenger(PassengerID),  -- Foreign key constraint
    FOREIGN KEY (TicketID) REFERENCES Ticket(TicketID)            -- Assuming Ticket table exists
);
GO

-- Create trigger to generate BaggageID
CREATE TRIGGER trgGenerateBaggageID
ON Baggage
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @PassengerID INT;

    -- Get the PassengerID from the inserted row
    SELECT @PassengerID = PassengerID FROM INSERTED;

    -- Insert the record with the generated BaggageID (BG + PassengerID)
    INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee)
    SELECT 'BG' + CAST(@PassengerID AS VARCHAR(10)), PassengerID, TicketID, Weight, Status, Fee
    FROM INSERTED;
END;
GO

INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Haruto', 'Tanaka', 'haruto.tanaka@gmail.com', '1985-05-15', 'Vegetarian', 'Yuki Tanaka');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Yui', 'Sato', 'yui.sato@yahoo.com', '1990-08-22', 'Non-Vegetarian', 'Ken Sato');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('João', 'Silva', 'joao.silva@aol.com', '1982-03-10', 'Vegetarian', 'Maria Silva');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Ana', 'Costa', 'ana.costa@gmx.com', '1995-11-30', 'Non-Vegetarian', 'Pedro Costa');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Gabriel', 'Oliveira', 'gabriel.oliveira@hotmail.com', '1988-07-19', 'Vegetarian', 'Lucas Oliveira');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Isabela', 'Santos', 'isabela.santos@proton.me', '1992-04-25', 'Non-Vegetarian', 'Rafael Santos');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Mwangi', 'Kamau', 'mwangi.kamau@gmail.com', '1980-01-05', 'Vegetarian', 'Wanjiku Kamau');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Achieng', 'Odhiambo', 'achieng.odhiambo@yahoo.com', '1987-09-14', 'Non-Vegetarian', 'Otieno Odhiambo');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Liam', 'Smith', 'liam.smith@aol.com', '1993-06-21', 'Vegetarian', 'Olivia Smith');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Charlotte', 'Brown', 'charlotte.brown@gmx.com', '1989-12-03', 'Non-Vegetarian', 'Noah Brown');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Ethan', 'Johnson', 'ethan.johnson@hotmail.com', '1984-02-17', 'Vegetarian', 'Emma Johnson');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Ava', 'Williams', 'ava.williams@proton.me', '1991-10-29', 'Non-Vegetarian', 'James Williams');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Arjun', 'Sharma', 'arjun.sharma@gmail.com', '1986-11-11', 'Vegetarian', 'Priya Sharma');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Ananya', 'Patel', 'ananya.patel@yahoo.com', '1994-05-07', 'Non-Vegetarian', 'Rohan Patel');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Carlos', 'Hernandez', 'carlos.hernandez@aol.com', '1983-08-18', 'Vegetarian', 'Sofia Hernandez');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Maria', 'Garcia', 'maria.garcia@gmx.com', '1996-03-23', 'Non-Vegetarian', 'Jose Garcia');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Oskar', 'Hansen', 'oskar.hansen@hotmail.com', '1981-12-27', 'Vegetarian', 'Ingrid Hansen');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Emma', 'Larsen', 'emma.larsen@proton.me', '1990-07-09', 'Non-Vegetarian', 'Nikolai Larsen');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Thabo', 'Nkosi', 'thabo.nkosi@gmail.com', '1985-04-14', 'Vegetarian', 'Zanele Nkosi');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Zinhle', 'Dlamini', 'zinhle.dlamini@yahoo.com', '1992-10-05', 'Non-Vegetarian', 'Sipho Dlamini');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Mateo', 'Gonzalez', 'mateo.gonzalez@aol.com', '1987-06-30', 'Vegetarian', 'Valentina Gonzalez');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Sofia', 'Lopez', 'sofia.lopez@gmx.com', '1993-01-19', 'Non-Vegetarian', 'Lucas Lopez');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Oliver', 'Wilson', 'oliver.wilson@hotmail.com', '1989-09-25', 'Vegetarian', 'Isla Wilson');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Amelia', 'Taylor', 'amelia.taylor@proton.me', '1991-03-12', 'Non-Vegetarian', 'Jack Taylor');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Ivan', 'Ivanov', 'ivan.ivanov@gmail.com', '1984-02-28', 'Vegetarian', 'Anastasia Ivanov');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Anastasia', 'Petrova', 'anastasia.petrova@yahoo.com', '1990-11-16', 'Non-Vegetarian', 'Dmitry Petrova');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Ahmed', 'Hassan', 'ahmed.hassan@aol.com', '1982-07-04', 'Vegetarian', 'Fatima Hassan');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Sara', 'Ali', 'sara.ali@gmx.com', '1995-09-08', 'Non-Vegetarian', 'Omar Ali');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Luca', 'Rossi', 'luca.rossi@hotmail.com', '1986-05-22', 'Vegetarian', 'Giulia Rossi');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Giulia', 'Bianchi', 'giulia.bianchi@proton.me', '1993-12-14', 'Non-Vegetarian', 'Marco Bianchi');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Napat', 'Sukhum', 'napat.sukhum@gmail.com', '1988-03-03', 'Vegetarian', 'Pim Sukhum');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Arisa', 'Wong', 'arisa.wong@yahoo.com', '1991-08-29', 'Non-Vegetarian', 'Somchai Wong');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Diego', 'Torres', 'diego.torres@aol.com', '1983-10-10', 'Vegetarian', 'Camila Torres');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Valentina', 'Diaz', 'valentina.diaz@gmx.com', '1994-06-15', 'Non-Vegetarian', 'Sebastian Diaz');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('James', 'Miller', 'james.miller@hotmail.com', '1985-01-20', 'Vegetarian', 'Emily Miller');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Sophia', 'Davis', 'sophia.davis@proton.me', '1992-04-07', 'Non-Vegetarian', 'Michael Davis');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Jone', 'Kumar', 'jone.kumar@gmail.com', '1987-11-05', 'Vegetarian', 'Litia Kumar');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Adi', 'Singh', 'adi.singh@yahoo.com', '1990-02-14', 'Non-Vegetarian', 'Raj Singh');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Nikos', 'Papadopoulos', 'nikos.papadopoulos@aol.com', '1984-09-17', 'Vegetarian', 'Maria Papadopoulos');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Eleni', 'Georgiou', 'eleni.georgiou@gmx.com', '1991-12-25', 'Non-Vegetarian', 'Kostas Georgiou');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Sakura', 'Yamamoto', 'sakura.yamamoto@gmail.com', '1986-04-12', 'Vegetarian', 'Hiroshi Yamamoto');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Ren', 'Kobayashi', 'ren.kobayashi@yahoo.com', '1993-07-21', 'Non-Vegetarian', 'Aiko Kobayashi');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Miguel', 'Ferreira', 'miguel.ferreira@aol.com', '1989-02-08', 'Vegetarian', 'Rita Ferreira');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Beatriz', 'Martins', 'beatriz.martins@gmx.com', '1994-10-30', 'Non-Vegetarian', 'Tiago Martins');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Lucas', 'Costa', 'lucas.costa@hotmail.com', '1987-06-15', 'Vegetarian', 'Fernanda Costa');
INSERT INTO Passenger (FirstName, LastName, Email, DateOfBirth, MealPreference, EmergencyContact) VALUES ('Mariana', 'Lima', 'mariana.lima@proton.me', '1992-03-27', 'Non-Vegetarian', 'Bruno Lima'); 
GO

SELECT * FROM Passenger

-- Insert sample employee records with specific EmployeeID values
INSERT INTO Employee (EmployeeID, Username, Password, Name, Email, Role, LastLogin)
VALUES ('EM201', 'chinedu.okeke', 'securePass123', 'Chinedu Okeke', 'chinedu.okeke@airwave.com', 'Ticketing Staff', '2025-04-23 08:30:00');
GO

INSERT INTO Employee (EmployeeID, Username, Password, Name, Email, Role, LastLogin)
VALUES ('EM202', 'adaobi.nwosu', 'strongPass456', 'Adaobi Nwosu', 'adaobi.nwosu@airwave.com', 'Ticketing Supervisor', '2025-04-23 09:15:00');
GO

INSERT INTO Employee (EmployeeID, Username, Password, Name, Email, Role, LastLogin)
VALUES ('EM203', 'uchechukwuEze', 'passWord321', 'Uchechukwu Eze', 'uchechukwu.eze@airwave.com', 'Ticketing Staff', '2025-04-23 11:00:00');
GO

INSERT INTO Employee (EmployeeID, Username, Password, Name, Email, Role, LastLogin)
VALUES ('EM204', 'nkechiOkafor', 'passWord654', 'Nkechi Okafor', 'nkechi.okafor@airwave.com', 'Ticketing Supervisor', '2025-04-23 11:30:00');
GO

INSERT INTO Employee (EmployeeID, Username, Password, Name, Email, Role, LastLogin)
VALUES ('EM205', 'chukwudiNnaji', 'passWord987', 'Chukwudi Nnaji', 'chukwudi.nnaji@airwave.com', 'Ticketing Staff', '2025-04-23 12:00:00');
GO

INSERT INTO Employee (EmployeeID, Username, Password, Name, Email, Role, LastLogin)
VALUES ('EM206', 'ifeanyiUgwu', 'safePass789', 'Ifeanyi Ugwu', 'ifeanyi.ugwu@airwave.com', 'Ticketing Staff', '2025-04-23 10:00:00');
GO

-- Insert sample flight records
INSERT INTO Flight (FlightNumber, DepartureTime, ArrivalTime, Origin, Destination)
VALUES ('AW001', '2025-05-01 08:00:00', '2025-05-01 12:00:00', 'Tokyo Narita', 'Los Angeles');
GO

INSERT INTO Flight (FlightNumber, DepartureTime, ArrivalTime, Origin, Destination)
VALUES ('AW002', '2025-05-02 09:00:00', '2025-05-02 13:00:00', 'Lisbon', 'New York JFK');
GO

Select* from Flight;

-- Insert reservation data passengers
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0001', 2000, '2025-04-20 08:00:00', 'Confirmed');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0002', 2001, '2025-04-20 09:00:00', 'Pending');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0003', 2002, '2025-04-20 10:00:00', 'Confirmed');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0004', 2003, '2025-04-20 11:00:00', 'Cancelled');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0005', 2004, '2025-04-20 12:00:00', 'Pending');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0006', 2005, '2025-04-21 08:15:00', 'Confirmed');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0007', 2006, '2025-04-21 09:30:00', 'Pending');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0008', 2007, '2025-04-21 10:45:00', 'Cancelled');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0009', 2008, '2025-04-21 11:30:00', 'Confirmed');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0010', 2009, '2025-04-21 12:00:00', 'Pending');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0011', 2010, '2025-04-22 08:00:00', 'Confirmed');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0012', 2011, '2025-04-22 09:00:00', 'Cancelled');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0013', 2012, '2025-04-22 10:30:00', 'Pending');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0014', 2013, '2025-04-22 11:30:00', 'Confirmed');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0015', 2014, '2025-04-22 12:15:00', 'Pending');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0016', 2015, '2025-04-23 08:30:00', 'Confirmed');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0017', 2016, '2025-04-23 09:00:00', 'Cancelled');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0018', 2017, '2025-04-23 10:00:00', 'Pending');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0019', 2018, '2025-04-23 11:00:00', 'Confirmed');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0020', 2019, '2025-04-23 12:00:00', 'Pending');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0021', 2020, '2025-04-24 08:15:00', 'Confirmed');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0022', 2021, '2025-04-24 09:30:00', 'Cancelled');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0023', 2022, '2025-04-24 10:45:00', 'Pending');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0024', 2023, '2025-04-24 11:15:00', 'Confirmed');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0025', 2024, '2025-04-24 12:00:00', 'Pending');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0026', 2025, '2025-04-25 08:00:00', 'Cancelled');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0027', 2026, '2025-04-25 09:00:00', 'Confirmed');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0028', 2027, '2025-04-25 10:00:00', 'Pending');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0029', 2028, '2025-04-25 11:15:00', 'Confirmed');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0030', 2029, '2025-04-25 12:00:00', 'Cancelled');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0031', 2030, '2025-04-26 08:30:00', 'Pending');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0032', 2031, '2025-04-26 09:00:00', 'Confirmed');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0033', 2032, '2025-04-26 10:00:00', 'Pending');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0034', 2033, '2025-04-26 11:00:00', 'Cancelled');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0035', 2034, '2025-04-26 12:00:00', 'Confirmed');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0036', 2035, '2025-04-27 08:00:00', 'Pending');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0037', 2036, '2025-04-27 09:00:00', 'Cancelled');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0038', 2037, '2025-04-27 10:00:00', 'Confirmed');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0039', 2038, '2025-04-27 11:15:00', 'Pending');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0040', 2039, '2025-04-27 12:00:00', 'Cancelled');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0041', 2040, '2025-04-28 08:00:00', 'Confirmed');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0042', 2041, '2025-04-28 09:00:00', 'Pending');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0043', 2042, '2025-04-28 10:15:00', 'Confirmed');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0044', 2043, '2025-04-28 11:30:00', 'Cancelled');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0045', 2044, '2025-04-28 12:00:00', 'Pending');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0046', 2045, '2025-04-29 08:30:00', 'Confirmed');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0047', 2046, '2025-04-29 09:00:00', 'Pending');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0048', 2047, '2025-04-29 10:00:00', 'Cancelled');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0049', 2048, '2025-04-29 11:15:00', 'Confirmed');
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status) VALUES ('PNR0050', 2049, '2025-04-29 12:00:00', 'Pending');
GO

SELECT * FROM Reservation

-- Insert  ticket data
INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0001', 3000, 203.75, 'A1', 'Business', 'EM202', 'EBN0001');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0002', 3001, 207.5, 'A2', 'FirstClass', 'EM203', 'EBN0002');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0003', 3002, 211.25, 'A3', 'Economy', 'EM204', 'EBN0003');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0004', 3003, 215.0, 'A4', 'Business', 'EM205', 'EBN0004');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0005', 3000, 218.75, 'A5', 'FirstClass', 'EM206', 'EBN0005');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0006', 3001, 222.5, 'A6', 'Economy', 'EM201', 'EBN0006');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0007', 3002, 226.25, 'A7', 'Business', 'EM202', 'EBN0007');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0008', 3003, 230.0, 'A8', 'FirstClass', 'EM203', 'EBN0008');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0009', 3000, 233.75, 'A9', 'Economy', 'EM204', 'EBN0009');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0010', 3001, 237.5, 'A10', 'Business', 'EM205', 'EBN0010');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0011', 3002, 241.25, 'A11', 'FirstClass', 'EM206', 'EBN0011');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0012', 3003, 245.0, 'A12', 'Economy', 'EM201', 'EBN0012');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0013', 3000, 248.75, 'A13', 'Business', 'EM202', 'EBN0013');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0014', 3001, 252.5, 'A14', 'FirstClass', 'EM203', 'EBN0014');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0015', 3002, 256.25, 'A15', 'Economy', 'EM204', 'EBN0015');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0016', 3003, 260.0, 'A16', 'Business', 'EM205', 'EBN0016');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0017', 3000, 263.75, 'A17', 'FirstClass', 'EM206', 'EBN0017');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0018', 3001, 267.5, 'A18', 'Economy', 'EM201', 'EBN0018');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0019', 3002, 271.25, 'A19', 'Business', 'EM202', 'EBN0019');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0020', 3003, 275.0, 'A20', 'FirstClass', 'EM203', 'EBN0020');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0021', 3000, 278.75, 'A21', 'Economy', 'EM204', 'EBN0021');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0022', 3001, 282.5, 'A22', 'Business', 'EM205', 'EBN0022');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0023', 3002, 286.25, 'A23', 'FirstClass', 'EM206', 'EBN0023');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0024', 3003, 290.0, 'A24', 'Economy', 'EM201', 'EBN0024');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0025', 3000, 293.75, 'A25', 'Business', 'EM202', 'EBN0025');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0026', 3001, 297.5, 'A26', 'FirstClass', 'EM203', 'EBN0026');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0027', 3002, 301.25, 'A27', 'Economy', 'EM204', 'EBN0027');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0028', 3003, 305.0, 'A28', 'Business', 'EM205', 'EBN0028');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0029', 3000, 308.75, 'A29', 'FirstClass', 'EM206', 'EBN0029');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0030', 3001, 312.5, 'A30', 'Economy', 'EM201', 'EBN0030');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0031', 3002, 316.25, 'A31', 'Business', 'EM202', 'EBN0031');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0032', 3003, 320.0, 'A32', 'FirstClass', 'EM203', 'EBN0032');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0033', 3000, 323.75, 'A33', 'Economy', 'EM204', 'EBN0033');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0034', 3001, 327.5, 'A34', 'Business', 'EM205', 'EBN0034');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0035', 3002, 331.25, 'A35', 'FirstClass', 'EM206', 'EBN0035');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0036', 3003, 335.0, 'A36', 'Economy', 'EM201', 'EBN0036');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0037', 3000, 338.75, 'A37', 'Business', 'EM202', 'EBN0037');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0038', 3001, 342.5, 'A38', 'FirstClass', 'EM203', 'EBN0038');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0039', 3002, 346.25, 'A39', 'Economy', 'EM204', 'EBN0039');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0040', 3003, 350.0, 'A40', 'Business', 'EM205', 'EBN0040');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0041', 3000, 353.75, 'A41', 'FirstClass', 'EM206', 'EBN0041');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0042', 3001, 357.5, 'A42', 'Economy', 'EM201', 'EBN0042');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0043', 3002, 361.25, 'A43', 'Business', 'EM202', 'EBN0043');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0044', 3003, 365.0, 'A44', 'FirstClass', 'EM203', 'EBN0044');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0045', 3000, 368.75, 'A45', 'Economy', 'EM204', 'EBN0045');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0046', 3001, 372.5, 'A46', 'Business', 'EM205', 'EBN0046');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0047', 3002, 376.25, 'A47', 'FirstClass', 'EM206', 'EBN0047');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0048', 3003, 380.0, 'A48', 'Economy', 'EM201', 'EBN0048');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0049', 3000, 383.75, 'A49', 'Business', 'EM202', 'EBN0049');

INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
VALUES ('PNR0050', 3001, 387.5, 'A50', 'FirstClass', 'EM203', 'EBN0050');
GO

select * from Ticket

-- INSERT data for additional services
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4088, 1.13, 0, 0, 5.65);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4089, 24.63, 1, 0, 143.15);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4090, 12.14, 1, 1, 90.7);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4091, 26.33, 0, 1, 141.65);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4092, 8.81, 1, 1, 74.05);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4093, 28.17, 0, 1, 150.85);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4094, 13.83, 0, 1, 79.15);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4095, 21.25, 0, 0, 106.25);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4096, 2.11, 1, 0, 30.55);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4097, 21.36, 0, 1, 116.8);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4098, 16.76, 1, 1, 113.8);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4099, 8.26, 1, 0, 61.3);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4100, 24.61, 1, 1, 153.05);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4101, 27.33, 1, 0, 156.65);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4102, 5.7, 0, 0, 28.5);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4103, 29.14, 0, 1, 155.7);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4104, 18.48, 0, 1, 102.4);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4105, 22.74, 0, 0, 113.7);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4106, 13.18, 1, 1, 95.9);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4107, 2.76, 0, 1, 23.8);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4108, 11.04, 0, 1, 65.2);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4109, 19.82, 1, 1, 129.1);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4110, 10.45, 0, 1, 62.25);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4111, 10.21, 1, 1, 81.05);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4112, 7.23, 0, 1, 46.15);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4113, 6.27, 1, 1, 61.35);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4114, 3.98, 1, 1, 49.9);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4115, 24.67, 1, 0, 143.35);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4116, 26.87, 1, 1, 164.35);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4117, 4.89, 0, 1, 34.45);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4118, 27.73, 0, 1, 148.65);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4119, 12.26, 0, 0, 61.3);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4120, 4.55, 1, 0, 42.75);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4121, 9.74, 1, 1, 78.7);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4122, 13.59, 0, 1, 77.95);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4123, 4.31, 1, 0, 41.55);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4124, 21.91, 1, 0, 129.55);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4125, 29.61, 0, 0, 148.05);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4126, 2.74, 1, 1, 43.7);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4127, 24.65, 1, 1, 153.25);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4128, 12.06, 0, 0, 60.3);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4129, 29.54, 1, 0, 167.7);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4130, 5.3, 1, 0, 46.5);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4131, 24.24, 0, 1, 131.2);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4132, 1.13, 0, 0, 5.65);
INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
VALUES (4133, 29.78, 0, 0, 148.9);
GO

select * from AdditionalServices


-- Baggage Data
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG3000', 2005, 4093, 25.98, 'Loaded', 259.8);
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG3001', 2008, 4096, 24.95, 'Loaded', 249.5);
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG3002', 2010, 4101, 26.82, 'Loaded', 268.2);
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG3003', 2013, 4101, 26.78, 'CheckedIn', 267.8);
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG3004', 2015, 4103, 18.29, 'CheckedIn', 182.9);
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG3005', 2023, 4111, 23.8, 'Loaded', 238.0);
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG3006', 2024, 4112, 21.0, 'Loaded', 210.0);
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG3007', 2026, 4114, 26.19, 'Loaded', 261.9);
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG3008', 2028, 4116, 22.0, 'CheckedIn', 220.0);
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG3009', 2031, 4119, 27.86, 'Loaded', 278.6);
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG3010', 2034, 4122, 25.61, 'CheckedIn', 256.1);
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG3011', 2037, 4125, 22.1, 'CheckedIn', 221.0);
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG3012', 2040, 4128, 21.01, 'Loaded', 210.1);
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG3013', 2042, 4130, 27.91, 'Loaded', 279.1);
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG3014', 2045, 4133, 20.5, 'Loaded', 205.0);
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG3015', 2009, 4097, 19.96, 'CheckedIn', 199.6);
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG3016', 2027, 4115, 25.42, 'CheckedIn', 254.2);
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG3017', 2035, 4123, 15.53, 'Loaded', 155.3);
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG3018', 2041, 4129, 27.37, 'CheckedIn', 273.7);
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG3019', 2044, 4132, 16.19, 'CheckedIn', 161.9);
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG2000', 2000, 4088, 22.75, 'CheckedIn', 227.50);
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG2001', 2001, 4089, 24.90, 'Loaded', 249.00);
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG2002', 2002, 4090, 21.35, 'CheckedIn', 213.50);
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG2003', 2003, 4091, 19.65, 'Loaded', 196.50);
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG2018', 2018, 4106, 23.74, 'CheckedIn', 237.40);
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG2019', 2019, 4107, 26.13, 'Loaded', 261.30);
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG2020', 2020, 4108, 25.98, 'CheckedIn', 259.80);
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG2021', 2021, 4109, 27.40, 'Loaded', 274.00);
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG2032', 2032, 4120, 22.67, 'CheckedIn', 226.70);
INSERT INTO Baggage (BaggageID, PassengerID, TicketID, Weight, Status, Fee) VALUES ('BG2033', 2033, 4121, 20.90, 'Loaded', 209.00);
GO

select * from Baggage

-- Procedure to issue a new ticket

CREATE PROCEDURE sp_IssueTicket
    @PNR NVARCHAR(10),
    @FlightID INT,
    @Fare DECIMAL(10,2),
    @SeatNumber NVARCHAR(10) = NULL,
    @Class NVARCHAR(20),
    @EmployeeID INT,
    @ExtraBaggageKG DECIMAL(5,2) = 0,
    @UpgradedMeal BIT = 0,
    @PreferredSeat BIT = 0
AS
BEGIN
    DECLARE @EBoardingNumber NVARCHAR(20)
    DECLARE @TicketID INT

    -- Generate a unique EBoardingNumber
    SET @EBoardingNumber = 'EB' + CAST(@FlightID AS NVARCHAR(10)) + CAST(DATEPART(YEAR, GETDATE()) AS NVARCHAR(4)) + CAST(DATEPART(MONTH, GETDATE()) AS NVARCHAR(2)) + CAST(DATEPART(DAY, GETDATE()) AS NVARCHAR(2)) + CAST(DATEPART(HOUR, GETDATE()) AS NVARCHAR(2)) + CAST(DATEPART(MINUTE, GETDATE()) AS NVARCHAR(2)) + CAST(DATEPART(SECOND, GETDATE()) AS NVARCHAR(2))

    -- Insert the new ticket
    INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
    VALUES (@PNR, @FlightID, @Fare, @SeatNumber, @Class, @EmployeeID, @EBoardingNumber)

    -- Get the TicketID of the newly inserted ticket
    SET @TicketID = SCOPE_IDENTITY()

    -- Insert additional services if any
    INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat)
    VALUES (@TicketID, @ExtraBaggageKG, @UpgradedMeal, @PreferredSeat)

    -- Return the TicketID and EBoardingNumber
    SELECT @TicketID AS TicketID, @EBoardingNumber AS EBoardingNumber
END
GO


-- Procedure to authenticate employee
CREATE PROCEDURE sp_AuthenticateEmployee
    @Username NVARCHAR(50),
    @Password NVARCHAR(100)
AS
BEGIN
    -- In a real implementation, compare hashed passwords
    SELECT EmployeeID, Name, Email, Role 
    FROM Employee 
    WHERE Username = @Username AND Password = @Password
    
    -- Update last login time if authentication is successful
    IF @@ROWCOUNT > 0
        UPDATE Employee SET LastLogin = GETDATE() WHERE Username = @Username
END
GO

--DATABASE OBJECTS - VIEWS
-- View for flight manifest
CREATE VIEW vw_FlightManifest AS
SELECT 
    f.FlightNumber,
    f.DepartureTime,
    f.Origin,
    f.Destination,
    p.FirstName + ' ' + p.LastName AS PassengerName,
    t.SeatNumber,
    t.Class,
    p.MealPreference,
    b.Weight AS BaggageWeight,
    b.Status AS BaggageStatus
FROM Flight f
JOIN Ticket t ON f.FlightID = t.FlightID
JOIN Reservation r ON t.PNR = r.PNR
JOIN Passenger p ON r.PassengerID = p.PassengerID
JOIN Baggage b ON t.TicketID = b.TicketID
GO


-- View for employee activity
CREATE VIEW vw_EmployeeActivity AS
SELECT 
    e.EmployeeID,
    e.Name,
    e.Role,
    COUNT(t.TicketID) AS TicketsIssued,
    SUM(t.Fare + ISNULL(a.ServiceFee, 0)) AS TotalRevenueGenerated
FROM Employee e
LEFT JOIN Ticket t ON e.EmployeeID = t.IssuedBy
LEFT JOIN AdditionalServices a ON t.TicketID = a.TicketID
GROUP BY e.EmployeeID, e.Name, e.Role
GO


-- Trigger to calculate and update service fee when additional services are modified
CREATE TRIGGER tr_UpdateServiceFee
ON AdditionalServices
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE a
    SET a.ServiceFee = 
        (i.ExtraBaggageKG * 100) + 
        (CASE WHEN i.UpgradedMeal = 1 THEN 20 ELSE 0 END) + 
        (CASE WHEN i.PreferredSeat = 1 THEN 30 ELSE 0 END)
    FROM AdditionalServices a
    INNER JOIN inserted i ON a.ServiceID = i.ServiceID
END
GO

-- Trigger to prevent ticket modification after issuance
CREATE TRIGGER tr_PreventTicketModification
ON Ticket
AFTER UPDATE
AS
BEGIN
    IF UPDATE(IssueDate) OR UPDATE(IssueTime) OR UPDATE(EBoardingNumber)
    BEGIN
        RAISERROR('Ticket details cannot be modified after issuance', 16, 1)
        ROLLBACK TRANSACTION
    END
END
GO

--DATABASE OBJECTS - USER DEFINED FUNCTIONS
-- Function to calculate total fare for a ticket
CREATE FUNCTION fn_CalculateTotalFare (@TicketID INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @TotalFare DECIMAL(10,2)
    
    SELECT @TotalFare = t.Fare + ISNULL(a.ServiceFee, 0)
    FROM Ticket t
    LEFT JOIN AdditionalServices a ON t.TicketID = a.TicketID
    WHERE t.TicketID = @TicketID
    
    RETURN @TotalFare
END
GO

-- Function to get passenger itinerary
CREATE FUNCTION fn_GetPassengerItinerary (@PassengerID INT)
RETURNS TABLE
AS
RETURN (
    SELECT 
        p.FirstName + ' ' + p.LastName AS PassengerName,
        f.FlightNumber,
        f.DepartureTime,
        f.ArrivalTime,
        f.Origin,
        f.Destination,
        t.SeatNumber,
        t.Class,
        t.EBoardingNumber,
        dbo.fn_CalculateTotalFare(t.TicketID) AS TotalFare,
        r.Status AS ReservationStatus
    FROM Passenger p
    JOIN Reservation r ON p.PassengerID = r.PassengerID
    JOIN Ticket t ON r.PNR = t.PNR
    JOIN Flight f ON t.FlightID = f.FlightID
    WHERE p.PassengerID = @PassengerID
)
GO

-- Question 2

ALTER TABLE Reservation
WITH NOCHECK
ADD CONSTRAINT CHK_BookingDateNotPast CHECK (CAST(BookingDate AS DATE) >= CAST(GETDATE() AS DATE));


-- Succeeds: future date
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status)
VALUES ('TEST003', 2003, DATEADD(DAY, 1, GETDATE()), 'Confirmed');

-- Succeeds: current date
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status)
VALUES ('TEST0005', 2001, GETDATE(), 'Confirmed');

-- Fails: past date
INSERT INTO Reservation (PNR, PassengerID, BookingDate, Status)
VALUES ('TEST0006', 2000, DATEADD(DAY, -1, GETDATE()), 'Confirmed');

--The INSERT statement conflicted with the CHECK constraint "CHK_BookingDateNotPast".

--QUESTION 3 - create a query to identify passengers who meet both criteria: having pending reservations and being over 40 years old

WITH PassengerAge AS (
    SELECT 
        p.PassengerID,
        p.FirstName + ' ' + p.LastName AS PassengerName,
        p.Email,
        p.DateOfBirth,
        -- Accurate age calculation
        DATEDIFF(YEAR, p.DateOfBirth, GETDATE()) - 
            CASE 
                WHEN DATEADD(YEAR, DATEDIFF(YEAR, p.DateOfBirth, GETDATE()), p.DateOfBirth) > GETDATE() 
                THEN 1 
                ELSE 0 
            END AS Age
    FROM 
        Passenger p
)
SELECT 
    pa.PassengerID,
    pa.PassengerName,
    pa.Email,
    pa.DateOfBirth,
    pa.Age,
    r.PNR,
    r.BookingDate,
    r.Status AS ReservationStatus
FROM 
    PassengerAge pa
JOIN 
    Reservation r ON pa.PassengerID = r.PassengerID
WHERE 
    r.Status = 'Pending'
    AND pa.Age > 40
ORDER BY 
    pa.Age DESC, pa.PassengerName;




----QUESTION 4 - USING STORED PROCEDURES AND FUNCTIONS
---QUESTION 4A - SEARCH BY PASSENGER LAST NAME


CREATE PROCEDURE sp_SearchPassengersByLastName
    @LastName NVARCHAR(50)
AS
BEGIN
    SELECT 
        p.PassengerID,
        p.FirstName,
        p.LastName,
        p.Email,
        p.DateOfBirth,
        t.TicketID,
        t.IssueDate,
        t.IssueTime,
        f.FlightNumber,
        f.DepartureTime,
        f.Origin,
        f.Destination
    FROM 
        Passenger p
    JOIN 
        Reservation r ON p.PassengerID = r.PassengerID
    JOIN 
        Ticket t ON r.PNR = t.PNR
    JOIN 
        Flight f ON t.FlightID = f.FlightID
    WHERE 
        p.LastName LIKE '%' + @LastName + '%'
    ORDER BY 
        t.IssueDate DESC, t.IssueTime DESC;
END
GO

--SAMPLE EXAMPLE FOR ABOVE PROCEDURE
EXEC sp_SearchPassengersByLastName @LastName = 'Sato';


CREATE PROCEDURE sp_GetBusinessClassPassengersWithMealsToday
AS
BEGIN
    SELECT 
        p.PassengerID,
        p.FirstName + ' ' + p.LastName AS PassengerName,
        p.MealPreference,
        r.PNR,
        t.TicketID,
        t.Class,
        f.FlightNumber,
        f.DepartureTime,
        f.Origin,
        f.Destination
    FROM 
        Passenger p
    JOIN 
        Reservation r ON p.PassengerID = r.PassengerID
    JOIN 
        Ticket t ON r.PNR = t.PNR
    JOIN 
        Flight f ON t.FlightID = f.FlightID
    WHERE 
        CAST(r.BookingDate AS DATE) = CAST(GETDATE() AS DATE)
        AND t.Class = 'Business'
        AND p.MealPreference IS NOT NULL
    ORDER BY 
        p.LastName, p.FirstName;
END
GO

--USUAGE EXAMPLE
EXEC sp_GetBusinessClassPassengersWithMealsToday;

--QUESTION 4C - Insert New Employee

CREATE PROCEDURE sp_InsertNewEmployee
    @Username NVARCHAR(50),
    @Password NVARCHAR(100),
    @Name NVARCHAR(100),
    @Email NVARCHAR(100),
    @Role NVARCHAR(20)
AS
BEGIN
    -- Validate role
    IF @Role NOT IN ('Ticketing Staff', 'Ticketing Supervisor')
    BEGIN
        RAISERROR('Invalid role specified. Must be either "Ticketing Staff" or "Ticketing Supervisor".', 16, 1)
        RETURN
    END
    
    BEGIN TRY
        INSERT INTO Employee (Username, Password, Name, Email, Role)
        VALUES (@Username, @Password, @Name, @Email, @Role)
        
        SELECT 
            EmployeeID,
            Username,
            Name,
            Email,
            Role,
            'Employee added successfully' AS Message
        FROM 
            Employee
        WHERE 
            EmployeeID = SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 2627 -- Unique constraint violation
        BEGIN
            RAISERROR('Username or email already exists. Please use different credentials.', 16, 1)
        END
        ELSE
        BEGIN
            RAISERROR('Error occurred while adding new employee: %s', 16, 1)
        END
    END CATCH
END
GO

EXEC sp_InsertNewEmployee 
    @Username = 'carchuks223',
    @Password = 'securepass456',
    @Name = 'Christianar Chuksar',
    @Email = 'christianar.chuksar@airwave.com',
    @Role = 'Ticketing Staff';

	select * from Employee

    --- 4D

	CREATE PROCEDURE sp_UpdatePassengerDetails
    @PassengerID INT,
    @FirstName NVARCHAR(50) = NULL,
    @LastName NVARCHAR(50) = NULL,
    @Email NVARCHAR(100) = NULL,
    @DateOfBirth DATE = NULL,
    @MealPreference NVARCHAR(20) = NULL,
    @EmergencyContact NVARCHAR(20) = NULL
AS
BEGIN
    -- Check if passenger exists and has bookings
    IF NOT EXISTS (SELECT 1 FROM Passenger WHERE PassengerID = @PassengerID)
    BEGIN
        RAISERROR('Passenger not found.', 16, 1)
        RETURN
    END

    -- Check if passenger has any reservations

   CREATE PROCEDURE sp_UpdatePassengerDetails
    @PassengerID INT,
    @FirstName NVARCHAR(50) = NULL,
    @LastName NVARCHAR(50) = NULL,
    @Email NVARCHAR(100) = NULL,
    @DateOfBirth DATE = NULL,
    @MealPreference NVARCHAR(20) = NULL,
    @EmergencyContact NVARCHAR(20) = NULL
AS
BEGIN
    -- Check if passenger exists
    IF NOT EXISTS (SELECT 1 FROM Passenger WHERE PassengerID = @PassengerID)
    BEGIN
        RAISERROR('Passenger not found.', 16, 1)
        RETURN
    END

    -- Check if passenger has any reservations
    IF NOT EXISTS (SELECT 1 FROM Reservation WHERE PassengerID = @PassengerID)
    BEGIN
        RAISERROR('Passenger has no existing reservations.', 16, 1)
        RETURN
    END

    BEGIN TRY
        UPDATE Passenger
        SET 
            FirstName = ISNULL(@FirstName, FirstName),
            LastName = ISNULL(@LastName, LastName),
            Email = ISNULL(@Email, Email),
            DateOfBirth = ISNULL(@DateOfBirth, DateOfBirth),
            MealPreference = @MealPreference, -- NULL is allowed
            EmergencyContact = @EmergencyContact -- NULL is allowed
        WHERE 
            PassengerID = @PassengerID;
            
        SELECT 
            PassengerID,
            FirstName,
            LastName,
            Email,
            DateOfBirth,
            MealPreference,
            EmergencyContact,
            'Passenger details updated successfully. Reservation verified.' AS Message
        FROM 
            Passenger
        WHERE 
            PassengerID = @PassengerID;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 2627 -- Unique constraint violation
        BEGIN
            RAISERROR('Email address already exists. Please use a different email.', 16, 1)
        END
        ELSE
        BEGIN
            DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
            RAISERROR(@ErrMsg, 16, 1);
        END
    END CATCH
END
GO

--USAGE EXAMPLE
EXEC sp_UpdatePassengerDetails 
    @PassengerID = 2005,
    @LastName = 'Santos',
    @MealPreference = 'Non-Vegetarian',
    @EmergencyContact = 'Rafael Santos';




	--QUESTION 5 - View for Employee-Issued E-Boarding Numbers with Revenue Details
	CREATE VIEW vw_EmployeeTicketRevenue AS
SELECT 
    e.EmployeeID,
    e.Name AS EmployeeName,
    e.Role,
    t.EBoardingNumber,
    t.IssueDate,
    t.IssueTime,
    p.PassengerID,
    p.FirstName + ' ' + p.LastName AS PassengerName,
    f.FlightID,
    f.FlightNumber,
    f.DepartureTime,
    f.Origin,
    f.Destination,
    t.Fare AS BaseFare,
    ISNULL(a.ExtraBaggageKG, 0) AS ExtraBaggageKG,
    ISNULL(a.ExtraBaggageKG * 100, 0) AS BaggageFee,
    CASE WHEN a.UpgradedMeal = 1 THEN 20 ELSE 0 END AS MealUpgradeFee,
    CASE WHEN a.PreferredSeat = 1 THEN 30 ELSE 0 END AS PreferredSeatFee,
    ISNULL(a.ServiceFee, 0) AS TotalAdditionalFees,
    t.Fare + ISNULL(a.ServiceFee, 0) AS TotalRevenue,
    t.Class,
    t.SeatNumber
FROM 
    Employee e
JOIN 
    Ticket t ON e.EmployeeID = t.IssuedBy
JOIN 
    Reservation r ON t.PNR = r.PNR
JOIN 
    Passenger p ON r.PassengerID = p.PassengerID
JOIN 
    Flight f ON t.FlightID = f.FlightID
LEFT JOIN 
    AdditionalServices a ON t.TicketID = a.TicketID;

--Usage Examples - View all tickets issued by a specific employee (EmployeeID 1000):
SELECT * FROM vw_EmployeeTicketRevenue
WHERE EmployeeID = 'EM201'
ORDER BY IssueDate DESC, IssueTime DESC;

--Usage Example - Calculate total revenue generated by an employee on a specific flight:
SELECT 
    EmployeeID,
    EmployeeName,
    FlightNumber,
    COUNT(EBoardingNumber) AS TicketsIssued,
    SUM(TotalRevenue) AS TotalRevenueGenerated
FROM 
    vw_EmployeeTicketRevenue
WHERE 
    EmployeeID = 'EM201' 
    AND FlightNumber = 'AW101'
GROUP BY 
    EmployeeID, EmployeeName, FlightNumber;



--QUESTION 6 - TRIGGER FOR AUTO SEAT RESERVATION
--modify our database schema to include a Seat table to track seat availability, then create the trigger
-- Add Seat table to track seat status

CREATE TABLE Seat (
    SeatID INT PRIMARY KEY IDENTITY(1,1), 
    FlightID INT NOT NULL, 
    SeatNumber NVARCHAR(10) NOT NULL,  
    Class NVARCHAR(20) NOT NULL CHECK (Class IN ('Economy', 'Business', 'FirstClass')), 
    Status NVARCHAR(20) NOT NULL CHECK (Status IN ('Available', 'Reserved', 'Occupied')) DEFAULT 'Available',  
    CONSTRAINT UQ_FlightSeat UNIQUE (FlightID, SeatNumber),  
    FOREIGN KEY (FlightID) REFERENCES Flight(FlightID)  
);
GO

-- Create trigger to update seat status when ticket is issued
CREATE TRIGGER tr_ReserveSeatOnTicketIssue
ON Ticket
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Only proceed if SeatNumber is specified in the inserted rows
    IF EXISTS (SELECT 1 FROM inserted WHERE SeatNumber IS NOT NULL)
    BEGIN
        -- Update seat status to 'Reserved' for newly assigned seats in inserted rows
        UPDATE s
        SET s.Status = 'Reserved'
        FROM Seat s
        JOIN inserted i ON s.FlightID = i.FlightID AND s.SeatNumber = i.SeatNumber
        WHERE i.SeatNumber IS NOT NULL;

        -- Handle updates to ticket seat assignments:
        -- Free previously assigned seats if SeatNumber changes
        IF EXISTS (SELECT 1 FROM deleted)
        BEGIN
            UPDATE s
            SET s.Status = 'Available'
            FROM Seat s
            JOIN deleted d ON s.FlightID = d.FlightID AND s.SeatNumber = d.SeatNumber
            LEFT JOIN inserted i ON d.TicketID = i.TicketID
            WHERE d.SeatNumber IS NOT NULL 
              AND (i.SeatNumber IS NULL OR i.SeatNumber <> d.SeatNumber);  -- Check if SeatNumber changed
        END
    END
END;
GO


--enhanced version of the ticket issuance procedure that works with this trigger
CREATE OR ALTER PROCEDURE sp_IssueTicketWithSeat
    @PNR NVARCHAR(10),
    @FlightID INT,
    @Fare DECIMAL(10,2),
    @SeatNumber NVARCHAR(10) = NULL,
    @Class NVARCHAR(20),
    @EmployeeID INT,
    @ExtraBaggageKG DECIMAL(5,2) = 0,
    @UpgradedMeal BIT = 0,
    @PreferredSeat BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Check seat availability if seat is specified
        IF @SeatNumber IS NOT NULL
        BEGIN
            IF NOT EXISTS (
                SELECT 1 FROM Seat 
                WHERE FlightID = @FlightID 
                  AND SeatNumber = @SeatNumber 
                  AND Status = 'Available'
                  AND Class = @Class
            )
            BEGIN
                RAISERROR('The requested seat is not available or does not exist.', 16, 1);
                RETURN;
            END
        END

        -- Generate boarding number
        DECLARE @EBoardingNumber NVARCHAR(20) = 
            (SELECT LEFT(FlightNumber, 2) FROM Flight WHERE FlightID = @FlightID) + 
            RIGHT('000' + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS NVARCHAR(3)), 3) +
            ISNULL(@SeatNumber, 'XX');

        -- Insert ticket
        INSERT INTO Ticket (PNR, FlightID, Fare, SeatNumber, Class, IssuedBy, EBoardingNumber)
        VALUES (@PNR, @FlightID, @Fare, @SeatNumber, @Class, @EmployeeID, @EBoardingNumber);

        DECLARE @TicketID INT = SCOPE_IDENTITY();

        -- Insert additional services (extra baggage, upgraded meal, preferred seat)
        DECLARE @ServiceFee DECIMAL(10,2) = 
            (@ExtraBaggageKG * 100) + 
            (CASE WHEN @UpgradedMeal = 1 THEN 20 ELSE 0 END) + 
            (CASE WHEN @PreferredSeat = 1 THEN 30 ELSE 0 END);

        INSERT INTO AdditionalServices (TicketID, ExtraBaggageKG, UpgradedMeal, PreferredSeat, ServiceFee)
        VALUES (@TicketID, @ExtraBaggageKG, @UpgradedMeal, @PreferredSeat, @ServiceFee);

        -- Insert baggage record
        INSERT INTO Baggage (TicketID, Weight, Status, Fee)
        VALUES (@TicketID, 
                CASE WHEN @ExtraBaggageKG > 0 THEN 20 + @ExtraBaggageKG ELSE 20 END,
                'CheckedIn',
                CASE WHEN @ExtraBaggageKG > 0 THEN @ExtraBaggageKG * 100 ELSE 0 END);

        -- Update reservation status to 'Confirmed'
        UPDATE Reservation 
        SET Status = 'Confirmed' 
        WHERE PNR = @PNR;

        COMMIT TRANSACTION;

        -- Return ticket ID and boarding number
        SELECT @TicketID AS NewTicketID, @EBoardingNumber AS BoardingNumber;
    END TRY
    BEGIN CATCH
        -- Rollback transaction if an error occurs
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

INSERT INTO Seat (FlightID, SeatNumber, Class, Status)
VALUES 
    (3000, '12A', 'Economy', 'Available'),
    (3000, '12B', 'Economy', 'Available'),
    (3000, '1A', 'Business', 'Available'),
    (3001, '3B', 'Business', 'Available');
    GO


-- Update a ticket to change seats
UPDATE Ticket 
SET SeatNumber = 'A47' 
WHERE TicketID = 4090;

SELECT * FROM Ticket

--QUESTION 7 - TOTAL BAGGAGE
--create a table-valued function that returns the total number of checked-in baggage items 
--for a specified flight on a specific date, along with relevant details

CREATE OR ALTER FUNCTION fn_GetCheckedInBaggageCount(
    @FlightNumber NVARCHAR(10),
    @Date DATE
)
RETURNS TABLE
AS
RETURN (
    SELECT 
        f.FlightNumber,
        CAST(f.DepartureTime AS TIME) AS DepartureTime,
        f.Origin,
        f.Destination,
        @Date AS CheckInDate,
        COUNT(b.BaggageID) AS TotalCheckedInBaggage,
        SUM(b.Weight) AS TotalBaggageWeight,
        SUM(b.Fee) AS TotalBaggageFees
    FROM 
        Flight f
    INNER JOIN Ticket t ON f.FlightID = t.FlightID
    INNER JOIN Baggage b ON t.TicketID = b.TicketID
    WHERE 
        f.FlightNumber = @FlightNumber
        AND CAST(t.IssueDate AS DATE) = @Date
        AND b.Status = 'CheckedIn'
    GROUP BY 
        f.FlightNumber,
        f.DepartureTime,
        f.Origin,
        f.Destination
);


--USAGE EXAMPLE - Using the function for a specific flight and date
-- Get checked-in baggage for flight AW101 on 2025-04-25
SELECT * FROM fn_GetCheckedInBaggageCount('AW101', '2025-04-25');

-- Get checked-in baggage for current date
SELECT * FROM fn_GetCheckedInBaggageCount('AW101', CAST(GETDATE() AS DATE));


--REPORT THAT IS more detailed  including passenger information
CREATE OR ALTER FUNCTION fn_GetDetailedCheckedInBaggage(
    @FlightNumber NVARCHAR(10) = NULL,
    @Date DATE = NULL
)
RETURNS TABLE
AS
RETURN (
    SELECT 
        f.FlightNumber,
        CAST(t.IssueDate AS DATE) AS CheckInDate,
        p.PassengerID,
        p.FirstName + ' ' + p.LastName AS PassengerName,
        t.EBoardingNumber,
        b.BaggageID,
        b.Weight AS BaggageWeightKG,
        b.Fee AS BaggageFee,
        b.Status AS BaggageStatus,
        f.DepartureTime,
        f.Origin,
        f.Destination
    FROM 
        Flight f
    INNER JOIN Ticket t ON f.FlightID = t.FlightID
    INNER JOIN Baggage b ON t.TicketID = b.TicketID
    INNER JOIN Reservation r ON t.PNR = r.PNR
    INNER JOIN Passenger p ON r.PassengerID = p.PassengerID
    WHERE 
        b.Status = 'CheckedIn'
        AND (@FlightNumber IS NULL OR f.FlightNumber = @FlightNumber)
        AND (@Date IS NULL OR CAST(t.IssueDate AS DATE) = @Date));


--USAGE EXAMPLE USING MORE DETAILED REPORT
-- Get all checked-in baggage details for flight AW101 on 25/04/2025
SELECT * FROM fn_GetDetailedCheckedInBaggage('AW101', '2025-04-25');

-- Get all checked-in baggage for flight AW101 (all dates)
SELECT * FROM fn_GetDetailedCheckedInBaggage('AW101', NULL);



---8

CREATE INDEX IX_Passenger_Email ON Passenger(Email);
--Improves lookups by email, e.g., for login or duplicate checks

--Flight
CREATE INDEX IX_Flight_Departure ON Flight(DepartureTime);
CREATE INDEX IX_Flight_OriginDestination ON Flight(Origin, Destination);
--Useful for searches by time, origin, and destination

--Reservation
CREATE INDEX IX_Reservation_PassengerID ON Reservation(PassengerID);
CREATE INDEX IX_Reservation_Status ON Reservation(Status);
--Helps when listing or filtering bookings by passenger or status

--Ticket
CREATE INDEX IX_Ticket_PNR ON Ticket(PNR);
CREATE INDEX IX_Ticket_FlightID ON Ticket(FlightID);
CREATE INDEX IX_Ticket_IssuedBy ON Ticket(IssuedBy);
--Speeds up joins with reservations, flights, and employees)

--AdditionalServices
CREATE INDEX IX_AdditionalServices_TicketID ON AdditionalServices(TicketID);
--Speeds up joins between Ticket and AdditionalServices, especially when retrieving services like baggage or upgraded meals for a given ticket.

--Baggage
CREATE INDEX IX_Baggage_PassengerID ON Baggage(PassengerID);
CREATE INDEX IX_Baggage_TicketID ON Baggage(TicketID);
--PassengerID index helps when listing or verifying baggage per passenger (e.g., during check-in).
--TicketID index improves joins with Ticket table or when calculating baggage fees related to a specific ticket.

-- Seat
CREATE INDEX IX_Seat_FlightID ON Seat(FlightID);
CREATE INDEX IX_Seat_Status ON Seat(Status);
--Useful for checking available/reserved seats per flight
