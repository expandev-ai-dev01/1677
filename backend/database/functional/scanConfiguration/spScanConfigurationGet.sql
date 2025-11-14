/**
 * @summary
 * Retrieves a specific scan configuration by ID
 *
 * @procedure spScanConfigurationGet
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/internal/scan-configuration/:id
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 *
 * @param {INT} idScanConfiguration
 *   - Required: Yes
 *   - Description: Configuration identifier
 *
 * @returns {RECORDSET} Scan configuration details
 *
 * @testScenarios
 * - Valid retrieval with existing ID
 * - Not found error for non-existent ID
 * - Account isolation validation
 */
CREATE OR ALTER PROCEDURE [functional].[spScanConfigurationGet]
  @idAccount INTEGER,
  @idScanConfiguration INTEGER
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

  IF (@idScanConfiguration IS NULL)
  BEGIN
    ;THROW 51000, 'idScanConfigurationRequired', 1;
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
   * @output {ScanConfiguration, 1, n}
   * @column {INT} idScanConfiguration - Configuration identifier
   * @column {NVARCHAR} name - Configuration name
   * @column {NVARCHAR} directoryPath - Directory path
   * @column {BIT} includeSubdirectories - Include subdirectories flag
   * @column {NVARCHAR} temporaryExtensions - JSON array of extensions
   * @column {NVARCHAR} namingPatterns - JSON array of patterns
   * @column {INT} minimumAgeDays - Minimum age in days
   * @column {BIGINT} minimumSizeBytes - Minimum size in bytes
   * @column {BIT} includeSystemFiles - Include system files flag
   * @column {DATETIME2} dateCreated - Creation date
   * @column {DATETIME2} dateModified - Last modification date
   */
  SELECT
    scnCfg.[idScanConfiguration],
    scnCfg.[name],
    scnCfg.[directoryPath],
    scnCfg.[includeSubdirectories],
    scnCfg.[temporaryExtensions],
    scnCfg.[namingPatterns],
    scnCfg.[minimumAgeDays],
    scnCfg.[minimumSizeBytes],
    scnCfg.[includeSystemFiles],
    scnCfg.[dateCreated],
    scnCfg.[dateModified]
  FROM [functional].[scanConfiguration] scnCfg
  WHERE scnCfg.[idScanConfiguration] = @idScanConfiguration
    AND scnCfg.[idAccount] = @idAccount
    AND scnCfg.[deleted] = 0;
END;
GO