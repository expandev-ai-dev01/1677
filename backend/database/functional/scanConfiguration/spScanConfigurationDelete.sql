/**
 * @summary
 * Soft deletes a scan configuration
 *
 * @procedure spScanConfigurationDelete
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - DELETE /api/v1/internal/scan-configuration/:id
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
 * @testScenarios
 * - Valid deletion of existing configuration
 * - Not found error for non-existent ID
 * - Account isolation validation
 * - Prevent deletion if active scheduled cleanups exist
 */
CREATE OR ALTER PROCEDURE [functional].[spScanConfigurationDelete]
  @idAccount INTEGER,
  @idUser INTEGER,
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

  IF (@idUser IS NULL)
  BEGIN
    ;THROW 51000, 'idUserRequired', 1;
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
   * @validation Business rule validation
   * @throw {cannotDelete}
   */
  IF EXISTS (
    SELECT 1
    FROM [functional].[scheduledCleanup] schCln
    WHERE schCln.[idScanConfiguration] = @idScanConfiguration
      AND schCln.[idAccount] = @idAccount
      AND schCln.[active] = 1
      AND schCln.[deleted] = 0
  )
  BEGIN
    ;THROW 51000, 'cannotDeleteConfigurationWithActiveSchedules', 1;
  END;

  BEGIN TRY
    /**
     * @rule {db-soft-delete} Soft delete implementation
     */
    UPDATE [functional].[scanConfiguration]
    SET
      [deleted] = 1,
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