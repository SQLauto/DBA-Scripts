/**************************************************************************
** CREATED BY:   Bulent Gucuk
** CREATED DATE: 2019.02.26
** CREATED FOR:  Disabling the jobs before maintenance
** NOTES:	The script depends on the DBA database and table named dbo.JobsEnabled
**			If you get an error make sure to alter the script to accomandate the
**			database and table name, when executed it will log all the enable jobs
**			and will disable the jobs.  Run it only once, truncate command will truncate
**			the table and you will lose the list of jobs enabled before
***************************************************************************/
USE msdb; 
GO
DECLARE @RowId SMALLINT = 1
	, @MaxRowId SMALLINT
	, @job_name SYSNAME
	, @enablejob TINYINT = 0;  -- 0 = disable job 1 = Enable job

TRUNCATE TABLE DBA.dbo.JobsEnabled;
INSERT INTO DBA.dbo.JobsEnabled
SELECT
	ROW_NUMBER () OVER(ORDER BY J.NAME) AS RowId
	, j.name
	, J.job_id
	, J.enabled
--INTO DBA.dbo.JobsEnabled
FROM	dbo.sysjobs AS j
WHERE	enabled = 1;

SELECT @MaxRowId = @@ROWCOUNT;

SELECT @MaxRowId, * from DBA.DBO.JobsEnabled;

WHILE @RowId <= @MaxRowId
	BEGIN
		SELECT	@job_name = name
		FROM	DBA.dbo.JobsEnabled
		WHERE	RowId = @RowId;

		EXEC msdb.dbo.sp_update_job
			@job_name = @job_name,
			@enabled = @enablejob;

		SELECT @RowId = @RowId + 1;
	END
