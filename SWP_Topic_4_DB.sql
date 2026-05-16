-- ============================================================
-- SEAL – Software Engineering Hackathon Management System
-- MS SQL Server Database Script
-- Version: 1.0 (Fixed Version)
-- ============================================================

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'SWP_SEAL_HackathonDB')
    DROP DATABASE SWP_SEAL_HackathonDB;
GO

CREATE DATABASE SWP_SEAL_HackathonDB
    COLLATE Vietnamese_CI_AS;
GO

USE SWP_SEAL_HackathonDB;
GO

-- ============================================================
-- SECTION 1: ENUMS / LOOKUP TABLES
-- ============================================================

CREATE TABLE UserType (
    UserTypeID   TINYINT      PRIMARY KEY,
    TypeName     NVARCHAR(50) NOT NULL UNIQUE
);
INSERT INTO UserType VALUES
    (1, N'FPT Student'),
    (2, N'External Student'),
    (3, N'Organizer'),
    (4, N'Internal Judge'),
    (5, N'Guest Judge');
GO

CREATE TABLE AccountStatus (
    StatusID   TINYINT      PRIMARY KEY,
    StatusName NVARCHAR(50) NOT NULL UNIQUE
);
INSERT INTO AccountStatus VALUES
    (1, N'Pending Approval'),
    (2, N'Active'),
    (3, N'Rejected'),
    (4, N'Suspended'),
    (5, N'Temporary');   -- Guest Judge accounts
GO

CREATE TABLE EventStatus (
    StatusID   TINYINT      PRIMARY KEY,
    StatusName NVARCHAR(50) NOT NULL UNIQUE
);
INSERT INTO EventStatus VALUES
    (1, N'Draft'),
    (2, N'Registration Open'),
    (3, N'Ongoing'),
    (4, N'Completed'),
    (5, N'Cancelled');
GO

CREATE TABLE RoundStatus (
    StatusID   TINYINT      PRIMARY KEY,
    StatusName NVARCHAR(50) NOT NULL UNIQUE
);
INSERT INTO RoundStatus VALUES
    (1, N'Upcoming'),
    (2, N'Submission Open'),
    (3, N'Judging'),
    (4, N'Completed');
GO

CREATE TABLE SubmissionStatus (
    StatusID   TINYINT      PRIMARY KEY,
    StatusName NVARCHAR(50) NOT NULL UNIQUE
);
INSERT INTO SubmissionStatus VALUES
    (1, N'Draft'),
    (2, N'Submitted'),
    (3, N'Under Review'),
    (4, N'Disqualified');
GO

CREATE TABLE TeamStatus (
    StatusID   TINYINT      PRIMARY KEY,
    StatusName NVARCHAR(50) NOT NULL UNIQUE
);
INSERT INTO TeamStatus VALUES
    (1, N'Forming'),
    (2, N'Active'),
    (3, N'Disqualified'),
    (4, N'Withdrawn');
GO

CREATE TABLE AwardTier (
    TierID   TINYINT      PRIMARY KEY,
    TierName NVARCHAR(50) NOT NULL UNIQUE
);
INSERT INTO AwardTier VALUES
    (1, N'First Place'),
    (2, N'Second Place'),
    (3, N'Third Place'),
    (4, N'Honorable Mention'),
    (5, N'Best Innovation'),
    (6, N'Best Presentation'),
    (7, N'Special Award');
GO

-- ============================================================
-- SECTION 2: USERS & AUTHENTICATION
-- ============================================================

CREATE TABLE Users (
    UserID            INT              IDENTITY(1,1) PRIMARY KEY,
    Email             NVARCHAR(255)    NOT NULL UNIQUE,
    PasswordHash      NVARCHAR(512)    NOT NULL,
    FullName          NVARCHAR(200)    NOT NULL,
    Phone             NVARCHAR(20)     NULL,
    UserTypeID        TINYINT          NOT NULL REFERENCES UserType(UserTypeID),
    AccountStatusID   TINYINT          NOT NULL DEFAULT 1 REFERENCES AccountStatus(StatusID),
    -- FPT Student fields
    FPTStudentCode    NVARCHAR(20)     NULL,
    -- External Student fields
    ExternalStudentCode NVARCHAR(50)   NULL,
    UniversityName    NVARCHAR(200)    NULL,
    -- Timestamps
    CreatedAt         DATETIME2        NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt         DATETIME2        NOT NULL DEFAULT GETUTCDATE(),
    ApprovedAt        DATETIME2        NULL,
    ApprovedByUserID  INT              NULL,
    -- Guest Judge expiry
    AccountExpiresAt  DATETIME2        NULL,
    -- Soft delete
    IsDeleted         BIT              NOT NULL DEFAULT 0,
    CONSTRAINT CK_Users_FPTCode CHECK (
        UserTypeID != 1 OR FPTStudentCode IS NOT NULL
    ),
    CONSTRAINT CK_Users_ExternalCode CHECK (
        UserTypeID != 2 OR (ExternalStudentCode IS NOT NULL AND UniversityName IS NOT NULL)
    )
);

CREATE NONCLUSTERED INDEX IX_Users_Email ON Users(Email) WHERE IsDeleted = 0;
CREATE NONCLUSTERED INDEX IX_Users_UserType ON Users(UserTypeID);

ALTER TABLE Users
    ADD CONSTRAINT FK_Users_ApprovedBy FOREIGN KEY (ApprovedByUserID)
        REFERENCES Users(UserID);
GO

-- JWT Refresh Token store
CREATE TABLE RefreshTokens (
    TokenID     BIGINT        IDENTITY(1,1) PRIMARY KEY,
    UserID      INT           NOT NULL REFERENCES Users(UserID),
    TokenHash   NVARCHAR(512) NOT NULL UNIQUE,
    IssuedAt    DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
    ExpiresAt   DATETIME2     NOT NULL,
    RevokedAt   DATETIME2     NULL,
    DeviceInfo  NVARCHAR(500) NULL
);
GO

-- ============================================================
-- SECTION 3: SCORING CRITERIA TEMPLATES
-- ============================================================

-- Global criterion templates (reusable across events)
CREATE TABLE CriterionTemplate (
    TemplateID    INT           IDENTITY(1,1) PRIMARY KEY,
    CriterionName NVARCHAR(200) NOT NULL,
    Description   NVARCHAR(MAX) NULL,
    DefaultWeight DECIMAL(5,2)  NOT NULL DEFAULT 1.00,
    MaxScore      DECIMAL(6,2)  NOT NULL DEFAULT 10.00,
    IsActive      BIT           NOT NULL DEFAULT 1,
    CreatedByID   INT           NOT NULL REFERENCES Users(UserID),
    CreatedAt     DATETIME2     NOT NULL DEFAULT GETUTCDATE()
);
GO

-- ============================================================
-- SECTION 4: EVENTS
-- ============================================================

CREATE TABLE Events (
    EventID          INT           IDENTITY(1,1) PRIMARY KEY,
    EventName        NVARCHAR(300) NOT NULL,
    Description      NVARCHAR(MAX) NULL,
    BannerImageURL   NVARCHAR(500) NULL,
    EventStatusID    TINYINT       NOT NULL DEFAULT 1 REFERENCES EventStatus(StatusID),
    RegistrationStart DATETIME2    NULL,
    RegistrationEnd  DATETIME2     NULL,
    EventStartDate   DATE          NULL,
    EventEndDate     DATE          NULL,
    MaxTeamSize      TINYINT       NOT NULL DEFAULT 5,
    MinTeamSize      TINYINT       NOT NULL DEFAULT 3,
    CreatedByID      INT           NOT NULL REFERENCES Users(UserID),
    CreatedAt        DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt        DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
    IsDeleted        BIT           NOT NULL DEFAULT 0
);
GO

-- Event-level scoring criteria (inherited from template, customizable)
CREATE TABLE EventCriteria (
    EventCriterionID INT           IDENTITY(1,1) PRIMARY KEY,
    EventID          INT           NOT NULL REFERENCES Events(EventID),
    TemplateID       INT           NULL REFERENCES CriterionTemplate(TemplateID),  -- NULL = custom for this event
    CriterionName    NVARCHAR(200) NOT NULL,
    Description      NVARCHAR(MAX) NULL,
    Weight           DECIMAL(5,2)  NOT NULL DEFAULT 1.00,
    MaxScore         DECIMAL(6,2)  NOT NULL DEFAULT 10.00,
    SortOrder        TINYINT       NOT NULL DEFAULT 0,
    IsActive         BIT           NOT NULL DEFAULT 1,
    CONSTRAINT UQ_EventCriteria_Event_Name UNIQUE (EventID, CriterionName)
);
GO

-- ============================================================
-- SECTION 5: CATEGORIES (HẠNG MỤC)
-- ============================================================

CREATE TABLE Categories (
    CategoryID   INT           IDENTITY(1,1) PRIMARY KEY,
    EventID      INT           NOT NULL REFERENCES Events(EventID),
    CategoryName NVARCHAR(300) NOT NULL,
    Description  NVARCHAR(MAX) NULL,
    MentorUserID INT           NULL REFERENCES Users(UserID),  -- Assigned mentor
    SortOrder    TINYINT       NOT NULL DEFAULT 0,
    IsActive     BIT           NOT NULL DEFAULT 1,
    CONSTRAINT UQ_Categories_Event_Name UNIQUE (EventID, CategoryName)
);
GO

-- ============================================================
-- SECTION 6: ROUNDS (VÒNG THI)
-- ============================================================

CREATE TABLE Rounds (
    RoundID              INT           IDENTITY(1,1) PRIMARY KEY,
    EventID              INT           NOT NULL REFERENCES Events(EventID),
    RoundName            NVARCHAR(200) NOT NULL,
    RoundOrder           TINYINT       NOT NULL,  -- 1 = first round
    RoundStatusID        TINYINT       NOT NULL DEFAULT 1 REFERENCES RoundStatus(StatusID),
    SubmissionDeadline   DATETIME2     NULL,
    JudgingDeadline      DATETIME2     NULL,
    StartDate            DATETIME2     NULL,
    EndDate              DATETIME2     NULL,
    -- Advancement rules: top N teams per category advance
    AdvancementTopN      INT           NULL,      -- NULL = no auto-advancement (final round)
    IsCalibrationRound   BIT           NOT NULL DEFAULT 0,  -- RBL: calibration round flag
    Description          NVARCHAR(MAX) NULL,
    CONSTRAINT UQ_Rounds_Event_Order UNIQUE (EventID, RoundOrder)
);
GO

-- Judge assignments to rounds (both internal and guest judges)
CREATE TABLE RoundJudges (
    RoundJudgeID INT       IDENTITY(1,1) PRIMARY KEY,
    RoundID      INT       NOT NULL REFERENCES Rounds(RoundID),
    UserID       INT       NOT NULL REFERENCES Users(UserID),
    AssignedAt   DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    AssignedByID INT       NOT NULL REFERENCES Users(UserID),
    CONSTRAINT UQ_RoundJudges UNIQUE (RoundID, UserID)
);
GO

-- Which criteria apply to each round (subset of EventCriteria)
CREATE TABLE RoundCriteria (
    RoundCriterionID INT           IDENTITY(1,1) PRIMARY KEY,
    RoundID          INT           NOT NULL REFERENCES Rounds(RoundID),
    EventCriterionID INT           NOT NULL REFERENCES EventCriteria(EventCriterionID),
    Weight           DECIMAL(5,2)  NULL,  -- Override event-level weight if needed
    CONSTRAINT UQ_RoundCriteria UNIQUE (RoundID, EventCriterionID)
);
GO

-- ============================================================
-- SECTION 7: TEAMS
-- ============================================================

CREATE TABLE Teams (
    TeamID       INT           IDENTITY(1,1) PRIMARY KEY,
    EventID      INT           NOT NULL REFERENCES Events(EventID),
    CategoryID   INT           NOT NULL REFERENCES Categories(CategoryID),
    TeamName     NVARCHAR(300) NOT NULL,
    TeamStatusID TINYINT       NOT NULL DEFAULT 1 REFERENCES TeamStatus(StatusID),
    LeaderUserID INT           NOT NULL REFERENCES Users(UserID),
    CreatedAt    DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt    DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT UQ_Teams_Event_Name UNIQUE (EventID, TeamName)
);

CREATE TABLE TeamMembers (
    TeamMemberID  INT       IDENTITY(1,1) PRIMARY KEY,
    TeamID        INT       NOT NULL REFERENCES Teams(TeamID),
    UserID        INT       NOT NULL REFERENCES Users(UserID),
    JoinedAt      DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    LeftAt        DATETIME2 NULL,
    IsActive      BIT       NOT NULL DEFAULT 1,
    CONSTRAINT UQ_TeamMembers UNIQUE (TeamID, UserID)
);
GO

-- ============================================================
-- SECTION 8: SUBMISSIONS (NỘP BÀI)
-- ============================================================

CREATE TABLE Submissions (
    SubmissionID       INT            IDENTITY(1,1) PRIMARY KEY,
    TeamID             INT            NOT NULL REFERENCES Teams(TeamID),
    RoundID            INT            NOT NULL REFERENCES Rounds(RoundID),
    SubmissionStatusID TINYINT        NOT NULL DEFAULT 1 REFERENCES SubmissionStatus(StatusID),
    -- URLs
    RepositoryURL      NVARCHAR(500)  NULL,
    DemoURL            NVARCHAR(500)  NULL,
    ReportURL          NVARCHAR(500)  NULL,
    SlideURL           NVARCHAR(500)  NULL,
    -- GitHub/GitLab metadata (optional integration)
    RepoMetadataJSON   NVARCHAR(MAX)  NULL,  -- JSON blob from GitHub/GitLab API
    RepoLastCommitAt   DATETIME2      NULL,
    RepoStarCount      INT            NULL,
    RepoForkCount      INT            NULL,
    -- Timestamps
    SubmittedAt        DATETIME2      NULL,
    LastUpdatedAt      DATETIME2      NOT NULL DEFAULT GETUTCDATE(),
    SubmittedByUserID  INT            NOT NULL REFERENCES Users(UserID),
    Notes              NVARCHAR(MAX)  NULL,
    CONSTRAINT UQ_Submissions_Team_Round UNIQUE (TeamID, RoundID)
);
GO

-- ============================================================
-- SECTION 9: SCORING & EVALUATION
-- ============================================================

-- Individual score given by one judge on one criterion for one submission
CREATE TABLE Scores (
    ScoreID          BIGINT        IDENTITY(1,1) PRIMARY KEY,
    SubmissionID     INT           NOT NULL REFERENCES Submissions(SubmissionID),
    JudgeUserID      INT           NOT NULL REFERENCES Users(UserID),
    EventCriterionID INT           NOT NULL REFERENCES EventCriteria(EventCriterionID),
    ScoreValue       DECIMAL(6,2)  NOT NULL,
    Comment          NVARCHAR(MAX) NULL,
    ScoredAt         DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt        DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
    IsCalibration    BIT           NOT NULL DEFAULT 0,  -- RBL: flag calibration scores
    CONSTRAINT UQ_Scores_Sub_Judge_Criterion UNIQUE (SubmissionID, JudgeUserID, EventCriterionID),
    CONSTRAINT CK_Scores_Value CHECK (ScoreValue >= 0)
);

CREATE NONCLUSTERED INDEX IX_Scores_Submission ON Scores(SubmissionID);
CREATE NONCLUSTERED INDEX IX_Scores_Judge ON Scores(JudgeUserID);
GO

-- ============================================================
-- SECTION 10: RANKINGS & ADVANCEMENT
-- ============================================================

-- Computed rankings per round per category (populated by SP/job)
CREATE TABLE RoundRankings (
    RankingID        INT           IDENTITY(1,1) PRIMARY KEY,
    RoundID          INT           NOT NULL REFERENCES Rounds(RoundID),
    CategoryID       INT           NOT NULL REFERENCES Categories(CategoryID),
    TeamID           INT           NOT NULL REFERENCES Teams(TeamID),
    SubmissionID     INT           NOT NULL REFERENCES Submissions(SubmissionID),
    TotalScore       DECIMAL(10,4) NOT NULL,
    AverageScore     DECIMAL(10,4) NOT NULL,
    RankPosition     INT           NOT NULL,
    IsAdvanced       BIT           NOT NULL DEFAULT 0,
    ComputedAt       DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT UQ_RoundRankings UNIQUE (RoundID, CategoryID, TeamID)
);
GO

-- Overall event-level rankings
CREATE TABLE EventRankings (
    EventRankingID INT           IDENTITY(1,1) PRIMARY KEY,
    EventID        INT           NOT NULL REFERENCES Events(EventID),
    CategoryID     INT           NOT NULL REFERENCES Categories(CategoryID),
    TeamID         INT           NOT NULL REFERENCES Teams(TeamID),
    FinalScore     DECIMAL(10,4) NOT NULL,
    RankPosition   INT           NOT NULL,
    ComputedAt     DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT UQ_EventRankings UNIQUE (EventID, CategoryID, TeamID)
);
GO

-- ============================================================
-- SECTION 11: DISQUALIFICATIONS
-- ============================================================

CREATE TABLE Disqualifications (
    DisqualificationID INT            IDENTITY(1,1) PRIMARY KEY,
    -- Either a team or a submission can be disqualified
    TeamID             INT            NULL REFERENCES Teams(TeamID),
    SubmissionID       INT            NULL REFERENCES Submissions(SubmissionID),
    Reason             NVARCHAR(MAX)  NOT NULL,
    DisqualifiedByID   INT            NOT NULL REFERENCES Users(UserID),
    DisqualifiedAt     DATETIME2      NOT NULL DEFAULT GETUTCDATE(),
    IsReversed         BIT            NOT NULL DEFAULT 0,
    ReversedAt         DATETIME2      NULL,
    ReversedByID       INT            NULL REFERENCES Users(UserID),
    ReversalReason     NVARCHAR(MAX)  NULL,
    CONSTRAINT CK_Disq_Target CHECK (
        (TeamID IS NOT NULL AND SubmissionID IS NULL)
        OR (TeamID IS NULL AND SubmissionID IS NOT NULL)
    )
);
GO

-- ============================================================
-- SECTION 12: AWARDS
-- ============================================================

CREATE TABLE Awards (
    AwardID       INT           IDENTITY(1,1) PRIMARY KEY,
    EventID       INT           NOT NULL REFERENCES Events(EventID),
    CategoryID    INT           NULL REFERENCES Categories(CategoryID),  -- NULL = overall event award
    TeamID        INT           NOT NULL REFERENCES Teams(TeamID),
    AwardTierID   TINYINT       NOT NULL REFERENCES AwardTier(TierID),
    AwardTitle    NVARCHAR(300) NOT NULL,
    Description   NVARCHAR(MAX) NULL,
    PrizeValue    DECIMAL(12,2) NULL,
    PrizeCurrency NCHAR(3)      NULL DEFAULT 'VND',
    AwardedAt     DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
    AwardedByID   INT           NOT NULL REFERENCES Users(UserID),
    IsPublished   BIT           NOT NULL DEFAULT 0,
    PublishedAt   DATETIME2     NULL
);
GO

-- Notifications sent to participants
CREATE TABLE Notifications (
    NotificationID   BIGINT        IDENTITY(1,1) PRIMARY KEY,
    EventID          INT           NULL REFERENCES Events(EventID),
    RecipientUserID  INT           NULL REFERENCES Users(UserID),  -- NULL = broadcast to all event participants
    Title            NVARCHAR(300) NOT NULL,
    Body             NVARCHAR(MAX) NOT NULL,
    SentAt           DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
    SentByUserID     INT           NOT NULL REFERENCES Users(UserID),
    IsRead           BIT           NOT NULL DEFAULT 0
);
GO

-- ============================================================
-- SECTION 13: AUDIT LOG
-- ============================================================

CREATE TABLE AuditLog (
    LogID        BIGINT         IDENTITY(1,1) PRIMARY KEY,
    ActionType   NVARCHAR(100)  NOT NULL,  -- e.g. 'SCORE_SUBMIT', 'TEAM_DISQUALIFY', 'SUBMISSION_UPDATE'
    EntityType   NVARCHAR(100)  NOT NULL,  -- e.g. 'Scores', 'Teams', 'Submissions'
    EntityID     NVARCHAR(50)   NOT NULL,
    ActorUserID  INT            NULL REFERENCES Users(UserID),
    OldValueJSON NVARCHAR(MAX)  NULL,
    NewValueJSON NVARCHAR(MAX)  NULL,
    IPAddress    NVARCHAR(50)   NULL,
    OccurredAt   DATETIME2      NOT NULL DEFAULT GETUTCDATE(),
    Notes        NVARCHAR(MAX)  NULL
);

CREATE NONCLUSTERED INDEX IX_AuditLog_Entity ON AuditLog(EntityType, EntityID);
CREATE NONCLUSTERED INDEX IX_AuditLog_Actor  ON AuditLog(ActorUserID);
CREATE NONCLUSTERED INDEX IX_AuditLog_Time   ON AuditLog(OccurredAt DESC);
GO

-- ============================================================
-- SECTION 14: RBL – RESEARCH-BASED LEARNING FEATURES
-- ============================================================

-- Sample submissions used in calibration rounds
CREATE TABLE CalibrationSamples (
    SampleID           INT           IDENTITY(1,1) PRIMARY KEY,
    RoundID            INT           NOT NULL REFERENCES Rounds(RoundID),
    SubmissionID       INT           NOT NULL REFERENCES Submissions(SubmissionID),
    ReferenceScoreJSON NVARCHAR(MAX) NULL,  -- Expected scores per criterion (JSON)
    AddedByID          INT           NOT NULL REFERENCES Users(UserID),
    AddedAt            DATETIME2     NOT NULL DEFAULT GETUTCDATE()
);
GO

-- Anonymized dataset export log (FIXED: RowCount wrapped in brackets)
CREATE TABLE DataExportLog (
    ExportID      INT           IDENTITY(1,1) PRIMARY KEY,
    EventID       INT           NOT NULL REFERENCES Events(EventID),
    ExportedByID  INT           NOT NULL REFERENCES Users(UserID),
    ExportedAt    DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
    FileFormat    NVARCHAR(10)  NOT NULL DEFAULT 'CSV',
    [RowCount]    INT           NULL,  
    Notes         NVARCHAR(500) NULL
);
GO

-- ============================================================
-- SECTION 15: STORED PROCEDURES
-- ============================================================

-- SP: Approve a user account (FIXED: Clean DROP/CREATE pattern)
IF OBJECT_ID('sp_ApproveUser', 'P') IS NOT NULL
    DROP PROCEDURE sp_ApproveUser;
GO

CREATE PROCEDURE sp_ApproveUser
    @UserID       INT,
    @ApproverID   INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Users
    SET    AccountStatusID = 2,
           ApprovedAt      = GETUTCDATE(),
           ApprovedByUserID = @ApproverID,
           UpdatedAt       = GETUTCDATE()
    WHERE  UserID = @UserID
      AND  AccountStatusID = 1
      AND  IsDeleted = 0;

    INSERT INTO AuditLog (ActionType, EntityType, EntityID, ActorUserID, NewValueJSON)
    VALUES ('ACCOUNT_APPROVED', 'Users', CAST(@UserID AS NVARCHAR), @ApproverID, 
            N'{"status":"Active"}');
END;
GO

-- SP: Create Guest Judge account (temporary)
CREATE OR ALTER PROCEDURE sp_CreateGuestJudge
    @Email         NVARCHAR(255),
    @FullName      NVARCHAR(200),
    @PasswordHash  NVARCHAR(512),
    @ExpiresAt     DATETIME2,
    @CreatedByID   INT,
    @NewUserID     INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Users (Email, PasswordHash, FullName, UserTypeID, AccountStatusID, AccountExpiresAt)
    VALUES (@Email, @PasswordHash, @FullName, 5, 5, @ExpiresAt);

    SET @NewUserID = SCOPE_IDENTITY();

    INSERT INTO AuditLog (ActionType, EntityType, EntityID, ActorUserID, NewValueJSON)
    VALUES ('GUEST_JUDGE_CREATED', 'Users', CAST(@NewUserID AS NVARCHAR), @CreatedByID, 
            N'{"type":"GuestJudge"}');
END;
GO

-- SP: Submit or update a team's submission
CREATE OR ALTER PROCEDURE sp_UpsertSubmission
    @TeamID            INT,
    @RoundID           INT,
    @RepositoryURL     NVARCHAR(500),
    @DemoURL           NVARCHAR(500),
    @ReportURL         NVARCHAR(500),
    @SlideURL          NVARCHAR(500),
    @Notes             NVARCHAR(MAX),
    @SubmittedByUserID INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SubID INT;

    IF EXISTS (SELECT 1 FROM Submissions WHERE TeamID = @TeamID AND RoundID = @RoundID)
    BEGIN
        UPDATE Submissions
        SET    RepositoryURL      = @RepositoryURL,
               DemoURL            = @DemoURL,
               ReportURL          = @ReportURL,
               SlideURL           = @SlideURL,
               Notes              = @Notes,
               SubmissionStatusID = 2,
               SubmittedAt        = GETUTCDATE(),
               LastUpdatedAt      = GETUTCDATE(),
               SubmittedByUserID  = @SubmittedByUserID
        WHERE  TeamID = @TeamID AND RoundID = @RoundID;

        SELECT @SubID = SubmissionID FROM Submissions WHERE TeamID = @TeamID AND RoundID = @RoundID;
        INSERT INTO AuditLog (ActionType, EntityType, EntityID, ActorUserID)
        VALUES ('SUBMISSION_UPDATED', 'Submissions', CAST(@SubID AS NVARCHAR), @SubmittedByUserID);
    END
    ELSE
    BEGIN
        -- Check submission deadline
        DECLARE @Deadline DATETIME2;
        SELECT @Deadline = SubmissionDeadline FROM Rounds WHERE RoundID = @RoundID;
        IF @Deadline IS NOT NULL AND GETUTCDATE() > @Deadline
            THROW 51000, N'Submission deadline has passed.', 1;

        INSERT INTO Submissions (TeamID, RoundID, RepositoryURL, DemoURL, ReportURL, SlideURL, 
                                 Notes, SubmissionStatusID, SubmittedAt, SubmittedByUserID)
        VALUES (@TeamID, @RoundID, @RepositoryURL, @DemoURL, @ReportURL, @SlideURL, 
                @Notes, 2, GETUTCDATE(), @SubmittedByUserID);

        SET @SubID = SCOPE_IDENTITY();
        INSERT INTO AuditLog (ActionType, EntityType, EntityID, ActorUserID)
        VALUES ('SUBMISSION_CREATED', 'Submissions', CAST(@SubID AS NVARCHAR), @SubmittedByUserID);
    END;
END;
GO

-- SP: Record a judge's score for a criterion
CREATE OR ALTER PROCEDURE sp_RecordScore
    @SubmissionID     INT,
    @JudgeUserID      INT,
    @EventCriterionID INT,
    @ScoreValue       DECIMAL(6,2),
    @Comment          NVARCHAR(MAX) = NULL,
    @IsCalibration    BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate judge is assigned to the round
    DECLARE @RoundID INT;
    SELECT @RoundID = RoundID FROM Submissions WHERE SubmissionID = @SubmissionID;

    IF NOT EXISTS (SELECT 1 FROM RoundJudges WHERE RoundID = @RoundID AND UserID = @JudgeUserID)
        THROW 52000, N'Judge is not assigned to this round.', 1;

    -- Validate score does not exceed max
    DECLARE @MaxScore DECIMAL(6,2);
    SELECT @MaxScore = MaxScore FROM EventCriteria WHERE EventCriterionID = @EventCriterionID;
    IF @ScoreValue > @MaxScore
        THROW 52001, N'Score exceeds the maximum allowed value.', 1;

    MERGE Scores AS target
    USING (SELECT @SubmissionID AS SubmissionID, 
                  @JudgeUserID  AS JudgeUserID, 
                  @EventCriterionID AS EventCriterionID) AS source
    ON  target.SubmissionID     = source.SubmissionID 
    AND target.JudgeUserID      = source.JudgeUserID 
    AND target.EventCriterionID = source.EventCriterionID
    WHEN MATCHED THEN 
        UPDATE SET ScoreValue   = @ScoreValue,
                   Comment      = @Comment,
                   UpdatedAt    = GETUTCDATE()
    WHEN NOT MATCHED THEN
        INSERT (SubmissionID, JudgeUserID, EventCriterionID, ScoreValue, Comment, IsCalibration)
        VALUES (@SubmissionID, @JudgeUserID, @EventCriterionID, @ScoreValue, @Comment, @IsCalibration);

    INSERT INTO AuditLog (ActionType, EntityType, EntityID, ActorUserID, NewValueJSON)
    VALUES ('SCORE_RECORDED', 'Scores', 
            CAST(@SubmissionID AS NVARCHAR) + '_' + CAST(@JudgeUserID AS NVARCHAR), 
            @JudgeUserID,
            N'{"criterion":' + CAST(@EventCriterionID AS NVARCHAR) + 
            ',"score":' + CAST(@ScoreValue AS NVARCHAR) + '}');
END;
GO

-- SP: Disqualify a team
CREATE OR ALTER PROCEDURE sp_DisqualifyTeam
    @TeamID          INT,
    @Reason          NVARCHAR(MAX),
    @DisqualifiedByID INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Update team status
    UPDATE Teams SET TeamStatusID = 3, UpdatedAt = GETUTCDATE() WHERE TeamID = @TeamID;

    -- Log disqualification
    INSERT INTO Disqualifications (TeamID, Reason, DisqualifiedByID)
    VALUES (@TeamID, @Reason, @DisqualifiedByID);

    INSERT INTO AuditLog (ActionType, EntityType, EntityID, ActorUserID, NewValueJSON)
    VALUES ('TEAM_DISQUALIFIED', 'Teams', CAST(@TeamID AS NVARCHAR), @DisqualifiedByID, 
            N'{"reason":"' + REPLACE(@Reason, '"', '\"') + '"}');
END;
GO

-- SP: Disqualify a submission
CREATE OR ALTER PROCEDURE sp_DisqualifySubmission
    @SubmissionID    INT,
    @Reason          NVARCHAR(MAX),
    @DisqualifiedByID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Submissions
    SET    SubmissionStatusID = 4,
           LastUpdatedAt      = GETUTCDATE()
    WHERE  SubmissionID = @SubmissionID;

    INSERT INTO Disqualifications (SubmissionID, Reason, DisqualifiedByID)
    VALUES (@SubmissionID, @Reason, @DisqualifiedByID);

    INSERT INTO AuditLog (ActionType, EntityType, EntityID, ActorUserID, NewValueJSON)
    VALUES ('SUBMISSION_DISQUALIFIED', 'Submissions', CAST(@SubmissionID AS NVARCHAR), 
            @DisqualifiedByID, 
            N'{"reason":"' + REPLACE(@Reason, '"', '\"') + '"}');
END;
GO

-- SP: Compute round rankings for a specific round & category
CREATE OR ALTER PROCEDURE sp_ComputeRoundRankings
    @RoundID    INT,
    @CategoryID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Delete existing rankings for this round+category
    DELETE FROM RoundRankings WHERE RoundID = @RoundID AND CategoryID = @CategoryID;

    DECLARE @EventID INT;
    SELECT @EventID = EventID FROM Rounds WHERE RoundID = @RoundID;

    ;WITH ScoreSummary AS (
        SELECT 
            s.SubmissionID,
            s.TeamID,
            SUM(sc.ScoreValue * COALESCE(rc.Weight, ec.Weight)) AS WeightedTotal,
            AVG(sc.ScoreValue) AS AverageScore
        FROM Submissions s
        JOIN Teams       t  ON t.TeamID = s.TeamID
        JOIN Scores      sc ON sc.SubmissionID = s.SubmissionID
        JOIN EventCriteria ec ON ec.EventCriterionID = sc.EventCriterionID
        LEFT JOIN RoundCriteria rc ON rc.EventCriterionID = ec.EventCriterionID 
                                   AND rc.RoundID = s.RoundID
        WHERE s.RoundID = @RoundID
          AND t.CategoryID = @CategoryID
          AND s.SubmissionStatusID != 4  -- exclude disqualified
          AND t.TeamStatusID != 3        -- exclude disqualified teams
          AND sc.IsCalibration = 0
        GROUP BY s.SubmissionID, s.TeamID
    ),
    Ranked AS (
        SELECT *,
               RANK() OVER (ORDER BY WeightedTotal DESC) AS RankPosition
        FROM ScoreSummary
    )
    INSERT INTO RoundRankings (RoundID, CategoryID, TeamID, SubmissionID, 
                               TotalScore, AverageScore, RankPosition, IsAdvanced)
    SELECT 
        @RoundID, 
        @CategoryID, 
        r.TeamID, 
        r.SubmissionID, 
        r.WeightedTotal, 
        r.AverageScore, 
        r.RankPosition,
        CASE WHEN rnd.AdvancementTopN IS NOT NULL 
                  AND r.RankPosition <= rnd.AdvancementTopN THEN 1 ELSE 0 END
    FROM Ranked r
    CROSS JOIN Rounds rnd WHERE rnd.RoundID = @RoundID;
END;
GO

-- SP: Compute final event rankings
CREATE OR ALTER PROCEDURE sp_ComputeEventRankings
    @EventID    INT,
    @CategoryID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM EventRankings WHERE EventID = @EventID AND CategoryID = @CategoryID;

    -- Final score = average of all round total scores for each team
    ;WITH FinalScores AS (
        SELECT 
            rr.TeamID,
            AVG(rr.TotalScore) AS FinalScore
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

-- View: Full submission details with team and event info
CREATE OR ALTER VIEW vw_SubmissionDetails AS
SELECT 
    s.SubmissionID,
    e.EventID,    e.EventName,
    r.RoundID,    r.RoundName,    r.RoundOrder,
    c.CategoryID, c.CategoryName,
    t.TeamID,     t.TeamName,
    ss.StatusName AS SubmissionStatus,
    s.RepositoryURL, s.DemoURL, s.ReportURL, s.SlideURL,
    s.SubmittedAt,
    u.FullName AS SubmittedBy
FROM Submissions s
JOIN Teams       t  ON t.TeamID   = s.TeamID
JOIN Categories  c  ON c.CategoryID = t.CategoryID
JOIN Events      e  ON e.EventID  = t.EventID
JOIN Rounds      r  ON r.RoundID  = s.RoundID
JOIN SubmissionStatus ss ON ss.StatusID = s.SubmissionStatusID
JOIN Users       u  ON u.UserID   = s.SubmittedByUserID;
GO

-- View: Judge score sheet with criterion breakdown
CREATE OR ALTER VIEW vw_JudgeScoreSheet AS
SELECT 
    sc.ScoreID,
    e.EventID,    e.EventName,
    r.RoundID,    r.RoundName,
    t.TeamID,     t.TeamName,
    c.CategoryName,
    s.SubmissionID,
    u.UserID  AS JudgeUserID,
    u.FullName AS JudgeName,
    ut.TypeName AS JudgeType,
    ec.EventCriterionID,
    ec.CriterionName,
    ec.Weight,
    ec.MaxScore,
    sc.ScoreValue,
    sc.ScoreValue * ec.Weight AS WeightedScore,
    sc.Comment,
    sc.ScoredAt,
    sc.IsCalibration
FROM Scores sc
JOIN Submissions s  ON s.SubmissionID = sc.SubmissionID
JOIN Teams       t  ON t.TeamID = s.TeamID
JOIN Categories  c  ON c.CategoryID = t.CategoryID
JOIN Events      e  ON e.EventID = t.EventID
JOIN Rounds      r  ON r.RoundID = s.RoundID
JOIN EventCriteria ec ON ec.EventCriterionID = sc.EventCriterionID
JOIN Users       u  ON u.UserID = sc.JudgeUserID
JOIN UserType    ut ON ut.UserTypeID = u.UserTypeID;
GO

-- View: Judge variance per criterion (RBL Dashboard)
CREATE OR ALTER VIEW vw_JudgeVariancePerCriterion AS
SELECT 
    s.RoundID,
    sc.EventCriterionID,
    ec.CriterionName,
    sc.SubmissionID,
    COUNT(DISTINCT sc.JudgeUserID)      AS JudgeCount,
    AVG(sc.ScoreValue)                  AS MeanScore,
    STDEV(sc.ScoreValue)                AS StdDevScore,
    MAX(sc.ScoreValue) - MIN(sc.ScoreValue) AS ScoreRange,
    VAR(sc.ScoreValue)                  AS VarianceScore
FROM Scores sc
JOIN Submissions s ON s.SubmissionID = sc.SubmissionID
JOIN EventCriteria ec ON ec.EventCriterionID = sc.EventCriterionID
WHERE sc.IsCalibration = 0
GROUP BY s.RoundID, sc.EventCriterionID, ec.CriterionName, sc.SubmissionID;
GO

-- View: Team leaderboard per round per category
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
JOIN Rounds     r  ON r.RoundID = rr.RoundID
JOIN Events     e  ON e.EventID = r.EventID
JOIN Categories c  ON c.CategoryID = rr.CategoryID
JOIN Teams      t  ON t.TeamID = rr.TeamID
JOIN TeamStatus ts ON ts.StatusID = t.TeamStatusID;
GO

-- View: Anonymized scoring dataset for RBL export
CREATE OR ALTER VIEW vw_AnonymizedScores AS
SELECT 
    sc.ScoreID,
    r.RoundID,
    r.RoundName,
    c.CategoryID,
    c.CategoryName,
    -- Anonymize: use hash-based identifiers
    HASHBYTES('SHA2_256', CAST(sc.SubmissionID AS NVARCHAR)) AS AnonymousSubmissionID,
    HASHBYTES('SHA2_256', CAST(sc.JudgeUserID  AS NVARCHAR)) AS AnonymousJudgeID,
    ec.CriterionName,
    ec.Weight,
    ec.MaxScore,
    sc.ScoreValue,
    sc.ScoredAt,
    sc.IsCalibration
FROM Scores sc
JOIN Submissions s  ON s.SubmissionID = sc.SubmissionID
JOIN Teams       t  ON t.TeamID = s.TeamID
JOIN Categories  c  ON c.CategoryID = t.CategoryID
JOIN Rounds      r  ON r.RoundID = s.RoundID
JOIN EventCriteria ec ON ec.EventCriterionID = sc.EventCriterionID;
GO

-- ============================================================
-- SECTION 17: SAMPLE DATA
-- ============================================================

-- Default criterion templates
INSERT INTO Users (Email, PasswordHash, FullName, UserTypeID, AccountStatusID)
VALUES (N'admin@seal.fpt.edu.vn', 
        N'$2a$12$PLACEHOLDER_HASH_REPLACE_IN_APP', 
        N'SEAL Administrator', 3, 2);
GO

DECLARE @AdminID INT = SCOPE_IDENTITY();

INSERT INTO CriterionTemplate (CriterionName, Description, DefaultWeight, MaxScore, CreatedByID)
VALUES 
    (N'Technical Complexity',   N'Depth and complexity of technical implementation', 2.0, 10.0, @AdminID),
    (N'Innovation',             N'Originality and creativity of the solution',       2.0, 10.0, @AdminID),
    (N'Feasibility',            N'Real-world applicability and viability',             1.5, 10.0, @AdminID),
    (N'Presentation Quality',   N'Clarity and effectiveness of the demo/slide',      1.5, 10.0, @AdminID),
    (N'Impact & Social Value',  N'Potential societal or business impact',              1.0, 10.0, @AdminID),
    (N'Code Quality',           N'Readability, structure, and maintainability',       1.0, 10.0, @AdminID);
GO

-- ============================================================
-- SECTION 18: INDEXES FOR PERFORMANCE
-- ============================================================

CREATE NONCLUSTERED INDEX IX_Teams_Event     ON Teams(EventID);
CREATE NONCLUSTERED INDEX IX_Teams_Category  ON Teams(CategoryID);
CREATE NONCLUSTERED INDEX IX_TeamMembers_User ON TeamMembers(UserID) WHERE IsActive = 1;
CREATE NONCLUSTERED INDEX IX_Submissions_Round ON Submissions(RoundID);
CREATE NONCLUSTERED INDEX IX_Submissions_Team  ON Submissions(TeamID);
CREATE NONCLUSTERED INDEX IX_RoundRankings_Round_Cat ON RoundRankings(RoundID, CategoryID);
CREATE NONCLUSTERED INDEX IX_EventRankings_Event_Cat ON EventRankings(EventID, CategoryID);
CREATE NONCLUSTERED INDEX IX_Rounds_Event    ON Rounds(EventID);
CREATE NONCLUSTERED INDEX IX_Categories_Event ON Categories(EventID);
GO

PRINT N' SEAL_HackathonDB fixed and created successfully.';
GO