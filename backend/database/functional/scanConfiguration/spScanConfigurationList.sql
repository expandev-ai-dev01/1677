/**
 * @summary
 * Lists all scan configurations for an account
 *
 * @procedure spScanConfigurationList
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/internal/scan-configuration
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 *
 * @returns {RECORDSET} List of scan configurations
 *
 * @testScenarios
 * - List all configurations for account
 * - Empty result when no configurations exist
 * - Soft-deleted configurations excluded
 */
CREATE OR ALTER PROCEDURE [functional].[spScanConfigurationList]
  @idAccount INTEGER
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

  /**
   * @output {ScanConfigurationList, n, n}
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
  WHERE scnCfg.[idAccount] = @idAccount
    AND scnCfg.[deleted] = 0
  ORDER BY scnCfg.[name];
END;
GO