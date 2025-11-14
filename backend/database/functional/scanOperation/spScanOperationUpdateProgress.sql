/**
 * @summary
 * Updates scan operation progress and statistics
 *
 * @procedure spScanOperationUpdateProgress
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - PATCH /api/v1/internal/scan-operation/:id/progress
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 *
 * @param {INT} idScanOperation
 *   - Required: Yes
 *   - Description: Operation identifier
 *
 * @param {INT} status
 *   - Required: Yes
 *   - Description: Operation status (0=Not Started, 1=In Progress, 2=Completed, 3=Error)
 *
 * @param {INT} progress
 *   - Required: Yes
 *   - Description: Progress percentage (0-100)
 *
 * @param {INT} totalFilesAnalyzed
 *   - Required: Yes
 *   - Description: Total files analyzed
 *
 * @param {INT} totalFilesIdentified
 *   - Required: Yes
 *   - Description: Total temporary files identified
 *
 * @param {BIGINT} potentialSpaceBytes
 *   - Required: Yes
 *   - Description: Potential space to free in bytes
 *
 * @testScenarios
 * - Valid progress update
 * - Status transition validation
 * - Progress percentage validation
 * - Account isolation validation
 */
CREATE OR ALTER PROCEDURE [functional].[spScanOperationUpdateProgress]
  @idAccount INTEGER,
  @idScanOperation INTEGER,
  @status INTEGER,
  @progress INTEGER,
  @totalFilesAnalyzed INTEGER,
  @totalFilesIdentified INTEGER,
  @potentialSpaceBytes BIGINT
AS
BEGIN
  SET NOCOUNT ON;

  /**
   * @validation Required parameter validation
   * @throw {parameterRequired}
   */
  IF (@idAccount IS NULL)
  BEGIN
    ;THROW 51000, 'idAccountRequired', 1;
  END;

  IF (@idScanOperation IS NULL)
  BEGIN
    ;THROW 51000, 'idScanOperationRequired', 1;
  END;

  /**
   * @validation Business rule validation
   * @throw {invalidValue}
   */
  IF (@status < 0 OR @status > 3)
  BEGIN
    ;THROW 51000, 'invalidStatus', 1;
  END;

  IF (@progress < 0 OR @progress > 100)
  BEGIN
    ;THROW 51000, 'progressMustBeBetween0And100', 1;
  END;

  /**
   * @validation Data consistency validation
   * @throw {notFound}
   */
  IF NOT EXISTS (
    SELECT 1
    FROM [functional].[scanOperation] scnOpr
    WHERE scnOpr.[idScanOperation] = @idScanOperation
      AND scnOpr.[idAccount] = @idAccount
  )
  BEGIN
    ;THROW 51000, 'scanOperationDoesntExist', 1;
  END;

  BEGIN TRY
    DECLARE @dateCompleted DATETIME2 = NULL;

    /**
     * @rule {fn-operation-completion} Set completion date when status is completed or error
     */
    IF (@status IN (2, 3))
    BEGIN
      SET @dateCompleted = GETUTCDATE();
    END;

    /**
     * @rule {db-multi-tenancy} Update with account isolation
     */
    UPDATE [functional].[scanOperation]
    SET
      [status] = @status,
      [progress] = @progress,
      [totalFilesAnalyzed] = @totalFilesAnalyzed,
      [totalFilesIdentified] = @totalFilesIdentified,
      [potentialSpaceBytes] = @potentialSpaceBytes,
      [dateCompleted] = @dateCompleted
    WHERE [idScanOperation] = @idScanOperation
      AND [idAccount] = @idAccount;

    /**
     * @output {Success, 1, 1}
     * @column {BIT} success - Operation success indicator
     */
    SELECT 1 AS [success];
  END TRY
  BEGIN CATCH
    ;THROW;
  END CATCH;
END;
GO