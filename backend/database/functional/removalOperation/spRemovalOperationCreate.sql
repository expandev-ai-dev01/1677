/**
 * @summary
 * Creates a new removal operation for selected files
 *
 * @procedure spRemovalOperationCreate
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - POST /api/v1/internal/removal-operation
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
 * @param {INT} idScanOperation
 *   - Required: Yes
 *   - Description: Scan operation identifier
 *
 * @param {INT} removalMode
 *   - Required: Yes
 *   - Description: Removal mode (0=Recycle Bin, 1=Permanent)
 *
 * @returns {INT} idRemovalOperation - Created operation identifier
 *
 * @testScenarios
 * - Valid creation with existing scan operation
 * - Scan operation not found error
 * - Account isolation validation
 */
CREATE OR ALTER PROCEDURE [functional].[spRemovalOperationCreate]
  @idAccount INTEGER,
  @idUser INTEGER,
  @idScanOperation INTEGER,
  @removalMode INTEGER
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

  IF (@idScanOperation IS NULL)
  BEGIN
    ;THROW 51000, 'idScanOperationRequired', 1;
  END;

  IF (@removalMode IS NULL)
  BEGIN
    ;THROW 51000, 'removalModeRequired', 1;
  END;

  /**
   * @validation Business rule validation
   * @throw {invalidValue}
   */
  IF (@removalMode < 0 OR @removalMode > 1)
  BEGIN
    ;THROW 51000, 'invalidRemovalMode', 1;
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
    DECLARE @idRemovalOperation INTEGER;

    /**
     * @rule {db-multi-tenancy} Insert with account isolation
     */
    INSERT INTO [functional].[removalOperation] (
      [idAccount],
      [idScanOperation],
      [removalMode],
      [status],
      [progress]
    )
    VALUES (
      @idAccount,
      @idScanOperation,
      @removalMode,
      0,
      0
    );

    SET @idRemovalOperation = SCOPE_IDENTITY();

    /**
     * @output {RemovalOperation, 1, 1}
     * @column {INT} idRemovalOperation - Operation identifier
     */
    SELECT @idRemovalOperation AS [idRemovalOperation];
  END TRY
  BEGIN CATCH
    ;THROW;
  END CATCH;
END;
GO