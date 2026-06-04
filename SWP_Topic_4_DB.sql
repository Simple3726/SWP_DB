-- =====================================================
-- TABLE: EvaluationAuditLogs
-- Purpose:
-- Store audit logs for all scoring modifications
-- and team/submission eliminations
-- =====================================================

CREATE TABLE EvaluationAuditLogs (
    EvaluationAuditLogID BIGINT IDENTITY(1,1) PRIMARY KEY,

    EventID INT NOT NULL,
    ActionType NVARCHAR(50) NOT NULL,
    ActorUserID INT NOT NULL,

    -- Contextual Foreign Keys
    -- Nullable depending on action type
    ScoreID BIGINT NULL,
    TeamID INT NULL,
    SubmissionID INT NULL,

    OldValue NVARCHAR(MAX) NULL,
    NewValue NVARCHAR(MAX) NULL,

    Reason NVARCHAR(MAX) NOT NULL,

    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),

    CONSTRAINT FK_EvaluationAuditLogs_Event
        FOREIGN KEY (EventID)
        REFERENCES Events(EventID),

    CONSTRAINT FK_EvaluationAuditLogs_Actor
        FOREIGN KEY (ActorUserID)
        REFERENCES Users(UserID),

    CONSTRAINT FK_EvaluationAuditLogs_Score
        FOREIGN KEY (ScoreID)
        REFERENCES Scores(ScoreID),

    CONSTRAINT FK_EvaluationAuditLogs_Team
        FOREIGN KEY (TeamID)
        REFERENCES Teams(TeamID),

    CONSTRAINT FK_EvaluationAuditLogs_Submission
        FOREIGN KEY (SubmissionID)
        REFERENCES Submissions(SubmissionID),

    CONSTRAINT CK_EvaluationAuditLogs_ActionType
        CHECK (
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

    CONSTRAINT CK_EvaluationAuditLogs_Target
        CHECK (
            ScoreID IS NOT NULL
            OR TeamID IS NOT NULL
            OR SubmissionID IS NOT NULL
        )
);
GO

CREATE NONCLUSTERED INDEX IX_EvaluationAuditLogs_Event
ON EvaluationAuditLogs(EventID);

CREATE NONCLUSTERED INDEX IX_EvaluationAuditLogs_Actor
ON EvaluationAuditLogs(ActorUserID);

CREATE NONCLUSTERED INDEX IX_EvaluationAuditLogs_Score
ON EvaluationAuditLogs(ScoreID)
WHERE ScoreID IS NOT NULL;

CREATE NONCLUSTERED INDEX IX_EvaluationAuditLogs_Team
ON EvaluationAuditLogs(TeamID)
WHERE TeamID IS NOT NULL;

CREATE NONCLUSTERED INDEX IX_EvaluationAuditLogs_Submission
ON EvaluationAuditLogs(SubmissionID)
WHERE SubmissionID IS NOT NULL;

CREATE NONCLUSTERED INDEX IX_EvaluationAuditLogs_CreatedAt
ON EvaluationAuditLogs(CreatedAt DESC);
GO