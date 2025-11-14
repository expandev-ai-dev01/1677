/**
 * @summary
 * Creates a new scan operation to analyze files in a directory
 *
 * @procedure spScanOperationCreate
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - POST /api/v1/internal/scan-operation
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 *
 * @param {INT} idUser
 *   - Required: Yes
 *   - Description: User identifier for audit
 *
 * @param {INT} idScanConfiguration
 *   - Required: Yes
 *   - Description: Configuration to use for scan
 *
 * @param {NVARCHAR(500)} directoryPath
 *   - Required: Yes
 *   - Description: Directory path to scan
 *
 * @returns {INT} idScanOperation - Created operation identifier
 *
 * @testScenarios
 * - Valid creation with existing configuration
 * - Configuration not found error
 * - Account isolation validation
 */
CREATE OR ALTER PROCEDURE [functional].[spScanOperationCreate]
  @idAccount INTEGER,
  @idUser INTEGER,
  @idScanConfiguration INTEGER,
  @directoryPath NVARCHAR(500)
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

  IF (@idUser IS NULL)
  BEGIN
    ;THROW 51000, 'idUserRequired', 1;
  END;

  IF (@idScanConfiguration IS NULL)
  BEGIN
    ;THROW 51000, 'idScanConfigurationRequired', 1;
  END;

  IF (@directoryPath IS NULL OR LTRIM(RTRIM(@directoryPath)) = '')
  BEGIN
    ;THROW 51000, 'directoryPathRequired', 1;
  END;

  /**
   * @validation Data consistency validation
   * @throw {notFound}
   */
  IF NOT EXISTS (
    SELECT 1
    FROM [functional].[scanConfiguration] scnCfg
    WHERE scnCfg.[idScanConfiguration] = @idScanConfiguration
      AND scnCfg.[idAccount] = @idAccount
      AND scnCfg.[deleted] = 0
  )
  BEGIN
    ;THROW 51000, 'scanConfigurationDoesntExist', 1;
  END;

  BEGIN TRY
    DECLARE @idScanOperation INTEGER;

    /**
     * @rule {db-multi-tenancy} Insert with account isolation
     */
    INSERT INTO [functional].[scanOperation] (
      [idAccount],
      [idScanConfiguration],
      [directoryPath],
      [status],
      [progress]
    )
    VALUES (
      @idAccount,
      @idScanConfiguration,
      @directoryPath,
      0,
      0
    );

    SET @idScanOperation = SCOPE_IDENTITY();

    /**
     * @output {ScanOperation, 1, 1}
     * @column {INT} idScanOperation - Operation identifier
     */
    SELECT @idScanOperation AS [idScanOperation];
  END TRY
  BEGIN CATCH
    ;THROW;
  END CATCH;
END;
GO