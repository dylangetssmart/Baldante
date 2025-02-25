USE BaldanteHighriseSA
GO


--IF NOT EXISTS (SELECT * FROM sys.columns WHERE [Name] = N'saga' AND Object_ID = Object_ID(N'sma_MST_Users'))
--BEGIN
--    ALTER TABLE [sma_MST_Users] ADD [saga] [varchar](100) NULL; 
--END
--GO

IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE [Name] = N'saga_ref'
			AND Object_ID = OBJECT_ID(N'sma_MST_IndvContacts')
	)
BEGIN
	ALTER TABLE [sma_MST_IndvContacts] ADD [saga_ref] [VARCHAR](100) NULL;
END
GO
IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga_db'
			AND Object_ID = OBJECT_ID(N'sma_mst_indvcontacts')
	)
BEGIN
	ALTER TABLE [sma_mst_indvcontacts] ADD [saga_db] VARCHAR(5);
END

IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE [Name] = N'saga_ref'
			AND Object_ID = OBJECT_ID(N'sma_MST_OrgContacts')
	)
BEGIN
	ALTER TABLE [sma_MST_OrgContacts] ADD [saga_ref] [VARCHAR](100) NULL;
END
GO
IF NOT EXISTS (
		SELECT
			*
		FROM sys.columns
		WHERE Name = N'saga_db'
			AND Object_ID = OBJECT_ID(N'sma_mst_orgcontacts')
	)
BEGIN
	ALTER TABLE [sma_mst_orgcontacts] ADD [saga_db] VARCHAR(5);
END


--(0) saga field for needles names_id ---
ALTER TABLE [sma_MST_IndvContacts]
ALTER COLUMN saga varchar(100)
ALTER TABLE [sma_MST_OrgContacts]
ALTER COLUMN saga varchar(100)


---------------------------
--INSERT RACE
---------------------------
--INSERT INTO sma_mst_contactRace (RaceDesc)
--SELECT distinct Race_Name from JoelBieberNeedles..Race 
--EXCEPT SELECT RaceDesc From sma_Mst_ContactRace

SET ANSI_WARNINGS ON;
GO

--SELECT 
--    COLUMN_NAME,
--    DATA_TYPE,
--    CHARACTER_MAXIMUM_LENGTH
--FROM 
--    INFORMATION_SCHEMA.COLUMNS
--WHERE 
--    TABLE_NAME = 'sma_MST_IndvContacts';

---------------------------------------
-- Individual Contacts
---------------------------------------
INSERT INTO [sma_MST_IndvContacts]
	(
	[cinsPrefix]
   ,[cinsSuffix]
   ,[cinsFirstName]
   ,[cinsMiddleName]
   ,[cinsLastName]
   ,[cinsHomePhone]
   ,[cinsWorkPhone]
   ,[cinsSSNNo]
   ,[cindBirthDate]
   ,[cindDateOfDeath]
   ,[cinnGender]
   ,[cinsMobile]
   ,[cinsComments]
   ,[cinnContactCtg]
   ,[cinnContactTypeID]
   ,[cinnContactSubCtgID]
   ,[cinnRecUserID]
   ,[cindDtCreated]
   ,[cinbStatus]
   ,[cinbPreventMailing]
   ,[cinsNickName]
   ,[cinsPrimaryLanguage]
   ,[cinsOtherLanguage]
   ,[cinnRace]
   ,[saga]
   ,[saga_db]
   ,[saga_ref]
	)
	SELECT
		NULL											AS [cinsPrefix]
	   ,NULL											AS [cinsSuffix]
	   ,left(c.[First name],100)								AS [cinsFirstName]
	   ,NULL											AS [cinsMiddleName]
	   ,left(c.[Last name],100)									AS [cinsLastName]
	   ,LEFT(c.[Phone number - Home], 20)				AS [cinsHomePhone]
	   ,LEFT(c.[Phone number - Work], 20)				AS [cinsWorkPhone]
	   ,NULL											AS [cinsSSNNo]
	   ,CASE
			WHEN Dates LIKE '%birthday%'
				THEN CASE
						WHEN TRY_CAST(SUBSTRING(Dates, CHARINDEX(': ', Dates) + 2, LEN(Dates)) AS DATE)
							BETWEEN '1900-01-01' AND '2079-12-31'
							THEN TRY_CAST(SUBSTRING(Dates, CHARINDEX(': ', Dates) + 2, LEN(Dates)) AS DATE)
						ELSE GETDATE()
					END
			ELSE NULL
		END												AS [cindBirthDate]
	   ,CASE
			WHEN Dates LIKE '%Date of death:%'
				THEN CASE
						WHEN TRY_CAST(SUBSTRING(Dates, CHARINDEX('Date of death: ', Dates) + 15, LEN(Dates)) AS DATE)
							BETWEEN '1900-01-01' AND '2079-12-31'
							THEN TRY_CAST(SUBSTRING(Dates, CHARINDEX('Date of death: ', Dates) + 15, LEN(Dates)) AS DATE)
						ELSE NULL
					END
			ELSE NULL
		END												AS [cindDateOfDeath]
	   ,NULL											AS [cinnGender]
		--case
		--	when N.[sex]='M' then 1
		--	when N.[sex]='F' then 2
		--		else 0
		--	end										as [cinnGender],
	   ,LEFT(c.[Phone number - Mobile], 20)				AS [cinsMobile]
	   ,REPLACE(c.Background, '|', CHAR(13) + CHAR(10)) AS [cinsComments]
	   ,1												AS [cinnContactCtg]
	   ,(
			SELECT
				octnOrigContactTypeID
			FROM [sma_MST_OriginalContactTypes]
			WHERE octsDscrptn = 'General'
				AND octnContactCtgID = 1
		)												
		AS [cinnContactTypeID]
	   ,(
			SELECT
				cscnContactSubCtgID
			FROM [sma_MST_ContactSubCategory]
			WHERE cscsDscrptn = 'Adult'
		)												
		AS cinnContactSubCtgID
	   ,368												AS cinnRecUserID
	   ,GETDATE()										AS cindDtCreated
	   ,1												AS [cinbStatus]			-- Hardcode Status as ACTIVE 
	   ,0												AS [cinbPreventMailing]
	   ,NULL											AS [cinsNickName]
	   ,NULL											AS [cinsPrimaryLanguage]
	   ,NULL											AS [cinsOtherLanguage]
	   ,NULL											AS [cinnrace]
	   ,convert(varchar,c.[Highrise ID])									AS saga
	   ,'HR'										AS [saga_db]
	   ,'contacts_csv'										AS [saga_ref]
	FROM Baldante..contacts_csv c
	WHERE c.[Company or Person] = 'Person'
GO

---------------------------------------
-- Org. Contacts
---------------------------------------
INSERT INTO [sma_MST_OrgContacts] (
		[consName],
		[consWorkPhone],
		[consComments],
		[connContactCtg],
		[connContactTypeID],	
		[connRecUserID],		
		[condDtCreated],
		[conbStatus],			
		[saga],
		[saga_db],
		[saga_ref]
	)
SELECT 
    c.name	as [consName]
    ,left(c.[phone number - work],20) as [consWorkPhone]
    ,REPLACE(c.background, '|', char(13) + char(10))				as [consComments]
    ,2											as [connContactCtg]
    ,(
		select octnOrigContactTypeID
		FROM .[sma_MST_OriginalContactTypes]
		where octsDscrptn='General' and octnContactCtgID=2
	)											as [connContactTypeID]
    ,368											as [connRecUserID]
    ,getdate()									as [condDtCreated]
    ,1											as [conbStatus]	-- Hardcode Status as ACTIVE
    ,convert(varchar,c.[Highrise ID])								as [saga]	-- remember the [names].[names_id] number
	,'HR' AS [saga_db]
	,'contacts_csv' AS [saga_ref]	
FROM Baldante..contacts_csv c
	WHERE c.[Company or Person] = 'Company'
GO


---------------------------------------
-- INDIVIDUAL CONTACT CARD FOR STAFF
---------------------------------------
--INSERT INTO [sma_MST_IndvContacts] (
--		[cinsPrefix],
--		[cinsSuffix],
--		[cinsFirstName],
--		[cinsmiddleName],
--		[cinsLastName],
--		[cinsHomePhone],
--		[cinsWorkPhone],
--		[cinsSSNNo],
--		[cindBirthDate],
--		[cindDateOfDeath],
--		[cinnGender],
--		[cinsMobile],
--		[cinsComments],
--		[cinnContactCtg],
--		[cinnContactTypeID],	
--		[cinnRecUserID],		
--		[cindDtCreated],
--		[cinbStatus],			
--		[cinbPreventMailing],
--		[cinsNickName],
--		[saga],
--		[cinsGrade],				-- remember the [staff_code]
--		[saga_db],
--		[saga_ref]
--)
--SELECT 
--		iu.Prefix							as [cinsPrefix],
--		iu.Suffix							as [cinsSuffix],
--		--left(isnull(first_name,dbo.get_firstword(full_name)),30)	as [cinsFirstName],
--		SAFirst								as [cinsFirstName],
--		SAMiddle							as [cinsmiddleName],
--		--left(isnull(last_name,dbo.get_lastword(full_name)),40)	    as [cinsLastName],
--		SALast								as [cinsLastName],
--		NULL								as [cinsHomePhone],
--		left(s.phone_number,20)				as [cinsWorkPhone],
--		NULL								as [cinsSSNNo],
--		NULL								as [cindBirthDate],
--		NULL								as [cindDateOfDeath],
--		case s.[sex] 
--			when 'M' then 1
--			when 'F' then 2
--			else 0
--		end									as [cinnGender],
--		left(s.mobil_phone,20)   			as [cinsMobile],
--		NULL								as [cinsComments],
--		1									as [cinnContactCtg],
--		(
--			select octnOrigContactTypeID
--			from sma_MST_OriginalContactTypes
--			where octsDscrptn='General' and octnContactCtgID=1
--		)									as [cinnContactTypeID],
--		368, 
--		getdate(),
--		1									as [cinbStatus],
--		0,
--		convert(varchar(15),s.full_name)	as [cinsNickName],
--		NULL								as [saga],
--		staff_code							as [cinsGrade], -- Remember it to go to sma_MST_Users
--			'ND' AS [saga_db],
--	'implementation_users' AS [saga_ref]	
----Select *
--FROM [implementation_users] iu
----LEFT JOIN [sma_MST_IndvContacts] ind on iu.StaffCode = ind.cinsgrade
--LEFT JOIN [sma_MST_IndvContacts] ind on iu.SAContactID = ind.cinnContactID
--LEFT JOIN JoelBieberNeedles..[staff] s on s.staff_code = iu.staffcode
--WHERE cinncontactid IS NULL
--and SALoginID <> 'aadmin'
--GO

-----------------------------------------
---- EMAILS FOR STAFF
-----------------------------------------
--INSERT INTO [sma_MST_EmailWebsite]
--  ( [cewnContactCtgID],[cewnContactID],[cewsEmailWebsiteFlag],[cewsEmailWebSite],[cewbDefault],[cewnRecUserID],[cewdDtCreated],[cewnModifyUserID],[cewdDtModified],[cewnLevelNo],[saga] )
--SELECT 
--		C.cinnContactCtg	as cewnContactCtgID,
--		C.cinnContactID		as cewnContactID,
--		'E'					as cewsEmailWebsiteFlag,
--		s.email				as cewsEmailWebSite,
--		null				as cewbDefault,
--		368					as cewnRecUserID,
--		getdate()			as cewdDtCreated,
--		368					as cewnModifyUserID,
--		getdate()			as cewdDtModified,
--		null,
--		1					as saga -- indicate email
--FROM implementation_users iu
--JOIN JoelBieberNeedles..staff s on s.staff_code = iu.staffcode
--JOIN [sma_MST_IndvContacts] C on C.cinsgrade = iu.staffcode
--WHERE isnull(email,'') <> ''
--GO

----------------------------------------------------
-- INSERT AADMIN USER IF DOES NOT ALREADY EXIST
----------------------------------------------------
IF (
	select count(*)
	from sma_mst_users
	where usrsloginid = 'aadmin'
	) = 0
BEGIN
	SET IDENTITY_INSERT sma_mst_users ON

	INSERT INTO [sma_MST_Users]
	(
		usrnuserid
		,[usrnContactID]
		,[usrsLoginID]
		,[usrsPassword]
		,[usrsBackColor]
		,[usrsReadBackColor]
		,[usrsEvenBackColor]
		,[usrsOddBackColor]
		,[usrnRoleID]
		,[usrdLoginDate]
		,[usrdLogOffDate]
		,[usrnUserLevel]
		,[usrsWorkstation]
		,[usrnPortno]
		,[usrbLoggedIn]
		,[usrbCaseLevelRights]
		,[usrbCaseLevelFilters]
		,[usrnUnsuccesfulLoginCount]
		,[usrnRecUserID]
		,[usrdDtCreated]
		,[usrnModifyUserID]
		,[usrdDtModified]
		,[usrnLevelNo]
		,[usrsCaseCloseColor]
		,[usrnDocAssembly]
		,[usrnAdmin]
		,[usrnIsLocked]
		,[usrbActiveState]
	)
	SELECT DISTINCT
		368							as usrnuserid
		,(
			SELECT
				TOP 1
				cinnContactID
			FROM
				dbo.sma_MST_IndvContacts
			WHERE
				cinslastname = 'Unassigned'
				AND cinsfirstname = 'Staff'
		)							as usrnContactID
		,'aadmin'					as usrsLoginID
		,'2/'				 as usrsPassword
		,null						as [usrsBackColor]
		,null						as [usrsReadBackColor]
		,null						as [usrsEvenBackColor]
		,null						as [usrsOddBackColor]
		,33							as [usrnRoleID]
		,null						as [usrdLoginDate]
		,null						as [usrdLogOffDate]
		,null						as [usrnUserLevel]
		,null						as [usrsWorkstation]
		,null						as [usrnPortno]
		,null						as [usrbLoggedIn]
		,null						as [usrbCaseLevelRights]
		,null						as [usrbCaseLevelFilters]
		,null						as [usrnUnsuccesfulLoginCount]
		,1							as [usrnRecUserID]
		,GETDATE()					as [usrdDtCreated]
		,null						as [usrnModifyUserID]
		,null						as [usrdDtModified]
		,null						as [usrnLevelNo]
		,null						as [usrsCaseCloseColor]
		,null						as [usrnDocAssembly]
		,null						as [usrnAdmin]
		,null						as [usrnIsLocked]
		,1							as [usrbActiveState]
	SET IDENTITY_INSERT sma_mst_users OFF
END

----------------------------------------------------
-- INSERT CONVERSION USER IF DOES NOT ALREADY EXIST
----------------------------------------------------
IF (
	select count(*)
	from sma_mst_users
	where usrsloginid = 'conversion'
	) = 0
BEGIN
	INSERT INTO [sma_MST_Users]
	(
		[usrnContactID]
		,[usrsLoginID]
		,[usrsPassword]
		,[usrsBackColor]
		,[usrsReadBackColor]
		,[usrsEvenBackColor]
		,[usrsOddBackColor]
		,[usrnRoleID]
		,[usrdLoginDate]
		,[usrdLogOffDate]
		,[usrnUserLevel]
		,[usrsWorkstation]
		,[usrnPortno]
		,[usrbLoggedIn]
		,[usrbCaseLevelRights]
		,[usrbCaseLevelFilters]
		,[usrnUnsuccesfulLoginCount]
		,[usrnRecUserID]
		,[usrdDtCreated]
		,[usrnModifyUserID]
		,[usrdDtModified]
		,[usrnLevelNo]
		,[usrsCaseCloseColor]
		,[usrnDocAssembly]
		,[usrnAdmin]
		,[usrnIsLocked]
		,[usrbActiveState]
	)
	SELECT DISTINCT
		(
			SELECT
				TOP 1
				cinnContactID
			FROM
				dbo.sma_MST_IndvContacts
			WHERE
				cinslastname = 'Unassigned'
				AND cinsfirstname = 'Staff'
		)							as usrnContactID
		,'conversion'				as usrsLoginID
		,'pass'				 		as usrsPassword
		,null						as [usrsBackColor]
		,null						as [usrsReadBackColor]
		,null						as [usrsEvenBackColor]
		,null						as [usrsOddBackColor]
		,33							as [usrnRoleID]
		,null						as [usrdLoginDate]
		,null						as [usrdLogOffDate]
		,null						as [usrnUserLevel]
		,null						as [usrsWorkstation]
		,null						as [usrnPortno]
		,null						as [usrbLoggedIn]
		,null						as [usrbCaseLevelRights]
		,null						as [usrbCaseLevelFilters]
		,null						as [usrnUnsuccesfulLoginCount]
		,1							as [usrnRecUserID]
		,GETDATE()					as [usrdDtCreated]
		,null						as [usrnModifyUserID]
		,null						as [usrdDtModified]
		,null						as [usrnLevelNo]
		,null						as [usrsCaseCloseColor]
		,null						as [usrnDocAssembly]
		,null						as [usrnAdmin]
		,null						as [usrnIsLocked]
		,1							as [usrbActiveState]
END

------------------------------------------------------
---- Add [saga] to [sma_MST_Users] if it does not exist
------------------------------------------------------
--IF NOT EXISTS (SELECT * FROM sys.columns WHERE Name = N'saga' AND Object_ID = Object_ID(N'sma_MST_Users'))
--BEGIN
--    ALTER TABLE [sma_MST_Users] ADD [saga] [varchar](20) NULL; 
--END
--GO

-----------------------
---- INSERT USERS
-----------------------

-- -- Insert data into sma_MST_Users table from implementation_users table
--INSERT INTO [sma_MST_Users] (
--    [usrnContactID],         -- Contact ID
--    [usrsLoginID],           -- Login ID
--    [usrsPassword],          -- Password
--    [usrsBackColor],         -- Background Color
--    [usrsReadBackColor],     -- Read Background Color
--    [usrsEvenBackColor],     -- Even Background Color
--    [usrsOddBackColor],      -- Odd Background Color
--    [usrnRoleID],            -- Role ID
--    [usrdLoginDate],         -- Login Date
--    [usrdLogOffDate],        -- Log Off Date
--    [usrnUserLevel],         -- User Level
--    [usrsWorkstation],       -- Workstation
--    [usrnPortno],            -- Port Number
--    [usrbLoggedIn],          -- Logged In
--    [usrbCaseLevelRights],   -- Case Level Rights
--    [usrbCaseLevelFilters],  -- Case Level Filters
--    [usrnUnsuccesfulLoginCount], -- Unsuccessful Login Count
--    [usrnRecUserID],         -- Record User ID
--    [usrdDtCreated],         -- Date Created
--    [usrnModifyUserID],      -- Modify User ID
--    [usrdDtModified],        -- Date Modified
--    [usrnLevelNo],           -- Level Number
--    [usrsCaseCloseColor],    -- Case Close Color
--    [usrnDocAssembly],       -- Document Assembly
--    [usrnAdmin],             -- Admin
--    [usrnIsLocked],          -- Is Locked
--    [saga],                  -- Staff Code
--    [usrbActiveState],       -- Active State
--    [usrbIsShowInSystem]     -- Show In System
--)
--SELECT 
--    INDV.cinncontactid					 -- [usrnContactID]
--    ,STF.SAloginID                      -- [usrsLoginID]
--    ,'#'								 -- [usrsPassword]
--    ,NULL                               -- [usrsBackColor]
--    ,NULL                               -- [usrsReadBackColor]
--    ,NULL                               -- [usrsEvenBackColor]
--    ,NULL                               -- [usrsOddBackColor]
--    ,33                                 -- [usrnRoleID]
--    ,NULL                               -- [usrdLoginDate]
--    ,NULL                               -- [usrdLogOffDate]
--    ,NULL                               -- [usrnUserLevel]
--    ,NULL                               -- [usrsWorkstation]
--    ,NULL                               -- [usrnPortno]
--    ,NULL                               -- [usrbLoggedIn]
--    ,NULL                               -- [usrbCaseLevelRights]
--    ,NULL                               -- [usrbCaseLevelFilters]
--    ,NULL                               -- [usrnUnsuccesfulLoginCount]
--    ,1                                  -- [usrnRecUserID]
--    ,GETDATE()                          -- [usrdDtCreated]
--    ,NULL                               -- [usrnModifyUserID]
--    ,NULL                               -- [usrdDtModified]
--    ,NULL                               -- [usrnLevelNo]
--    ,NULL                               -- [usrsCaseCloseColor]
--    ,NULL                               -- [usrnDocAssembly]
--    ,NULL                               -- [usrnAdmin]
--    ,NULL                               -- [usrnIsLocked]
--    ,CONVERT(VARCHAR(20), STF.staffcode) -- [saga]
--    ,0									as [usrbActiveState]
--	,1									as [usrbIsShowInSystem]
--FROM implementation_users STF
--JOIN sma_MST_IndvContacts INDV
--	ON INDV.cinsGrade = STF.staffcode
--LEFT JOIN [sma_MST_Users] u
--	ON u.saga = CONVERT(VARCHAR(20), STF.staffcode)
--WHERE u.usrsLoginID IS NULL
--GO

-----------------------------------------------END ADD USERS-----------------------------------------------

--DECLARE @UserID int

--DECLARE staff_cursor CURSOR FAST_FORWARD FOR SELECT usrnuserid from sma_mst_users

--OPEN staff_cursor 

--FETCH NEXT FROM staff_cursor INTO @UserID

--SET NOCOUNT ON;
--WHILE @@FETCH_STATUS = 0
--BEGIN
--    -- Print the fetched UserID for debugging
--    PRINT 'Fetched UserID: ' + CAST(@UserID AS VARCHAR);

--    -- Check if @UserID is NULL
--    IF @UserID IS NOT NULL
--    BEGIN
--        PRINT 'Inserting for UserID: ' + CAST(@UserID AS VARCHAR);

--        INSERT INTO sma_TRN_CaseBrowseSettings
--        (
--            cbsnColumnID
--            ,cbsnUserID
--            ,cbssCaption
--            ,cbsbVisible
--            ,cbsnWidth
--            ,cbsnOrder
--            ,cbsnRecUserID
--            ,cbsdDtCreated
--            ,cbsn_StyleName
--        )
--        SELECT DISTINCT
--            cbcnColumnID
--            ,@UserID
--            ,cbcscolumnname
--            ,'True'
--            ,200
--            ,cbcnDefaultOrder
--            ,@UserID
--            ,GETDATE()
--            ,'Office2007Blue'
--        FROM [sma_MST_CaseBrowseColumns]
--        WHERE cbcnColumnID NOT IN (1, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 33);
--    END
--    ELSE
--    BEGIN
--        -- Log the NULL @UserID occurrence
--        PRINT 'NULL UserID encountered. Skipping insert.';
--    END
    
--    FETCH NEXT FROM staff_cursor INTO @UserID;
--END

--CLOSE staff_cursor 
--DEALLOCATE staff_cursor



------ Appendix ----
--INSERT INTO Account_UsersInRoles ( user_id,role_id)
--SELECT usrnUserID as user_id,2 as role_id 
--FROM sma_MST_Users

--update sma_MST_Users set usrbActiveState=1
--where usrsLoginID='aadmin'

--UPDATE Account_UsersInRoles 
--SET role_id=1 
--WHERE user_id=368 


