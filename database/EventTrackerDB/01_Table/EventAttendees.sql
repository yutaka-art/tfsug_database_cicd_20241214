CREATE TABLE EventAttendees (
    AttendeeID INT IDENTITY(1,1) PRIMARY KEY, -- 出席者の一意なID
    EventName NVARCHAR(100) NOT NULL,         -- イベント名
    AttendeeName NVARCHAR(100) NOT NULL,      -- 出席者名
    Email NVARCHAR(100) NOT NULL,             -- 出席者のメールアドレス
    RegistrationDate DATETIME NOT NULL DEFAULT GETDATE() -- 登録日時
);
