/**
 * @summary
 * Lists all identified files for a scan operation
 *
 * @procedure spIdentifiedFileList
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/internal/scan-operation/:id/identified-files
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
 * @returns {RECORDSET} List of identified files
 *
 * @testScenarios
 * - List all files for operation
 * - Empty result when no files identified
 * - Account isolation validation
 */
CREATE OR ALTER PROCEDURE [functional].[spIdentifiedFileList]
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
   * @output {IdentifiedFileList, n, n}
   * @column {INT} idIdentifiedFile - File identifier
   * @column {NVARCHAR} filePath - Complete file path
   * @column {NVARCHAR} fileName - File name
   * @column {NVARCHAR} fileExtension - File extension
   * @column {BIGINT} fileSizeBytes - File size in bytes
   * @column {DATETIME2} fileModifiedDate - Last modification date
   * @column {NVARCHAR} identificationCriteria - Criteria that identified this file
   * @column {BIT} selected - Selection status for removal
   * @column {DATETIME2} dateIdentified - Identification date
   */
  SELECT
    idnFil.[idIdentifiedFile],
    idnFil.[filePath],
    idnFil.[fileName],
    idnFil.[fileExtension],
    idnFil.[fileSizeBytes],
    idnFil.[fileModifiedDate],
    idnFil.[identificationCriteria],
    idnFil.[selected],
    idnFil.[dateIdentified]
  FROM [functional].[identifiedFile] idnFil
  WHERE idnFil.[idAccount] = @idAccount
    AND idnFil.[idScanOperation] = @idScanOperation
  ORDER BY idnFil.[filePath];
END;
GO