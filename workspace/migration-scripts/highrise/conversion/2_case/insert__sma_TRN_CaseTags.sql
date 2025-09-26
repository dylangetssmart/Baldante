-- =======================================================
-- Author:        PWLAW\dsmith
-- Create date:   2025-09-12
-- Description:   Imports contact tags from Highrise and links them to cases.
-- =======================================================

USE SABaldantePracticeMasterConversion;
GO

---
alter table [sma_TRN_CaseTags] disable trigger all
go
---

-- Set compatibility level for STRING_SPLIT, if not already set.
DECLARE @compatibility_level INT;
SELECT @compatibility_level = compatibility_level FROM sys.databases WHERE name = 'SABaldantePracticeMasterConversion';

IF @compatibility_level < 130
BEGIN
    ALTER DATABASE SABaldantePracticeMasterConversion SET compatibility_level = 160;
END
GO

-- Create a temporary junction table to hold split tags
IF OBJECT_ID('tempdb..#ContactTags') IS NOT NULL
    DROP TABLE #ContactTags;

CREATE TABLE #ContactTags (
    contact_id INT NOT NULL,
    tag        NVARCHAR(255) NOT NULL
);

-- Split comma-separated tags and insert them into the temporary table
-- using the STRING_SPLIT function introduced in SQL Server 2016 (compatibility level 130)
INSERT INTO #ContactTags (contact_id, tag)
SELECT
    c.id,
    TRIM(value) AS Tag
FROM Baldante_Highrise..contacts AS c
CROSS APPLY STRING_SPLIT(c.tags, ',')
WHERE
    ISNULL(c.tags, '') <> '';

-- Insert any new, unique tags into the master tags table
INSERT INTO [dbo].[sma_MST_CaseTags]
    (
        [Name],
        [LimitTagGroups],
        [IsActive],
        [CreateUserID],
        [DtCreated],
        [ModifyUserID],
        [dDtModified]
    )
SELECT DISTINCT
    ct.tag      AS name,
    0           AS LimitTagGroups,
    1           AS IsActive,
    368         AS CreateUserID,
    GETDATE()   AS DtCreated,
    368         AS ModifyUserID,
    GETDATE()   AS dDtModified
FROM #ContactTags AS ct
WHERE
    NOT EXISTS (
        SELECT 1 FROM [dbo].[sma_MST_CaseTags] AS smct WHERE smct.Name = ct.tag
    );

-- Add the newly created tags to their corresponding cases
-- This join is more efficient than the original subquery
INSERT INTO [dbo].[sma_TRN_CaseTags]
    (
        [CaseID],
        [TagID],
        [CreateUserID],
        [DtCreated],
        [DeleteUserID],
        [DtDeleted]
    )
SELECT DISTINCT
    stc.casnCaseID AS [CaseID],
    smct.TagID     AS [TagID],
    368            AS [CreateUserID],
    GETDATE()      AS [DtCreated],
    NULL           AS DeleteUserID,
    NULL           AS DtDeleted
FROM Baldante_Highrise..contacts AS c
JOIN SABaldantePracticeMasterConversion..sma_TRN_Cases AS stc
    ON stc.cassCaseNumber = c.company_name
JOIN #ContactTags AS ct
    ON ct.contact_id = c.id
JOIN [dbo].[sma_MST_CaseTags] AS smct
    ON smct.Name = ct.tag;


---
alter table [sma_TRN_CaseTags] enable trigger all
go
---