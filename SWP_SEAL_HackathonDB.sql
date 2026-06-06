-- ============================================================
-- SEAL – Software Engineering Hackathon Management System
-- MS SQL Server Database Script
-- Version: 2.0 UUID Version
-- ============================================================

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'SWP_SEAL_HackathonDB')
BEGIN
    ALTER DATABASE SWP_SEAL_HackathonDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SWP_SEAL_HackathonDB;
END
GO

CREATE DATABASE SWP_SEAL_HackathonDB
    COLLATE Vietnamese_CI_AS;
GO

USE SWP_SEAL_HackathonDB;
GO

-- ============================================================
-- CONSTANT UUID VALUES FOR LOOKUP TABLES
-- ============================================================

-- UserType
DECLARE @UT_FPT_STUDENT       UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000000001';
DECLARE @UT_EXTERNAL_STUDENT  UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000000002';
DECLARE @UT_ORGANIZER         UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000000003';
DECLARE @UT_INTERNAL_JUDGE    UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000000004';
DECLARE @UT_GUEST_JUDGE       UNIQUEIDENTIFIER = '10000000-0000-0000-0000-000000000005';

-- AccountStatus
DECLARE @AS_PENDING_APPROVAL  UNIQUEIDENTIFIER = '20000000-0000-0000-0000-000000000001';
DECLARE @AS_ACTIVE            UNIQUEIDENTIFIER = '20000000-0000-0000-0000-000000000002';
DECLARE @AS_REJECTED          UNIQUEIDENTIFIER = '20000000-0000-0000-0000-000000000003';
DECLARE @AS_SUSPENDED         UNIQUEIDENTIFIER = '20000000-0000-0000-0000-000000000004';
DECLARE @AS_TEMPORARY         UNIQUEIDENTIFIER = '20000000-0000-0000-0000-000000000005';

-- EventStatus
DECLARE @ES_DRAFT             UNIQUEIDENTIFIER = '30000000-0000-0000-0000-000000000001';
DECLARE @ES_REG_OPEN          UNIQUEIDENTIFIER = '30000000-0000-0000-0000-000000000002';
DECLARE @ES_ONGOING           UNIQUEIDENTIFIER = '30000000-0000-0000-0000-000000000003';
DECLARE @ES_COMPLETED         UNIQUEIDENTIFIER = '30000000-0000-0000-0000-000000000004';
DECLARE @ES_CANCELLED         UNIQUEIDENTIFIER = '30000000-0000-0000-0000-000000000005';

-- RoundStatus
DECLARE @RS_UPCOMING          UNIQUEIDENTIFIER = '40000000-0000-0000-0000-000000000001';
DECLARE @RS_SUBMISSION_OPEN   UNIQUEIDENTIFIER = '40000000-0000-0000-0000-000000000002';
DECLARE @RS_JUDGING           UNIQUEIDENTIFIER = '40000000-0000-0000-0000-000000000003';
DECLARE @RS_COMPLETED         UNIQUEIDENTIFIER = '40000000-0000-0000-0000-000000000004';

-- SubmissionStatus
DECLARE @SS_DRAFT             UNIQUEIDENTIFIER = '50000000-0000-0000-0000-000000000001';
DECLARE @SS_SUBMITTED         UNIQUEIDENTIFIER = '50000000-0000-0000-0000-000000000002';
DECLARE @SS_UNDER_REVIEW      UNIQUEIDENTIFIER = '50000000-0000-0000-0000-000000000003';
DECLARE @SS_DISQUALIFIED      UNIQUEIDENTIFIER = '50000000-0000-0000-0000-000000000004';

-- TeamStatus
DECLARE @TS_FORMING           UNIQUEIDENTIFIER = '60000000-0000-0000-0000-000000000001';
DECLARE @TS_ACTIVE            UNIQUEIDENTIFIER = '60000000-0000-0000-0000-000000000002';
DECLARE @TS_DISQUALIFIED      UNIQUEIDENTIFIER = '60000000-0000-0000-0000-000000000003';
DECLARE @TS_WITHDRAWN         UNIQUEIDENTIFIER = '60000000-0000-0000-0000-000000000004';

-- AwardTier
DECLARE @AT_FIRST             UNIQUEIDENTIFIER = '70000000-0000-0000-0000-000000000001';
DECLARE @AT_SECOND            UNIQUEIDENTIFIER = '70000000-0000-0000-0000-000000000002';
DECLARE @AT_THIRD             UNIQUEIDENTIFIER = '70000000-0000-0000-0000-000000000003';
DECLARE @AT_HONORABLE         UNIQUEIDENTIFIER = '70000000-0000-0000-0000-000000000004';
DECLARE @AT_INNOVATION        UNIQUEIDENTIFIER = '70000000-0000-0000-0000-000000000005';
DECLARE @AT_PRESENTATION      UNIQUEIDENTIFIER = '70000000-0000-0000-0000-000000000006';
DECLARE @AT_SPECIAL           UNIQUEIDENTIFIER = '70000000-0000-0000-0000-000000000007';

-- ============================================================
-- SECTION 1: ENUMS / LOOKUP TABLES
-- ============================================================

CREATE TABLE UserType (
    UserTypeID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    TypeName NVARCHAR(50) NOT NULL UNIQUE
);
INSERT INTO UserType (UserTypeID, TypeName) VALUES
    (@UT_FPT_STUDENT, N'FPT Student'),
    (@UT_EXTERNAL_STUDENT, N'External Student'),
    (@UT_ORGANIZER, N'Organizer'),
    (@UT_INTERNAL_JUDGE, N'Internal Judge'),
    (@UT_GUEST_JUDGE, N'Guest Judge');

CREATE TABLE AccountStatus (
    StatusID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    StatusName NVARCHAR(50) NOT NULL UNIQUE
);
INSERT INTO AccountStatus (StatusID, StatusName) VALUES
    (@AS_PENDING_APPROVAL, N'Pending Approval'),
    (@AS_ACTIVE, N'Active'),
    (@AS_REJECTED, N'Rejected'),
    (@AS_SUSPENDED, N'Suspended'),
    (@AS_TEMPORARY, N'Temporary');

CREATE TABLE EventStatus (
    StatusID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    StatusName NVARCHAR(50) NOT NULL UNIQUE
);
INSERT INTO EventStatus (StatusID, StatusName) VALUES
    (@ES_DRAFT, N'Draft'),
    (@ES_REG_OPEN, N'Registration Open'),
    (@ES_ONGOING, N'Ongoing'),
    (@ES_COMPLETED, N'Completed'),
    (@ES_CANCELLED, N'Cancelled');

CREATE TABLE RoundStatus (
    StatusID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    StatusName NVARCHAR(50) NOT NULL UNIQUE
);
INSERT INTO RoundStatus (StatusID, StatusName) VALUES
    (@RS_UPCOMING, N'Upcoming'),
    (@RS_SUBMISSION_OPEN, N'Submission Open'),
    (@RS_JUDGING, N'Judging'),
    (@RS_COMPLETED, N'Completed');

CREATE TABLE SubmissionStatus (
    StatusID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    StatusName NVARCHAR(50) NOT NULL UNIQUE
);
INSERT INTO SubmissionStatus (StatusID, StatusName) VALUES
    (@SS_DRAFT, N'Draft'),
    (@SS_SUBMITTED, N'Submitted'),
    (@SS_UNDER_REVIEW, N'Under Review'),
    (@SS_DISQUALIFIED, N'Disqualified');

CREATE TABLE TeamStatus (
    StatusID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    StatusName NVARCHAR(50) NOT NULL UNIQUE
);
INSERT INTO TeamStatus (StatusID, StatusName) VALUES
    (@TS_FORMING, N'Forming'),
    (@TS_ACTIVE, N'Active'),
    (@TS_DISQUALIFIED, N'Disqualified'),
    (@TS_WITHDRAWN, N'Withdrawn');

CREATE TABLE AwardTier (
    TierID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    TierName NVARCHAR(50) NOT NULL UNIQUE
);
INSERT INTO AwardTier (TierID, TierName) VALUES
    (@AT_FIRST, N'First Place'),
    (@AT_SECOND, N'Second Place'),
    (@AT_THIRD, N'Third Place'),
    (@AT_HONORABLE, N'Honorable Mention'),
    (@AT_INNOVATION, N'Best Innovation'),
    (@AT_PRESENTATION, N'Best Presentation'),
    (@AT_SPECIAL, N'Special Award');
GO

-- ============================================================
-- SECTION 2: USERS & AUTHENTICATION
-- ============================================================

CREATE TABLE Users (
    UserID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(512) NOT NULL,
    FullName NVARCHAR(200) NOT NULL,
    Phone NVARCHAR(20) NULL,
    UserTypeID UNIQUEIDENTIFIER NOT NULL REFERENCES UserType(UserTypeID),
    AccountStatusID UNIQUEIDENTIFIER NOT NULL DEFAULT '20000000-0000-0000-0000-000000000001' REFERENCES AccountStatus(StatusID),
    FPTStudentCode NVARCHAR(20) NULL,
    ExternalStudentCode NVARCHAR(50) NULL,
    UniversityName NVARCHAR(200) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ApprovedAt DATETIME2 NULL,
    ApprovedByUserID UNIQUEIDENTIFIER NULL,
    AccountExpiresAt DATETIME2 NULL,
    IsDeleted BIT NOT NULL DEFAULT 0,
    CONSTRAINT CK_Users_FPTCode CHECK (
        UserTypeID != '10000000-0000-0000-0000-000000000001' OR FPTStudentCode IS NOT NULL
    ),
    CONSTRAINT CK_Users_ExternalCode CHECK (
        UserTypeID != '10000000-0000-0000-0000-000000000002' OR (ExternalStudentCode IS NOT NULL AND UniversityName IS NOT NULL)
    )
);

CREATE NONCLUSTERED INDEX IX_Users_Email ON Users(Email) WHERE IsDeleted = 0;
CREATE NONCLUSTERED INDEX IX_Users_UserType ON Users(UserTypeID);

ALTER TABLE Users
    ADD CONSTRAINT FK_Users_ApprovedBy FOREIGN KEY (ApprovedByUserID)
        REFERENCES Users(UserID);
GO

CREATE TABLE RefreshTokens (
    TokenID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    UserID UNIQUEIDENTIFIER NOT NULL REFERENCES Users(UserID),
    TokenHash NVARCHAR(512) NOT NULL UNIQUE,
    IssuedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ExpiresAt DATETIME2 NOT NULL,
    RevokedAt DATETIME2 NULL,
    DeviceInfo NVARCHAR(500) NULL
);
GO

-- ============================================================
-- SECTION 3: SCORING CRITERIA TEMPLATES
-- ============================================================

CREATE TABLE CriterionTemplate (
    TemplateID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    CriterionName NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    DefaultWeight DECIMAL(5,2) NOT NULL DEFAULT 1.00,
    MaxScore DECIMAL(6,2) NOT NULL DEFAULT 10.00,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedByID UNIQUEIDENTIFIER NOT NULL REFERENCES Users(UserID),
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);
GO

-- ============================================================
-- SECTION 4: EVENTS
-- ============================================================

CREATE TABLE Events (
    EventID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    EventName NVARCHAR(300) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    Location NVARCHAR(200) NOT NULL,
    BannerImageURL NVARCHAR(500) NULL,
    EventStatusID UNIQUEIDENTIFIER NOT NULL DEFAULT '30000000-0000-0000-0000-000000000001' REFERENCES EventStatus(StatusID),
    RegistrationStart DATETIME2 NULL,
    RegistrationEnd DATETIME2 NULL,
    EventStartDate DATE NULL,
    EventEndDate DATE NULL,
    MaxTeamSize TINYINT NOT NULL DEFAULT 5,
    MinTeamSize TINYINT NOT NULL DEFAULT 3,
    CreatedByID UNIQUEIDENTIFIER NOT NULL REFERENCES Users(UserID),
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    IsDeleted BIT NOT NULL DEFAULT 0
);
GO

CREATE TABLE EventCriteria (
    EventCriterionID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    EventID UNIQUEIDENTIFIER NOT NULL REFERENCES Events(EventID),
    TemplateID UNIQUEIDENTIFIER NULL REFERENCES CriterionTemplate(TemplateID),
    CriterionName NVARCHAR(200) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    Weight DECIMAL(5,2) NOT NULL DEFAULT 1.00,
    MaxScore DECIMAL(6,2) NOT NULL DEFAULT 10.00,
    SortOrder TINYINT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1,
    CONSTRAINT UQ_EventCriteria_Event_Name UNIQUE (EventID, CriterionName)
);
GO

-- ============================================================
-- SECTION 5: CATEGORIES
-- ============================================================

CREATE TABLE Categories (
    CategoryID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    EventID UNIQUEIDENTIFIER NOT NULL REFERENCES Events(EventID),
    CategoryName NVARCHAR(300) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    MentorUserID UNIQUEIDENTIFIER NULL REFERENCES Users(UserID),
    SortOrder TINYINT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1,
    CONSTRAINT UQ_Categories_Event_Name UNIQUE (EventID, CategoryName)
);
GO

-- ============================================================
-- SECTION 6: ROUNDS
-- ============================================================

CREATE TABLE Rounds (
    RoundID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    EventID UNIQUEIDENTIFIER NOT NULL REFERENCES Events(EventID),
    RoundName NVARCHAR(200) NOT NULL,
    RoundOrder TINYINT NOT NULL,
    RoundStatusID UNIQUEIDENTIFIER NOT NULL DEFAULT '40000000-0000-0000-0000-000000000001' REFERENCES RoundStatus(StatusID),
    SubmissionDeadline DATETIME2 NULL,
    JudgingDeadline DATETIME2 NULL,
    StartDate DATETIME2 NULL,
    EndDate DATETIME2 NULL,
    AdvancementTopN INT NULL,
    IsCalibrationRound BIT NOT NULL DEFAULT 0,
    Description NVARCHAR(MAX) NULL,
    CONSTRAINT UQ_Rounds_Event_Order UNIQUE (EventID, RoundOrder)
);
GO

CREATE TABLE RoundJudges (
    RoundJudgeID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    RoundID UNIQUEIDENTIFIER NOT NULL REFERENCES Rounds(RoundID),
    UserID UNIQUEIDENTIFIER NOT NULL REFERENCES Users(UserID),
    AssignedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    AssignedByID UNIQUEIDENTIFIER NOT NULL REFERENCES Users(UserID),
    CONSTRAINT UQ_RoundJudges UNIQUE (RoundID, UserID)
);
GO

CREATE TABLE RoundCriteria (
    RoundCriterionID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    RoundID UNIQUEIDENTIFIER NOT NULL REFERENCES Rounds(RoundID),
    EventCriterionID UNIQUEIDENTIFIER NOT NULL REFERENCES EventCriteria(EventCriterionID),
    Weight DECIMAL(5,2) NULL,
    CONSTRAINT UQ_RoundCriteria UNIQUE (RoundID, EventCriterionID)
);
GO

-- ============================================================
-- SECTION 7: TEAMS
-- ============================================================

CREATE TABLE Teams (
    TeamID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    EventID UNIQUEIDENTIFIER NOT NULL REFERENCES Events(EventID),
    CategoryID UNIQUEIDENTIFIER NOT NULL REFERENCES Categories(CategoryID),
    TeamName NVARCHAR(300) NOT NULL,
    TeamStatusID UNIQUEIDENTIFIER NOT NULL DEFAULT '60000000-0000-0000-0000-000000000001' REFERENCES TeamStatus(StatusID),
    LeaderUserID UNIQUEIDENTIFIER NOT NULL REFERENCES Users(UserID),
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT UQ_Teams_Event_Name UNIQUE (EventID, TeamName)
);

CREATE TABLE TeamMembers (
    TeamMemberID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    TeamID UNIQUEIDENTIFIER NOT NULL REFERENCES Teams(TeamID),
    UserID UNIQUEIDENTIFIER NOT NULL REFERENCES Users(UserID),
    JoinedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    LeftAt DATETIME2 NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CONSTRAINT UQ_TeamMembers UNIQUE (TeamID, UserID)
);
GO

CREATE TABLE TeamJoinRequests (
    RequestID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    TeamID UNIQUEIDENTIFIER NOT NULL REFERENCES Teams(TeamID),
    UserID UNIQUEIDENTIFIER NOT NULL REFERENCES Users(UserID),
    RequestStatus NVARCHAR(20) NOT NULL DEFAULT N'PENDING',
    RequestedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    RespondedAt DATETIME2 NULL,
    RespondedByID UNIQUEIDENTIFIER NULL REFERENCES Users(UserID),
    ResponseNote NVARCHAR(500) NULL,
    CONSTRAINT UQ_TeamJoinRequests_Pending UNIQUE (TeamID, UserID, RequestStatus),
    CONSTRAINT CK_TeamJoinRequests_Status CHECK (
        RequestStatus IN (N'PENDING', N'APPROVED', N'REJECTED', N'CANCELLED')
    )
);
GO

-- ============================================================
-- SECTION 8: SUBMISSIONS
-- ============================================================

CREATE TABLE Submissions (
    SubmissionID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    TeamID UNIQUEIDENTIFIER NOT NULL REFERENCES Teams(TeamID),
    RoundID UNIQUEIDENTIFIER NOT NULL REFERENCES Rounds(RoundID),
    SubmissionStatusID UNIQUEIDENTIFIER NOT NULL DEFAULT '50000000-0000-0000-0000-000000000001' REFERENCES SubmissionStatus(StatusID),
    RepositoryURL NVARCHAR(500) NULL,
    DemoURL NVARCHAR(500) NULL,
    ReportURL NVARCHAR(500) NULL,
    SlideURL NVARCHAR(500) NULL,
    RepoMetadataJSON NVARCHAR(MAX) NULL,
    RepoLastCommitAt DATETIME2 NULL,
    RepoStarCount INT NULL,
    RepoForkCount INT NULL,
    SubmittedAt DATETIME2 NULL,
    LastUpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    SubmittedByUserID UNIQUEIDENTIFIER NOT NULL REFERENCES Users(UserID),
    Notes NVARCHAR(MAX) NULL,
    CONSTRAINT UQ_Submissions_Team_Round UNIQUE (TeamID, RoundID)
);
GO

-- ============================================================
-- SECTION 9: SCORING & EVALUATION
-- ============================================================

CREATE TABLE Judging (
    JudgingID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    SubmissionID UNIQUEIDENTIFIER NOT NULL REFERENCES Submissions(SubmissionID),
    JudgeUserID UNIQUEIDENTIFIER NOT NULL REFERENCES Users(UserID),
    EventCriterionID UNIQUEIDENTIFIER NOT NULL REFERENCES EventCriteria(EventCriterionID),
    ScoreValue DECIMAL(6,2) NOT NULL,
    Comment NVARCHAR(MAX) NULL,
    JudgedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    IsCalibration BIT NOT NULL DEFAULT 0,
    CONSTRAINT UQ_Judging_Sub_Judge_Criterion UNIQUE (SubmissionID, JudgeUserID, EventCriterionID),
    CONSTRAINT CK_Judging_Value CHECK (ScoreValue >= 0)
);

CREATE NONCLUSTERED INDEX IX_Judging_Submission ON Judging(SubmissionID);
CREATE NONCLUSTERED INDEX IX_Judging_Judge ON Judging(JudgeUserID);
GO

CREATE TABLE EvaluationAuditLogs (
    EvaluationAuditLogID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    EventID UNIQUEIDENTIFIER NOT NULL REFERENCES Events(EventID),
    ActionType NVARCHAR(50) NOT NULL,
    ActorUserID UNIQUEIDENTIFIER NOT NULL REFERENCES Users(UserID),
    JudgingID UNIQUEIDENTIFIER NULL REFERENCES Judging(JudgingID),
    TeamID UNIQUEIDENTIFIER NULL REFERENCES Teams(TeamID),
    SubmissionID UNIQUEIDENTIFIER NULL REFERENCES Submissions(SubmissionID),
    OldValue NVARCHAR(MAX) NULL,
    NewValue NVARCHAR(MAX) NULL,
    Reason NVARCHAR(MAX) NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT CK_EvaluationAuditLogs_ActionType CHECK (
        ActionType IN (
            N'SCORE_CREATED',
            N'SCORE_UPDATED',
            N'SCORE_DELETED',
            N'TEAM_DISQUALIFIED',
            N'TEAM_DISQUALIFICATION_REVERSED',
            N'SUBMISSION_DISQUALIFIED',
            N'SUBMISSION_DISQUALIFICATION_REVERSED'
        )
    ),
    CONSTRAINT CK_EvaluationAuditLogs_Target CHECK (
        JudgingID IS NOT NULL OR TeamID IS NOT NULL OR SubmissionID IS NOT NULL
    )
);
GO

CREATE NONCLUSTERED INDEX IX_EvaluationAuditLogs_Event ON EvaluationAuditLogs(EventID);
CREATE NONCLUSTERED INDEX IX_EvaluationAuditLogs_Actor ON EvaluationAuditLogs(ActorUserID);
CREATE NONCLUSTERED INDEX IX_EvaluationAuditLogs_Score ON EvaluationAuditLogs(JudgingID) WHERE JudgingID IS NOT NULL;
CREATE NONCLUSTERED INDEX IX_EvaluationAuditLogs_Team ON EvaluationAuditLogs(TeamID) WHERE TeamID IS NOT NULL;
CREATE NONCLUSTERED INDEX IX_EvaluationAuditLogs_Submission ON EvaluationAuditLogs(SubmissionID) WHERE SubmissionID IS NOT NULL;
CREATE NONCLUSTERED INDEX IX_EvaluationAuditLogs_CreatedAt ON EvaluationAuditLogs(CreatedAt DESC);
GO

-- ============================================================
-- SECTION 10: RANKINGS & ADVANCEMENT
-- ============================================================

CREATE TABLE RoundRankings (
    RankingID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    RoundID UNIQUEIDENTIFIER NOT NULL REFERENCES Rounds(RoundID),
    CategoryID UNIQUEIDENTIFIER NOT NULL REFERENCES Categories(CategoryID),
    TeamID UNIQUEIDENTIFIER NOT NULL REFERENCES Teams(TeamID),
    SubmissionID UNIQUEIDENTIFIER NOT NULL REFERENCES Submissions(SubmissionID),
    TotalScore DECIMAL(10,4) NOT NULL,
    AverageScore DECIMAL(10,4) NOT NULL,
    RankPosition INT NOT NULL,
    IsAdvanced BIT NOT NULL DEFAULT 0,
    ComputedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT UQ_RoundRankings UNIQUE (RoundID, CategoryID, TeamID)
);
GO

CREATE TABLE EventRankings (
    EventRankingID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    EventID UNIQUEIDENTIFIER NOT NULL REFERENCES Events(EventID),
    CategoryID UNIQUEIDENTIFIER NOT NULL REFERENCES Categories(CategoryID),
    TeamID UNIQUEIDENTIFIER NOT NULL REFERENCES Teams(TeamID),
    FinalScore DECIMAL(10,4) NOT NULL,
    RankPosition INT NOT NULL,
    ComputedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT UQ_EventRankings UNIQUE (EventID, CategoryID, TeamID)
);
GO

-- ============================================================
-- SECTION 11: DISQUALIFICATIONS
-- ============================================================

CREATE TABLE Disqualifications (
    DisqualificationID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    TeamID UNIQUEIDENTIFIER NULL REFERENCES Teams(TeamID),
    SubmissionID UNIQUEIDENTIFIER NULL REFERENCES Submissions(SubmissionID),
    Reason NVARCHAR(MAX) NOT NULL,
    DisqualifiedByID UNIQUEIDENTIFIER NOT NULL REFERENCES Users(UserID),
    DisqualifiedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    IsReversed BIT NOT NULL DEFAULT 0,
    ReversedAt DATETIME2 NULL,
    ReversedByID UNIQUEIDENTIFIER NULL REFERENCES Users(UserID),
    ReversalReason NVARCHAR(MAX) NULL,
    CONSTRAINT CK_Disq_Target CHECK (
        (TeamID IS NOT NULL AND SubmissionID IS NULL)
        OR (TeamID IS NULL AND SubmissionID IS NOT NULL)
    )
);
GO

-- ============================================================
-- SECTION 12: AWARDS & NOTIFICATIONS
-- ============================================================

CREATE TABLE Awards (
    AwardID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    EventID UNIQUEIDENTIFIER NOT NULL REFERENCES Events(EventID),
    CategoryID UNIQUEIDENTIFIER NULL REFERENCES Categories(CategoryID),
    TeamID UNIQUEIDENTIFIER NOT NULL REFERENCES Teams(TeamID),
    AwardTierID UNIQUEIDENTIFIER NOT NULL REFERENCES AwardTier(TierID),
    AwardTitle NVARCHAR(300) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    PrizeValue DECIMAL(12,2) NULL,
    PrizeCurrency NCHAR(3) NULL DEFAULT 'VND',
    AwardedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    AwardedByID UNIQUEIDENTIFIER NOT NULL REFERENCES Users(UserID),
    IsPublished BIT NOT NULL DEFAULT 0,
    PublishedAt DATETIME2 NULL
);
GO

CREATE TABLE Notifications (
    NotificationID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    EventID UNIQUEIDENTIFIER NULL REFERENCES Events(EventID),
    RecipientUserID UNIQUEIDENTIFIER NULL REFERENCES Users(UserID),
    Title NVARCHAR(300) NOT NULL,
    Body NVARCHAR(MAX) NOT NULL,
    SentAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    SentByUserID UNIQUEIDENTIFIER NOT NULL REFERENCES Users(UserID),
    IsRead BIT NOT NULL DEFAULT 0
);
GO

-- ============================================================
-- SECTION 13: AUDIT LOG
-- ============================================================

CREATE TABLE AuditLog (
    LogID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    ActionType NVARCHAR(100) NOT NULL,
    EntityType NVARCHAR(100) NOT NULL,
    EntityID UNIQUEIDENTIFIER NULL,
    EntityKey NVARCHAR(200) NULL,
    ActorUserID UNIQUEIDENTIFIER NULL REFERENCES Users(UserID),
    OldValueJSON NVARCHAR(MAX) NULL,
    NewValueJSON NVARCHAR(MAX) NULL,
    IPAddress NVARCHAR(50) NULL,
    OccurredAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    Notes NVARCHAR(MAX) NULL,
    CONSTRAINT CK_AuditLog_Entity CHECK (EntityID IS NOT NULL OR EntityKey IS NOT NULL)
);

CREATE NONCLUSTERED INDEX IX_AuditLog_Entity ON AuditLog(EntityType, EntityID);
CREATE NONCLUSTERED INDEX IX_AuditLog_Actor ON AuditLog(ActorUserID);
CREATE NONCLUSTERED INDEX IX_AuditLog_Time ON AuditLog(OccurredAt DESC);
GO

-- ============================================================
-- SECTION 14: RBL FEATURES
-- ============================================================

CREATE TABLE CalibrationSamples (
    SampleID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    RoundID UNIQUEIDENTIFIER NOT NULL REFERENCES Rounds(RoundID),
    SubmissionID UNIQUEIDENTIFIER NOT NULL REFERENCES Submissions(SubmissionID),
    ReferenceScoreJSON NVARCHAR(MAX) NULL,
    AddedByID UNIQUEIDENTIFIER NOT NULL REFERENCES Users(UserID),
    AddedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);
GO

CREATE TABLE DataExportLog (
    ExportID UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    EventID UNIQUEIDENTIFIER NOT NULL REFERENCES Events(EventID),
    ExportedByID UNIQUEIDENTIFIER NOT NULL REFERENCES Users(UserID),
    ExportedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FileFormat NVARCHAR(10) NOT NULL DEFAULT 'CSV',
    [RowCount] INT NULL,
    Notes NVARCHAR(500) NULL
);
GO

-- ============================================================
-- SECTION 15: STORED PROCEDURES
-- ============================================================

IF OBJECT_ID('sp_ApproveUser', 'P') IS NOT NULL
    DROP PROCEDURE sp_ApproveUser;
GO

CREATE PROCEDURE sp_ApproveUser
    @UserID UNIQUEIDENTIFIER,
    @ApproverID UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Users
    SET AccountStatusID = '20000000-0000-0000-0000-000000000002',
        ApprovedAt = GETUTCDATE(),
        ApprovedByUserID = @ApproverID,
        UpdatedAt = GETUTCDATE()
    WHERE UserID = @UserID
      AND AccountStatusID = '20000000-0000-0000-0000-000000000001'
      AND IsDeleted = 0;

    INSERT INTO AuditLog (ActionType, EntityType, EntityID, ActorUserID, NewValueJSON)
    VALUES (N'ACCOUNT_APPROVED', N'Users', @UserID, @ApproverID, N'{"status":"Active"}');
END;
GO

CREATE OR ALTER PROCEDURE sp_CreateGuestJudge
    @Email NVARCHAR(255),
    @FullName NVARCHAR(200),
    @PasswordHash NVARCHAR(512),
    @ExpiresAt DATETIME2,
    @CreatedByID UNIQUEIDENTIFIER,
    @NewUserID UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @NewUserID = NEWID();

    INSERT INTO Users (UserID, Email, PasswordHash, FullName, UserTypeID, AccountStatusID, AccountExpiresAt)
    VALUES (@NewUserID, @Email, @PasswordHash, @FullName,
            '10000000-0000-0000-0000-000000000005',
            '20000000-0000-0000-0000-000000000005',
            @ExpiresAt);

    INSERT INTO AuditLog (ActionType, EntityType, EntityID, ActorUserID, NewValueJSON)
    VALUES (N'GUEST_JUDGE_CREATED', N'Users', @NewUserID, @CreatedByID, N'{"type":"GuestJudge"}');
END;
GO

CREATE OR ALTER PROCEDURE sp_UpsertSubmission
    @TeamID UNIQUEIDENTIFIER,
    @RoundID UNIQUEIDENTIFIER,
    @RepositoryURL NVARCHAR(500),
    @DemoURL NVARCHAR(500),
    @ReportURL NVARCHAR(500),
    @SlideURL NVARCHAR(500),
    @Notes NVARCHAR(MAX),
    @RepoMetadataJSON NVARCHAR(MAX) = NULL,
    @RepoLastCommitAt DATETIME2 = NULL,
    @RepoStarCount INT = NULL,
    @RepoForkCount INT = NULL,
    @SubmittedByUserID UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SubID UNIQUEIDENTIFIER;
    DECLARE @TeamStatus UNIQUEIDENTIFIER;
    DECLARE @Deadline DATETIME2;

    SELECT @TeamStatus = TeamStatusID FROM Teams WHERE TeamID = @TeamID;

    IF @TeamStatus IN (
        '60000000-0000-0000-0000-000000000003',
        '60000000-0000-0000-0000-000000000004'
    )
        THROW 51001, N'This team is disqualified or withdrawn and cannot submit.', 1;

    SELECT @Deadline = SubmissionDeadline FROM Rounds WHERE RoundID = @RoundID;

    IF @Deadline IS NOT NULL AND GETUTCDATE() > @Deadline
        THROW 51000, N'Submission deadline has passed.', 1;

    IF EXISTS (SELECT 1 FROM Submissions WHERE TeamID = @TeamID AND RoundID = @RoundID)
    BEGIN
        UPDATE Submissions
        SET RepositoryURL = @RepositoryURL,
            DemoURL = @DemoURL,
            ReportURL = @ReportURL,
            SlideURL = @SlideURL,
            Notes = @Notes,
            RepoMetadataJSON = @RepoMetadataJSON,
            RepoLastCommitAt = @RepoLastCommitAt,
            RepoStarCount = @RepoStarCount,
            RepoForkCount = @RepoForkCount,
            SubmissionStatusID = '50000000-0000-0000-0000-000000000002',
            SubmittedAt = GETUTCDATE(),
            LastUpdatedAt = GETUTCDATE(),
            SubmittedByUserID = @SubmittedByUserID
        WHERE TeamID = @TeamID AND RoundID = @RoundID;

        SELECT @SubID = SubmissionID FROM Submissions WHERE TeamID = @TeamID AND RoundID = @RoundID;

        INSERT INTO AuditLog (ActionType, EntityType, EntityID, ActorUserID)
        VALUES (N'SUBMISSION_UPDATED', N'Submissions', @SubID, @SubmittedByUserID);
    END
    ELSE
    BEGIN
        SET @SubID = NEWID();

        INSERT INTO Submissions (
            SubmissionID, TeamID, RoundID, RepositoryURL, DemoURL, ReportURL, SlideURL,
            Notes, RepoMetadataJSON, RepoLastCommitAt, RepoStarCount, RepoForkCount,
            SubmissionStatusID, SubmittedAt, SubmittedByUserID
        )
        VALUES (
            @SubID, @TeamID, @RoundID, @RepositoryURL, @DemoURL, @ReportURL, @SlideURL,
            @Notes, @RepoMetadataJSON, @RepoLastCommitAt, @RepoStarCount, @RepoForkCount,
            '50000000-0000-0000-0000-000000000002', GETUTCDATE(), @SubmittedByUserID
        );

        INSERT INTO AuditLog (ActionType, EntityType, EntityID, ActorUserID)
        VALUES (N'SUBMISSION_CREATED', N'Submissions', @SubID, @SubmittedByUserID);
    END;
END;
GO

CREATE OR ALTER PROCEDURE sp_RecordScore
    @SubmissionID UNIQUEIDENTIFIER,
    @JudgeUserID UNIQUEIDENTIFIER,
    @EventCriterionID UNIQUEIDENTIFIER,
    @ScoreValue DECIMAL(6,2),
    @Comment NVARCHAR(MAX) = NULL,
    @IsCalibration BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RoundID UNIQUEIDENTIFIER;
    DECLARE @MaxScore DECIMAL(6,2);
    DECLARE @JudgingID UNIQUEIDENTIFIER;
    DECLARE @EventID UNIQUEIDENTIFIER;
    DECLARE @OldValue NVARCHAR(MAX);
    DECLARE @ActionType NVARCHAR(50);

    SELECT @RoundID = RoundID FROM Submissions WHERE SubmissionID = @SubmissionID;

    IF NOT EXISTS (SELECT 1 FROM RoundJudges WHERE RoundID = @RoundID AND UserID = @JudgeUserID)
        THROW 52000, N'Judge is not assigned to this round.', 1;

    SELECT @MaxScore = MaxScore FROM EventCriteria WHERE EventCriterionID = @EventCriterionID;

    IF @ScoreValue > @MaxScore
        THROW 52001, N'Score exceeds the maximum allowed value.', 1;

    SELECT @EventID = e.EventID
    FROM Submissions s
    JOIN Teams t ON t.TeamID = s.TeamID
    JOIN Events e ON e.EventID = t.EventID
    WHERE s.SubmissionID = @SubmissionID;

    SELECT @JudgingID = JudgingID,
           @OldValue = N'{"score":' + CAST(ScoreValue AS NVARCHAR(30)) + N'}'
    FROM Judging
    WHERE SubmissionID = @SubmissionID
      AND JudgeUserID = @JudgeUserID
      AND EventCriterionID = @EventCriterionID;

    IF @JudgingID IS NULL
    BEGIN
        SET @JudgingID = NEWID();
        SET @ActionType = N'SCORE_CREATED';

        INSERT INTO Judging (JudgingID, SubmissionID, JudgeUserID, EventCriterionID, ScoreValue, Comment, IsCalibration)
        VALUES (@JudgingID, @SubmissionID, @JudgeUserID, @EventCriterionID, @ScoreValue, @Comment, @IsCalibration);
    END
    ELSE
    BEGIN
        SET @ActionType = N'SCORE_UPDATED';

        UPDATE Judging
        SET ScoreValue = @ScoreValue,
            Comment = @Comment,
            UpdatedAt = GETUTCDATE()
        WHERE JudgingID = @JudgingID;
    END

    INSERT INTO AuditLog (ActionType, EntityType, EntityID, ActorUserID, NewValueJSON)
    VALUES (N'SCORE_RECORDED', N'Judging', @JudgingID, @JudgeUserID,
            N'{"criterion":"' + CAST(@EventCriterionID AS NVARCHAR(36)) +
            N'","score":' + CAST(@ScoreValue AS NVARCHAR(30)) + N'}');

    INSERT INTO EvaluationAuditLogs (EventID, ActionType, ActorUserID, JudgingID, SubmissionID, OldValue, NewValue, Reason)
    VALUES (@EventID, @ActionType, @JudgeUserID, @JudgingID, @SubmissionID, @OldValue,
            N'{"score":' + CAST(@ScoreValue AS NVARCHAR(30)) + N'}',
            N'Score recorded by judge');
END;
GO

CREATE OR ALTER PROCEDURE sp_DisqualifyTeam
    @TeamID UNIQUEIDENTIFIER,
    @Reason NVARCHAR(MAX),
    @DisqualifiedByID UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EventID UNIQUEIDENTIFIER;
    SELECT @EventID = EventID FROM Teams WHERE TeamID = @TeamID;

    UPDATE Teams
    SET TeamStatusID = '60000000-0000-0000-0000-000000000003',
        UpdatedAt = GETUTCDATE()
    WHERE TeamID = @TeamID;

    INSERT INTO Disqualifications (TeamID, Reason, DisqualifiedByID)
    VALUES (@TeamID, @Reason, @DisqualifiedByID);

    INSERT INTO AuditLog (ActionType, EntityType, EntityID, ActorUserID, NewValueJSON)
    VALUES (N'TEAM_DISQUALIFIED', N'Teams', @TeamID, @DisqualifiedByID,
            N'{"reason":"' + REPLACE(@Reason, '"', '\"') + N'"}');

    INSERT INTO EvaluationAuditLogs (EventID, ActionType, ActorUserID, TeamID, NewValue, Reason)
    VALUES (@EventID, N'TEAM_DISQUALIFIED', @DisqualifiedByID, @TeamID,
            N'{"status":"Disqualified"}', @Reason);
END;
GO

CREATE OR ALTER PROCEDURE sp_DisqualifySubmission
    @SubmissionID UNIQUEIDENTIFIER,
    @Reason NVARCHAR(MAX),
    @DisqualifiedByID UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EventID UNIQUEIDENTIFIER;

    SELECT @EventID = t.EventID
    FROM Submissions s
    JOIN Teams t ON t.TeamID = s.TeamID
    WHERE s.SubmissionID = @SubmissionID;

    UPDATE Submissions
    SET SubmissionStatusID = '50000000-0000-0000-0000-000000000004',
        LastUpdatedAt = GETUTCDATE()
    WHERE SubmissionID = @SubmissionID;

    INSERT INTO Disqualifications (SubmissionID, Reason, DisqualifiedByID)
    VALUES (@SubmissionID, @Reason, @DisqualifiedByID);

    INSERT INTO AuditLog (ActionType, EntityType, EntityID, ActorUserID, NewValueJSON)
    VALUES (N'SUBMISSION_DISQUALIFIED', N'Submissions', @SubmissionID, @DisqualifiedByID,
            N'{"reason":"' + REPLACE(@Reason, '"', '\"') + N'"}');

    INSERT INTO EvaluationAuditLogs (EventID, ActionType, ActorUserID, SubmissionID, NewValue, Reason)
    VALUES (@EventID, N'SUBMISSION_DISQUALIFIED', @DisqualifiedByID, @SubmissionID,
            N'{"status":"Disqualified"}', @Reason);
END;
GO

CREATE OR ALTER PROCEDURE sp_ComputeRoundRankings
    @RoundID UNIQUEIDENTIFIER,
    @CategoryID UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM RoundRankings WHERE RoundID = @RoundID AND CategoryID = @CategoryID;

    ;WITH ScoreSummary AS (
        SELECT
            s.SubmissionID,
            s.TeamID,
            SUM(sc.ScoreValue * COALESCE(rc.Weight, ec.Weight)) AS WeightedTotal,
            AVG(sc.ScoreValue) AS AverageScore
        FROM Submissions s
        JOIN Teams t ON t.TeamID = s.TeamID
        JOIN Judging sc ON sc.SubmissionID = s.SubmissionID
        JOIN EventCriteria ec ON ec.EventCriterionID = sc.EventCriterionID
        LEFT JOIN RoundCriteria rc ON rc.EventCriterionID = ec.EventCriterionID
                                  AND rc.RoundID = s.RoundID
        WHERE s.RoundID = @RoundID
          AND t.CategoryID = @CategoryID
          AND s.SubmissionStatusID != '50000000-0000-0000-0000-000000000004'
          AND t.TeamStatusID != '60000000-0000-0000-0000-000000000003'
          AND sc.IsCalibration = 0
        GROUP BY s.SubmissionID, s.TeamID
    ),
    Ranked AS (
        SELECT *, RANK() OVER (ORDER BY WeightedTotal DESC) AS RankPosition
        FROM ScoreSummary
    )
    INSERT INTO RoundRankings (RoundID, CategoryID, TeamID, SubmissionID, TotalScore, AverageScore, RankPosition, IsAdvanced)
    SELECT
        @RoundID,
        @CategoryID,
        r.TeamID,
        r.SubmissionID,
        r.WeightedTotal,
        r.AverageScore,
        r.RankPosition,
        CASE WHEN rnd.AdvancementTopN IS NOT NULL AND r.RankPosition <= rnd.AdvancementTopN THEN 1 ELSE 0 END
    FROM Ranked r
    CROSS JOIN Rounds rnd
    WHERE rnd.RoundID = @RoundID;
END;
GO

CREATE OR ALTER PROCEDURE sp_ComputeEventRankings
    @EventID UNIQUEIDENTIFIER,
    @CategoryID UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM EventRankings WHERE EventID = @EventID AND CategoryID = @CategoryID;

    ;WITH FinalScores AS (
        SELECT rr.TeamID, AVG(rr.TotalScore) AS FinalScore
        FROM RoundRankings rr
        JOIN Rounds r ON r.RoundID = rr.RoundID
        WHERE r.EventID = @EventID
          AND rr.CategoryID = @CategoryID
        GROUP BY rr.TeamID
    )
    INSERT INTO EventRankings (EventID, CategoryID, TeamID, FinalScore, RankPosition)
    SELECT
        @EventID,
        @CategoryID,
        TeamID,
        FinalScore,
        RANK() OVER (ORDER BY FinalScore DESC)
    FROM FinalScores;
END;
GO

-- ============================================================
-- SECTION 16: VIEWS
-- ============================================================

CREATE OR ALTER VIEW vw_SubmissionDetails AS
SELECT
    s.SubmissionID,
    e.EventID,
    e.EventName,
    r.RoundID,
    r.RoundName,
    r.RoundOrder,
    c.CategoryID,
    c.CategoryName,
    t.TeamID,
    t.TeamName,
    ss.StatusName AS SubmissionStatus,
    s.RepositoryURL,
    s.DemoURL,
    s.ReportURL,
    s.SlideURL,
    s.SubmittedAt,
    u.FullName AS SubmittedBy
FROM Submissions s
JOIN Teams t ON t.TeamID = s.TeamID
JOIN Categories c ON c.CategoryID = t.CategoryID
JOIN Events e ON e.EventID = t.EventID
JOIN Rounds r ON r.RoundID = s.RoundID
JOIN SubmissionStatus ss ON ss.StatusID = s.SubmissionStatusID
JOIN Users u ON u.UserID = s.SubmittedByUserID;
GO

CREATE OR ALTER VIEW vw_JudgeScoreSheet AS
SELECT
    sc.JudgingID,
    e.EventID,
    e.EventName,
    r.RoundID,
    r.RoundName,
    t.TeamID,
    t.TeamName,
    c.CategoryName,
    s.SubmissionID,
    u.UserID AS JudgeUserID,
    u.FullName AS JudgeName,
    ut.TypeName AS JudgeType,
    ec.EventCriterionID,
    ec.CriterionName,
    ec.Weight,
    ec.MaxScore,
    sc.ScoreValue,
    sc.ScoreValue * ec.Weight AS WeightedScore,
    sc.Comment,
    sc.JudgedAt,
    sc.IsCalibration
FROM Judging sc
JOIN Submissions s ON s.SubmissionID = sc.SubmissionID
JOIN Teams t ON t.TeamID = s.TeamID
JOIN Categories c ON c.CategoryID = t.CategoryID
JOIN Events e ON e.EventID = t.EventID
JOIN Rounds r ON r.RoundID = s.RoundID
JOIN EventCriteria ec ON ec.EventCriterionID = sc.EventCriterionID
JOIN Users u ON u.UserID = sc.JudgeUserID
JOIN UserType ut ON ut.UserTypeID = u.UserTypeID;
GO

CREATE OR ALTER VIEW vw_JudgeVariancePerCriterion AS
SELECT
    s.RoundID,
    sc.EventCriterionID,
    ec.CriterionName,
    sc.SubmissionID,
    COUNT(DISTINCT sc.JudgeUserID) AS JudgeCount,
    AVG(sc.ScoreValue) AS MeanScore,
    STDEV(sc.ScoreValue) AS StdDevScore,
    MAX(sc.ScoreValue) - MIN(sc.ScoreValue) AS ScoreRange,
    VAR(sc.ScoreValue) AS VarianceScore
FROM Judging sc
JOIN Submissions s ON s.SubmissionID = sc.SubmissionID
JOIN EventCriteria ec ON ec.EventCriterionID = sc.EventCriterionID
WHERE sc.IsCalibration = 0
GROUP BY s.RoundID, sc.EventCriterionID, ec.CriterionName, sc.SubmissionID;
GO

CREATE OR ALTER VIEW vw_RoundLeaderboard AS
SELECT
    rr.RoundID,
    r.RoundName,
    r.EventID,
    e.EventName,
    rr.CategoryID,
    c.CategoryName,
    rr.TeamID,
    t.TeamName,
    rr.TotalScore,
    rr.AverageScore,
    rr.RankPosition,
    rr.IsAdvanced,
    ts.StatusName AS TeamStatus
FROM RoundRankings rr
JOIN Rounds r ON r.RoundID = rr.RoundID
JOIN Events e ON e.EventID = r.EventID
JOIN Categories c ON c.CategoryID = rr.CategoryID
JOIN Teams t ON t.TeamID = rr.TeamID
JOIN TeamStatus ts ON ts.StatusID = t.TeamStatusID;
GO

CREATE OR ALTER VIEW vw_AnonymizedScores AS
SELECT
    sc.JudgingID,
    r.RoundID,
    r.RoundName,
    c.CategoryID,
    c.CategoryName,
    HASHBYTES('SHA2_256', CAST(sc.SubmissionID AS NVARCHAR(36))) AS AnonymousSubmissionID,
    HASHBYTES('SHA2_256', CAST(sc.JudgeUserID AS NVARCHAR(36))) AS AnonymousJudgeID,
    ec.CriterionName,
    ec.Weight,
    ec.MaxScore,
    sc.ScoreValue,
    sc.JudgedAt,
    sc.IsCalibration
FROM Judging sc
JOIN Submissions s ON s.SubmissionID = sc.SubmissionID
JOIN Teams t ON t.TeamID = s.TeamID
JOIN Categories c ON c.CategoryID = t.CategoryID
JOIN Rounds r ON r.RoundID = s.RoundID
JOIN EventCriteria ec ON ec.EventCriterionID = sc.EventCriterionID;
GO

-- ============================================================
-- SECTION 17: SAMPLE DATA
-- ============================================================

DECLARE @AdminID UNIQUEIDENTIFIER = NEWID();

INSERT INTO Users (UserID, Email, PasswordHash, FullName, UserTypeID, AccountStatusID)
VALUES (@AdminID,
        N'admin@seal.fpt.edu.vn',
        N'$2a$12$PLACEHOLDER_HASH_REPLACE_IN_APP',
        N'SEAL Administrator',
        '10000000-0000-0000-0000-000000000003',
        '20000000-0000-0000-0000-000000000002');

INSERT INTO CriterionTemplate (CriterionName, Description, DefaultWeight, MaxScore, CreatedByID)
VALUES
    (N'Technical Complexity', N'Depth and complexity of technical implementation', 2.0, 10.0, @AdminID),
    (N'Innovation', N'Originality and creativity of the solution', 2.0, 10.0, @AdminID),
    (N'Feasibility', N'Real-world applicability and viability', 1.5, 10.0, @AdminID),
    (N'Presentation Quality', N'Clarity and effectiveness of the demo/slide', 1.5, 10.0, @AdminID),
    (N'Impact & Social Value', N'Potential societal or business impact', 1.0, 10.0, @AdminID),
    (N'Code Quality', N'Readability, structure, and maintainability', 1.0, 10.0, @AdminID);

DECLARE @Leader1ID UNIQUEIDENTIFIER = NEWID();
DECLARE @Member1ID UNIQUEIDENTIFIER = NEWID();
DECLARE @Member2ID UNIQUEIDENTIFIER = NEWID();
DECLARE @Applicant1ID UNIQUEIDENTIFIER = NEWID();
DECLARE @Leader2ID UNIQUEIDENTIFIER = NEWID();

INSERT INTO Users (UserID, Email, PasswordHash, FullName, Phone, UserTypeID, AccountStatusID, FPTStudentCode)
VALUES
    (@Leader1ID, N'leader1@fpt.edu.vn', N'$2a$12$PLACEHOLDER_HASH_REPLACE_IN_APP', N'Nguyen Van Leader', N'0900000001', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', N'SE170001'),
    (@Member1ID, N'member1@fpt.edu.vn', N'$2a$12$PLACEHOLDER_HASH_REPLACE_IN_APP', N'Tran Thi Member', N'0900000002', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', N'SE170002'),
    (@Member2ID, N'member2@fpt.edu.vn', N'$2a$12$PLACEHOLDER_HASH_REPLACE_IN_APP', N'Le Van Member', N'0900000003', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', N'SE170003'),
    (@Applicant1ID, N'applicant1@fpt.edu.vn', N'$2a$12$PLACEHOLDER_HASH_REPLACE_IN_APP', N'Pham Thi Applicant', N'0900000004', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', N'SE170004'),
    (@Leader2ID, N'leader2@fpt.edu.vn', N'$2a$12$PLACEHOLDER_HASH_REPLACE_IN_APP', N'Hoang Van Leader', N'0900000005', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', N'SE170005');

DECLARE @EventID UNIQUEIDENTIFIER = NEWID();

INSERT INTO Events (
    EventID, EventName, Description, Location, EventStatusID,
    RegistrationStart, RegistrationEnd, EventStartDate, EventEndDate,
    MaxTeamSize, MinTeamSize, CreatedByID
)
VALUES (
    @EventID,
    N'SEAL Hackathon 2026',
    N'Sample event for testing team workflow',
    N'FPT University',
    '30000000-0000-0000-0000-000000000002',
    DATEADD(DAY, -7, GETUTCDATE()),
    DATEADD(DAY, 7, GETUTCDATE()),
    CAST(GETUTCDATE() AS DATE),
    DATEADD(DAY, 3, CAST(GETUTCDATE() AS DATE)),
    5,
    3,
    @AdminID
);

DECLARE @CategoryID UNIQUEIDENTIFIER = NEWID();

INSERT INTO Categories (CategoryID, EventID, CategoryName, Description, SortOrder, IsActive)
VALUES (@CategoryID, @EventID, N'Web Application', N'Sample category for web application teams', 1, 1);

DECLARE @Team1ID UNIQUEIDENTIFIER = NEWID();

INSERT INTO Teams (TeamID, EventID, CategoryID, TeamName, TeamStatusID, LeaderUserID)
VALUES (@Team1ID, @EventID, @CategoryID, N'SEAL Builders', '60000000-0000-0000-0000-000000000002', @Leader1ID);

INSERT INTO TeamMembers (TeamID, UserID, IsActive)
VALUES
    (@Team1ID, @Leader1ID, 1),
    (@Team1ID, @Member1ID, 1),
    (@Team1ID, @Member2ID, 1);

INSERT INTO TeamJoinRequests (TeamID, UserID, RequestStatus)
VALUES (@Team1ID, @Applicant1ID, N'PENDING');

DECLARE @Team2ID UNIQUEIDENTIFIER = NEWID();

INSERT INTO Teams (TeamID, EventID, CategoryID, TeamName, TeamStatusID, LeaderUserID)
VALUES (@Team2ID, @EventID, @CategoryID, N'Disqualified Demo Team', '60000000-0000-0000-0000-000000000003', @Leader2ID);

INSERT INTO TeamMembers (TeamID, UserID, IsActive)
VALUES (@Team2ID, @Leader2ID, 1);

INSERT INTO Disqualifications (TeamID, Reason, DisqualifiedByID)
VALUES (@Team2ID, N'Sample disqualification record for testing', @AdminID);
GO

-- ============================================================
-- SECTION 18: INDEXES FOR PERFORMANCE
-- ============================================================

CREATE NONCLUSTERED INDEX IX_Teams_Event ON Teams(EventID);
CREATE NONCLUSTERED INDEX IX_Teams_Category ON Teams(CategoryID);
CREATE NONCLUSTERED INDEX IX_TeamMembers_User ON TeamMembers(UserID) WHERE IsActive = 1;
CREATE NONCLUSTERED INDEX IX_Submissions_Round ON Submissions(RoundID);
CREATE NONCLUSTERED INDEX IX_Submissions_Team ON Submissions(TeamID);
CREATE NONCLUSTERED INDEX IX_RoundRankings_Round_Cat ON RoundRankings(RoundID, CategoryID);
CREATE NONCLUSTERED INDEX IX_EventRankings_Event_Cat ON EventRankings(EventID, CategoryID);
CREATE NONCLUSTERED INDEX IX_Rounds_Event ON Rounds(EventID);
CREATE NONCLUSTERED INDEX IX_Categories_Event ON Categories(EventID);
GO

CREATE OR ALTER TRIGGER trg_EnforceOneTeamPerEvent
ON TeamMembers
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Teams t_new ON i.TeamID = t_new.TeamID
        JOIN TeamMembers tm_existing ON i.UserID = tm_existing.UserID
        JOIN Teams t_existing ON tm_existing.TeamID = t_existing.TeamID
        WHERE i.IsActive = 1
          AND tm_existing.IsActive = 1
          AND t_new.EventID = t_existing.EventID
          AND i.TeamMemberID <> tm_existing.TeamMemberID
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 51002, N'Lỗi DB: Một sinh viên chỉ được tham gia tối đa 1 nhóm đang hoạt động trong cùng 1 sự kiện!', 1;
    END
END;
GO

PRINT N'SEAL_HackathonDB UUID version created successfully.';
GO
