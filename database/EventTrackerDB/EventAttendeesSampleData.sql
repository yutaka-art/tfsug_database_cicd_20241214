-- EventAttendees テーブルにデータを投入するSQLスクリプト
TRUNCATE TABLE EventAttendees
INSERT INTO EventAttendees (EventName, AttendeeName, Email, RegistrationDate)
VALUES
('C# Community Conference 2024', 'John Doe', 'john.doe@example.com', '2024-11-01'),
('C# Community Conference 2024', 'Jane Smith', 'jane.smith@example.com', '2024-11-02'),
('C# Community Conference 2024', 'Michael Brown', 'michael.brown@example.com', '2024-11-01'),
('DevOps Summit 2024', 'Emily Davis', 'emily.davis@example.com', '2024-11-03'),
('DevOps Summit 2024', 'David Wilson', 'david.wilson@example.com', '2024-11-03'),
('Azure Tech Day 2024', 'Sophia Lee', 'sophia.lee@example.com', '2024-11-04'),
('Azure Tech Day 2024', 'James Taylor', 'james.taylor@example.com', '2024-11-04');
