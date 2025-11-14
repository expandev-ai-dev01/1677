/**
 * @summary
 * Retrieves removal operation details with statistics
 *
 * @procedure spRemovalOperationGet
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/internal/removal-operation/:id
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 *
 * @param {INT} idRemovalOperation
 *   - Required: Yes
 *   - Description: Operation identifier
 *
 * @returns {RECORDSET} Removal operation details and file lists
 *
 * @testScenarios
 * - Valid retrieval with existing ID
 * - Not found error for non-existent ID
 * - Account isolation validation
 */
CREATE OR ALTER PROCEDURE [functional].[spRemovalOperationGet]
  @idAccount INTEGER,
  @idRemovalOperation INTEGER
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

  IF (@idRemovalOperation IS NULL)
  BEGIN
    ;THROW 51000, 'idRemovalOperationRequired', 1;
  END;

  /**
   * @validation Data consistency validation
   * @throw {notFound}
   */
  IF NOT EXISTS (
    SELECT 1
    FROM [functional].[removalOperation] rmvOpr
    WHERE rmvOpr.[idRemovalOperation] = @idRemovalOperation
      AND rmvOpr.[idAccount] = @idAccount
  )
  BEGIN
    ;THROW 51000, 'removalOperationDoesntExist', 1;
  END;

  /**
   * @output {RemovalOperationDetails, 1, n}
   * @column {INT} idRemovalOperation - Operation identifier
   * @column {INT} idScanOperation - Related scan operation
   * @column {INT} removalMode - Removal mode
   * @column {INT} status - Operation status
   * @column {INT} progress - Progress percentage
   * @column {INT} totalFilesRemoved - Total files removed
   * @column {INT} totalFilesWithError - Total files with errors
   * @column {BIGINT} spaceFreedBytes - Space freed in bytes
   * @column {DATETIME2} dateStarted - Start date
   * @column {DATETIME2} dateCompleted - Completion date
   */
  SELECT
    rmvOpr.[idRemovalOperation],
    rmvOpr.[idScanOperation],
    rmvOpr.[removalMode],
    rmvOpr.[status],
    rmvOpr.[progress],
    rmvOpr.[totalFilesRemoved],
    rmvOpr.[totalFilesWithError],
    rmvOpr.[spaceFreedBytes],
    rmvOpr.[dateStarted],
    rmvOpr.[dateCompleted]
  FROM [functional].[removalOperation] rmvOpr
  WHERE rmvOpr.[idRemovalOperation] = @idRemovalOperation
    AND rmvOpr.[idAccount] = @idAccount;

  /**
   * @output {RemovedFilesList, n, n}
   * @column {INT} idRemovedFile - Removed file identifier
   * @column {NVARCHAR} filePath - File path
   * @column {BIGINT} fileSizeBytes - File size
   * @column {BIT} success - Removal success status
   * @column {NVARCHAR} errorMessage - Error message if failed
   * @column {DATETIME2} dateRemoved - Removal date
   */
  SELECT
    rmvFil.[idRemovedFile],
    rmvFil.[filePath],
    rmvFil.[fileSizeBytes],
    rmvFil.[success],
    rmvFil.[errorMessage],
    rmvFil.[dateRemoved]
  FROM [functional].[removedFile] rmvFil
  WHERE rmvFil.[idAccount] = @idAccount
    AND rmvFil.[idRemovalOperation] = @idRemovalOperation
  ORDER BY rmvFil.[dateRemoved];
END;
GO