USE Baldante_SA_Highrise
GO
--delete from sma_TRN_Notes
/*
alter table [sma_TRN_Notes] disable trigger all
delete from [sma_TRN_Notes] 
DBCC CHECKIDENT ('[sma_TRN_Notes]', RESEED, 0);
alter table [sma_TRN_Notes] enable trigger all
*/
IF NOT EXISTS (
		SELECT
			*
		FROM sys.tables t
		JOIN sys.columns c
			ON t.object_id = c.object_id
		WHERE t.name = 'Sma_trn_notes'
			AND c.name = 'saga'
	)
BEGIN
	ALTER TABLE sma_trn_notes
	ADD SAGA INT
END
GO

----(0)----
--INSERT INTO [sma_MST_NoteTypes]
--	(
--	nttsDscrptn
--   ,nttsNoteText
--	)
--	SELECT DISTINCT
--		topic AS nttsDscrptn
--	   ,topic AS nttsNoteText
--	FROM TestNeedles.[dbo].[case_notes_Indexed]
--	EXCEPT
--	SELECT
--		nttsDscrptn
--	   ,nttsNoteText
--	FROM [sma_MST_NoteTypes]
--GO

---
ALTER TABLE [sma_TRN_Notes] DISABLE TRIGGER ALL
GO
---

----(1)----
INSERT INTO [sma_TRN_Notes]
	(
	[notnCaseID]
   ,[notnNoteTypeID]
   ,[notmDescription]
   ,[notmPlainText]
   ,[notnContactCtgID]
   ,[notnContactId]
   ,[notsPriority]
   ,[notnFormID]
   ,[notnRecUserID]
   ,[notdDtCreated]
   ,[notnModifyUserID]
   ,[notdDtModified]
   ,[notnLevelNo]
   ,[notdDtInserted]
   ,[WorkPlanItemId]
   ,[notnSubject]
   ,SAGA
	)
	SELECT
		casnCaseID AS [notnCaseID]
	   ,(
			SELECT
				MIN(nttnNoteTypeID)
			FROM [sma_MST_NoteTypes]
			WHERE nttsDscrptn = 'General Comments'
		)		   
		AS [notnNoteTypeID]
	   ,CONCAT(
		COALESCE('Author: ' + n.author, '') + CHAR(10) + CHAR(13),
		COALESCE('About: ' + n.about, '') + CHAR(10) + CHAR(13),
		n.body)	   
		AS [notmDescription]
	   ,CONCAT(
		COALESCE('Author: ' + n.author, '') + '<br>',
		COALESCE('About: ' + n.about, '') + '<br>',
		n.body)	   AS [notmPlainText]
	   ,0		   AS [notnContactCtgID]
	   ,NULL	   AS [notnContactId]
	   ,NULL	   AS [notsPriority]
	   ,NULL	   AS [notnFormID]
	   ,368		   AS [notnRecUserID]
	   ,CASE
			WHEN n.written_date BETWEEN '1900-01-01' AND '2079-06-06'
				THEN n.written_date
			ELSE GETDATE()
		--WHEN N.note_date BETWEEN '1900-01-01' AND '2079-06-06' AND
		--	CONVERT(TIME, ISNULL(N.note_time, '00:00:00')) <> CONVERT(TIME, '00:00:00')
		--	THEN CAST(CAST(N.note_date AS DATETIME) + CAST(N.note_time AS DATETIME) AS DATETIME)
		--WHEN N.note_date BETWEEN '1900-01-01' AND '2079-06-06' AND
		--	CONVERT(TIME, ISNULL(N.note_time, '00:00:00')) = CONVERT(TIME, '00:00:00')
		--	THEN CAST(CAST(N.note_date AS DATETIME) + CAST('00:00:00' AS DATETIME) AS DATETIME)
		--ELSE '1900-01-01'
		END		   AS notdDtCreated
	   ,NULL	   AS [notnModifyUserID]
	   ,NULL	   AS notdDtModified
	   ,NULL	   AS [notnLevelNo]
	   ,NULL	   AS [notdDtInserted]
	   ,NULL	   AS [WorkPlanItemId]
	   ,NULL	   AS [notnSubject]
	   ,n.id AS SAGA
	FROM Baldante_Highrise..notes n
	--FROM TestNeedles.[dbo].[case_notes_Indexed] N
	JOIN [sma_TRN_Cases] C
		ON c.saga = n.contact_id
	--LEFT JOIN [sma_MST_Users] U
	--	ON U.saga = N.staff_id
	LEFT JOIN [sma_TRN_Notes] ns
		ON ns.saga = n.id
	WHERE ns.notnNoteID IS NULL
GO


--alter table sma_trn_notes disable trigger all
--update  sma_trn_notes set notmPlainText=replace(notmPlainText,char(10),'<br>') where  notmPlainText like '%'+char(10)+'%'
--alter table sma_trn_notes enable trigger all

---
ALTER TABLE [sma_TRN_Notes] ENABLE TRIGGER ALL
GO
---

