-- Venues Table
create database Event_mng;
use Event_mng;
create table venues(
venue_id int primary key auto_increment,
name varchar (255),
address text,
capacity int
);
-- value Insert
insert into venues(name,address,capacity)values
('Grand Hall','123 Main street,city',500),
('Confrence Park','789 Green Avenue,city',1000);
select * from venues;

--  Second table,  Events Table
create table events(
event_id int  primary key auto_increment,
name varchar (255),
event_date date,
venue_id int,
status varchar(200),
foreign key(venue_id) references venues(venue_id)
);

-- Value Insert
insert into events(name,event_date,venue_id,status)values
('Tech Confrence','2025-05-10',1,'Scheduled'),
('Business Meetup','2025-07-15',2,'Scheduled');
select * from events;

--  Create Third Table Attendence Table
create table Attendence(
attendence_id int primary key auto_increment,
name varchar(255),
email varchar(255),
phone varchar(20)
);

-- Insert values
insert into Attendence(name,email,phone)values
('Preeti Patel','preeti@example.com','8965234178'),
('Lucky Kumari','lucky@example.com','5269315874'),
('Sana Rangrage','sana@example.com','2569315749');
select * from Attendence;

-- Create Fourth Table registration Table
create table Registration(
registration_id int primary key auto_increment,
event_id int,
attendence_id int,
registration_date timestamp ,
status varchar(200),
foreign key (event_id) references events (event_id),
foreign key (attendence_id) references Attendence (attendence_id)
);

-- Insert Values
insert into Registration (event_id,attendence_id,registration_date,status)values
(1,1,Now(),'Confirmed'),
(1,2,Now(),'Confirmed'),
(2,3,Now(),'Confirmed');
select * from Registration;

-- Task 3
DELIMITER //

CREATE PROCEDURE DeleteEvent(IN eventID INT)
BEGIN
    -- Check if there are registrations for this event
    IF (SELECT COUNT(*) FROM Registration WHERE event_id = eventID) > 0 THEN
        -- Throw an error if registrations exist
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Oops! Attendance is registered for this event, so it cannot be deleted';
    ELSE
        -- Delete the event if no registrations exist
        DELETE FROM Events WHERE event_id = eventID;
        SELECT 'Event successfully deleted!' AS message;
    END IF;
END //

DELIMITER //
SELECT * FROM events;
SELECT * FROM Registration;
SELECT event_id, name FROM Events;
SELECT * FROM Events WHERE event_id = 1;

-- Task 4
DELIMITER //
Create procedure SoftDeleteEvent(in eventID int)
BEGIN
DECLARE event_exists int;
-- Check if the event exists and is not
select count(*) into event_exists from events where event_id= eventID and status != 'Cancelled';
if event_exists = 0 then 
select 'Event does not exist or is already cancelled!' as Mesage;
else
update events set status='Cancelled' where event_id = eventID;

Update Registration set status ='Cancelled' where event_id =eventId;

select 'Event and registration have been cancelled successfully!' as Message;
END if;
END  //
DELIMITER ;

select * from events where event_id =1;
select * from Registration where event_id =2;
call SoftDeleteEvent(3);

-- Task 5
 -- create Notification table
 create table Notification (
 notification_id int primary key auto_increment,
 attendence_email varchar (255),
 message text not null,
 sent_at datetime not null
);

DELIMITER //

CREATE PROCEDURE SendEventReminder(IN days_before INT)
BEGIN
    -- Insert Reminders
    INSERT INTO Notification (attendence_email, message, sent_at)
    SELECT a.email,  
           CONCAT('Reminder: Your event "', e.name, '" is on ', e.event_date), 
           NOW()
    FROM Registration r
    JOIN Attendence a ON r.attendence_id = a.attendence_id
    JOIN events e ON r.event_id = e.event_id
    WHERE e.event_date = DATE_ADD(CURDATE(), INTERVAL days_before DAY)
      AND r.status = 'Confirmed' 
      AND e.status != 'Cancelled'  
      AND a.email IS NOT NULL;

    -- Confirmation message
    SELECT IF(ROW_COUNT() > 0, 
              CONCAT(ROW_COUNT(), ' reminders sent successfully!'), 
              'No reminders sent. No upcoming events found.') AS Message;
END //

DELIMITER ;

-- Calling the procedure with the desired number of days
CALL SendEventReminder(5);  -- For example, sending reminders 5 days before the event













