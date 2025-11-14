/**
 * @summary
 * Creates multiple identified files in batch for a scan operation
 *
 * @procedure spIdentifiedFileBatchCreate
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - POST /api/v1/internal/scan-operation/:id/identified-files
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 *
 * @param {INT} idScanOperation
 *   - Required: Yes
 *   - Description: Scan operation identifier
 *
 * @param {NVARCHAR(MAX)} filesJson
 *   - Required: Yes
 *   - Description: JSON array of identified files
 *
 * @testScenarios
 * - Valid batch creation with multiple files
 * - JSON parsing validation
 * - Scan operation existence validation
 * - Account isolation validation
 */
CREATE OR ALTER PROCEDURE [functional].[spIdentifiedFileBatchCreate]
  @idAccount INTEGER,
  @idScanOperation INTEGER,
  @filesJson NVARCHAR(MAX)
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

  IF (@filesJson IS NULL OR LTRIM(RTRIM(@filesJson)) = '')
  BEGIN
    ;THROW 51000, 'filesJsonRequired', 1;
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
    /**
     * @rule {db-json-parsing} Parse JSON array into table variable
     */
    INSERT INTO [functional].[identifiedFile] (
      [idAccount],
      [idScanOperation],
      [filePath],
      [fileName],
      [fileExtension],
      [fileSizeBytes],
      [fileModifiedDate],
      [identificationCriteria]
    )
    SELECT
      @idAccount,
      @idScanOperation,
      JSON_VALUE([value], '$.filePath'),
      JSON_VALUE([value], '$.fileName'),
      JSON_VALUE([value], '$.fileExtension'),
      CAST(JSON_VALUE([value], '$.fileSizeBytes') AS BIGINT),
      CAST(JSON_VALUE([value], '$.fileModifiedDate') AS DATETIME2),
      JSON_VALUE([value], '$.identificationCriteria')
    FROM OPENJSON(@filesJson);

    /**
     * @output {Success, 1, 1}
     * @column {INT} filesCreated - Number of files created
     */
    SELECT @@ROWCOUNT AS [filesCreated];
  END TRY
  BEGIN CATCH
    ;THROW;
  END CATCH;
END;
GO