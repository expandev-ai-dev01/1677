/**
 * @summary
 * Updates an existing scan configuration
 *
 * @procedure spScanConfigurationUpdate
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - PUT /api/v1/internal/scan-configuration/:id
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
 *   - Description: Configuration identifier
 *
 * @param {NVARCHAR(100)} name
 *   - Required: Yes
 *   - Description: Configuration name
 *
 * @param {NVARCHAR(500)} directoryPath
 *   - Required: Yes
 *   - Description: Directory path to scan
 *
 * @param {BIT} includeSubdirectories
 *   - Required: Yes
 *   - Description: Include subdirectories in scan
 *
 * @param {NVARCHAR(MAX)} temporaryExtensions
 *   - Required: Yes
 *   - Description: JSON array of file extensions
 *
 * @param {NVARCHAR(MAX)} namingPatterns
 *   - Required: Yes
 *   - Description: JSON array of naming patterns
 *
 * @param {INT} minimumAgeDays
 *   - Required: Yes
 *   - Description: Minimum file age in days
 *
 * @param {BIGINT} minimumSizeBytes
 *   - Required: Yes
 *   - Description: Minimum file size in bytes
 *
 * @param {BIT} includeSystemFiles
 *   - Required: Yes
 *   - Description: Include system files in scan
 *
 * @testScenarios
 * - Valid update with all parameters
 * - Not found error for non-existent ID
 * - Duplicate name validation
 * - Account isolation validation
 */
CREATE OR ALTER PROCEDURE [functional].[spScanConfigurationUpdate]
  @idAccount INTEGER,
  @idUser INTEGER,
  @idScanConfiguration INTEGER,
  @name NVARCHAR(100),
  @directoryPath NVARCHAR(500),
  @includeSubdirectories BIT,
  @temporaryExtensions NVARCHAR(MAX),
  @namingPatterns NVARCHAR(MAX),
  @minimumAgeDays INTEGER,
  @minimumSizeBytes BIGINT,
  @includeSystemFiles BIT
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

  IF (@name IS NULL OR LTRIM(RTRIM(@name)) = '')
  BEGIN
    ;THROW 51000, 'nameRequired', 1;
  END;

  IF (@directoryPath IS NULL OR LTRIM(RTRIM(@directoryPath)) = '')
  BEGIN
    ;THROW 51000, 'directoryPathRequired', 1;
  END;

  /**
   * @validation Business rule validation
   * @throw {invalidValue}
   */
  IF (@minimumAgeDays < 0)
  BEGIN
    ;THROW 51000, 'minimumAgeDaysMustBeEqualOrGreaterZero', 1;
  END;

  IF (@minimumSizeBytes < 0)
  BEGIN
    ;THROW 51000, 'minimumSizeBytesMustBeEqualOrGreaterZero', 1;
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

  /**
   * @validation Duplicate name check
   * @throw {duplicateName}
   */
  IF EXISTS (
    SELECT 1
    FROM [functional].[scanConfiguration] scnCfg
    WHERE scnCfg.[idAccount] = @idAccount
      AND scnCfg.[name] = @name
      AND scnCfg.[idScanConfiguration] <> @idScanConfiguration
      AND scnCfg.[deleted] = 0
  )
  BEGIN
    ;THROW 51000, 'configurationNameAlreadyExists', 1;
  END;

  BEGIN TRY
    /**
     * @rule {db-multi-tenancy} Update with account isolation
     */
    UPDATE [functional].[scanConfiguration]
    SET
      [name] = @name,
      [directoryPath] = @directoryPath,
      [includeSubdirectories] = @includeSubdirectories,
      [temporaryExtensions] = @temporaryExtensions,
      [namingPatterns] = @namingPatterns,
      [minimumAgeDays] = @minimumAgeDays,
      [minimumSizeBytes] = @minimumSizeBytes,
      [includeSystemFiles] = @includeSystemFiles,
      [dateModified] = GETUTCDATE()
    WHERE [idScanConfiguration] = @idScanConfiguration
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