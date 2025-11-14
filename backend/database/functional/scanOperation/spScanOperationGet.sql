/**
 * @summary
 * Retrieves scan operation details with statistics
 *
 * @procedure spScanOperationGet
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/internal/scan-operation/:id
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
 * @returns {RECORDSET} Scan operation details
 *
 * @testScenarios
 * - Valid retrieval with existing ID
 * - Not found error for non-existent ID
 * - Account isolation validation
 */
CREATE OR ALTER PROCEDURE [functional].[spScanOperationGet]
  @idAccount INTEGER,
  @idScanOperation INTEGER
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

  /**
   * @output {ScanOperationDetails, 1, n}
   * @column {INT} idScanOperation - Operation identifier
   * @column {INT} idScanConfiguration - Configuration identifier
   * @column {NVARCHAR} directoryPath - Scanned directory path
   * @column {INT} status - Operation status
   * @column {INT} progress - Progress percentage
   * @column {INT} totalFilesAnalyzed - Total files analyzed
   * @column {INT} totalFilesIdentified - Total temporary files found
   * @column {BIGINT} potentialSpaceBytes - Potential space to free
   * @column {DATETIME2} dateStarted - Start date
   * @column {DATETIME2} dateCompleted - Completion date
   */
  SELECT
    scnOpr.[idScanOperation],
    scnOpr.[idScanConfiguration],
    scnOpr.[directoryPath],
    scnOpr.[status],
    scnOpr.[progress],
    scnOpr.[totalFilesAnalyzed],
    scnOpr.[totalFilesIdentified],
    scnOpr.[potentialSpaceBytes],
    scnOpr.[dateStarted],
    scnOpr.[dateCompleted]
  FROM [functional].[scanOperation] scnOpr
  WHERE scnOpr.[idScanOperation] = @idScanOperation
    AND scnOpr.[idAccount] = @idAccount;
END;
GO