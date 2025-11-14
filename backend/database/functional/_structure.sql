/**
 * @schema functional
 * Business logic schema for AutoClean application
 */
CREATE SCHEMA [functional];
GO

/**
 * @table scanConfiguration Configuration for file scanning operations
 * @multitenancy true
 * @softDelete true
 * @alias scnCfg
 */
CREATE TABLE [functional].[scanConfiguration] (
  [idScanConfiguration] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [directoryPath] NVARCHAR(500) NOT NULL,
  [includeSubdirectories] BIT NOT NULL DEFAULT (1),
  [temporaryExtensions] NVARCHAR(MAX) NOT NULL,
  [namingPatterns] NVARCHAR(MAX) NOT NULL,
  [minimumAgeDays] INTEGER NOT NULL DEFAULT (7),
  [minimumSizeBytes] BIGINT NOT NULL DEFAULT (0),
  [includeSystemFiles] BIT NOT NULL DEFAULT (0),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @table scanOperation Record of file scanning operations
 * @multitenancy true
 * @softDelete false
 * @alias scnOpr
 */
CREATE TABLE [functional].[scanOperation] (
  [idScanOperation] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idScanConfiguration] INTEGER NOT NULL,
  [directoryPath] NVARCHAR(500) NOT NULL,
  [status] INTEGER NOT NULL DEFAULT (0),
  [progress] INTEGER NOT NULL DEFAULT (0),
  [totalFilesAnalyzed] INTEGER NOT NULL DEFAULT (0),
  [totalFilesIdentified] INTEGER NOT NULL DEFAULT (0),
  [potentialSpaceBytes] BIGINT NOT NULL DEFAULT (0),
  [dateStarted] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateCompleted] DATETIME2 NULL
);
GO

/**
 * @table identifiedFile Files identified as temporary during scan
 * @multitenancy true
 * @softDelete false
 * @alias idnFil
 */
CREATE TABLE [functional].[identifiedFile] (
  [idIdentifiedFile] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idScanOperation] INTEGER NOT NULL,
  [filePath] NVARCHAR(500) NOT NULL,
  [fileName] NVARCHAR(255) NOT NULL,
  [fileExtension] NVARCHAR(50) NOT NULL,
  [fileSizeBytes] BIGINT NOT NULL,
  [fileModifiedDate] DATETIME2 NOT NULL,
  [identificationCriteria] NVARCHAR(200) NOT NULL,
  [selected] BIT NOT NULL DEFAULT (1),
  [dateIdentified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @table removalOperation Record of file removal operations
 * @multitenancy true
 * @softDelete false
 * @alias rmvOpr
 */
CREATE TABLE [functional].[removalOperation] (
  [idRemovalOperation] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idScanOperation] INTEGER NOT NULL,
  [removalMode] INTEGER NOT NULL DEFAULT (0),
  [status] INTEGER NOT NULL DEFAULT (0),
  [progress] INTEGER NOT NULL DEFAULT (0),
  [totalFilesRemoved] INTEGER NOT NULL DEFAULT (0),
  [totalFilesWithError] INTEGER NOT NULL DEFAULT (0),
  [spaceFreedBytes] BIGINT NOT NULL DEFAULT (0),
  [dateStarted] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateCompleted] DATETIME2 NULL
);
GO

/**
 * @table removedFile Record of files removed during operation
 * @multitenancy true
 * @softDelete false
 * @alias rmvFil
 */
CREATE TABLE [functional].[removedFile] (
  [idRemovedFile] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idRemovalOperation] INTEGER NOT NULL,
  [idIdentifiedFile] INTEGER NOT NULL,
  [filePath] NVARCHAR(500) NOT NULL,
  [fileSizeBytes] BIGINT NOT NULL,
  [success] BIT NOT NULL,
  [errorMessage] NVARCHAR(500) NULL,
  [dateRemoved] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @table scheduledCleanup Configuration for scheduled cleanup operations
 * @multitenancy true
 * @softDelete true
 * @alias schCln
 */
CREATE TABLE [functional].[scheduledCleanup] (
  [idScheduledCleanup] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idScanConfiguration] INTEGER NOT NULL,
  [active] BIT NOT NULL DEFAULT (0),
  [frequency] INTEGER NOT NULL DEFAULT (1),
  [scheduleTime] TIME NOT NULL DEFAULT ('03:00'),
  [dayOfWeek] INTEGER NULL,
  [dayOfMonth] INTEGER NULL,
  [cronExpression] NVARCHAR(100) NULL,
  [nextExecution] DATETIME2 NULL,
  [lastExecution] DATETIME2 NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @primaryKey pkScanConfiguration
 * @keyType Object
 */
ALTER TABLE [functional].[scanConfiguration]
ADD CONSTRAINT [pkScanConfiguration] PRIMARY KEY CLUSTERED ([idScanConfiguration]);
GO

/**
 * @primaryKey pkScanOperation
 * @keyType Object
 */
ALTER TABLE [functional].[scanOperation]
ADD CONSTRAINT [pkScanOperation] PRIMARY KEY CLUSTERED ([idScanOperation]);
GO

/**
 * @primaryKey pkIdentifiedFile
 * @keyType Object
 */
ALTER TABLE [functional].[identifiedFile]
ADD CONSTRAINT [pkIdentifiedFile] PRIMARY KEY CLUSTERED ([idIdentifiedFile]);
GO

/**
 * @primaryKey pkRemovalOperation
 * @keyType Object
 */
ALTER TABLE [functional].[removalOperation]
ADD CONSTRAINT [pkRemovalOperation] PRIMARY KEY CLUSTERED ([idRemovalOperation]);
GO

/**
 * @primaryKey pkRemovedFile
 * @keyType Object
 */
ALTER TABLE [functional].[removedFile]
ADD CONSTRAINT [pkRemovedFile] PRIMARY KEY CLUSTERED ([idRemovedFile]);
GO

/**
 * @primaryKey pkScheduledCleanup
 * @keyType Object
 */
ALTER TABLE [functional].[scheduledCleanup]
ADD CONSTRAINT [pkScheduledCleanup] PRIMARY KEY CLUSTERED ([idScheduledCleanup]);
GO

/**
 * @foreignKey fkScanOperation_ScanConfiguration Relates scan operation to its configuration
 * @target functional.scanConfiguration
 */
ALTER TABLE [functional].[scanOperation]
ADD CONSTRAINT [fkScanOperation_ScanConfiguration] FOREIGN KEY ([idScanConfiguration])
REFERENCES [functional].[scanConfiguration]([idScanConfiguration]);
GO

/**
 * @foreignKey fkIdentifiedFile_ScanOperation Relates identified file to scan operation
 * @target functional.scanOperation
 */
ALTER TABLE [functional].[identifiedFile]
ADD CONSTRAINT [fkIdentifiedFile_ScanOperation] FOREIGN KEY ([idScanOperation])
REFERENCES [functional].[scanOperation]([idScanOperation]);
GO

/**
 * @foreignKey fkRemovalOperation_ScanOperation Relates removal operation to scan operation
 * @target functional.scanOperation
 */
ALTER TABLE [functional].[removalOperation]
ADD CONSTRAINT [fkRemovalOperation_ScanOperation] FOREIGN KEY ([idScanOperation])
REFERENCES [functional].[scanOperation]([idScanOperation]);
GO

/**
 * @foreignKey fkRemovedFile_RemovalOperation Relates removed file to removal operation
 * @target functional.removalOperation
 */
ALTER TABLE [functional].[removedFile]
ADD CONSTRAINT [fkRemovedFile_RemovalOperation] FOREIGN KEY ([idRemovalOperation])
REFERENCES [functional].[removalOperation]([idRemovalOperation]);
GO

/**
 * @foreignKey fkRemovedFile_IdentifiedFile Relates removed file to identified file
 * @target functional.identifiedFile
 */
ALTER TABLE [functional].[removedFile]
ADD CONSTRAINT [fkRemovedFile_IdentifiedFile] FOREIGN KEY ([idIdentifiedFile])
REFERENCES [functional].[identifiedFile]([idIdentifiedFile]);
GO

/**
 * @foreignKey fkScheduledCleanup_ScanConfiguration Relates scheduled cleanup to configuration
 * @target functional.scanConfiguration
 */
ALTER TABLE [functional].[scheduledCleanup]
ADD CONSTRAINT [fkScheduledCleanup_ScanConfiguration] FOREIGN KEY ([idScanConfiguration])
REFERENCES [functional].[scanConfiguration]([idScanConfiguration]);
GO

/**
 * @check chkScanOperation_Status Validates scan operation status
 * @enum {0} Not Started
 * @enum {1} In Progress
 * @enum {2} Completed
 * @enum {3} Error
 */
ALTER TABLE [functional].[scanOperation]
ADD CONSTRAINT [chkScanOperation_Status] CHECK ([status] BETWEEN 0 AND 3);
GO

/**
 * @check chkScanOperation_Progress Validates progress percentage
 * @enum {0-100} Progress percentage
 */
ALTER TABLE [functional].[scanOperation]
ADD CONSTRAINT [chkScanOperation_Progress] CHECK ([progress] BETWEEN 0 AND 100);
GO

/**
 * @check chkRemovalOperation_RemovalMode Validates removal mode
 * @enum {0} Recycle Bin
 * @enum {1} Permanent
 */
ALTER TABLE [functional].[removalOperation]
ADD CONSTRAINT [chkRemovalOperation_RemovalMode] CHECK ([removalMode] BETWEEN 0 AND 1);
GO

/**
 * @check chkRemovalOperation_Status Validates removal operation status
 * @enum {0} Not Started
 * @enum {1} In Progress
 * @enum {2} Completed
 * @enum {3} Error
 */
ALTER TABLE [functional].[removalOperation]
ADD CONSTRAINT [chkRemovalOperation_Status] CHECK ([status] BETWEEN 0 AND 3);
GO

/**
 * @check chkRemovalOperation_Progress Validates progress percentage
 * @enum {0-100} Progress percentage
 */
ALTER TABLE [functional].[removalOperation]
ADD CONSTRAINT [chkRemovalOperation_Progress] CHECK ([progress] BETWEEN 0 AND 100);
GO

/**
 * @check chkScheduledCleanup_Frequency Validates cleanup frequency
 * @enum {0} Daily
 * @enum {1} Weekly
 * @enum {2} Monthly
 * @enum {3} Custom
 */
ALTER TABLE [functional].[scheduledCleanup]
ADD CONSTRAINT [chkScheduledCleanup_Frequency] CHECK ([frequency] BETWEEN 0 AND 3);
GO

/**
 * @check chkScheduledCleanup_DayOfWeek Validates day of week
 * @enum {1-7} Sunday to Saturday
 */
ALTER TABLE [functional].[scheduledCleanup]
ADD CONSTRAINT [chkScheduledCleanup_DayOfWeek] CHECK ([dayOfWeek] IS NULL OR ([dayOfWeek] BETWEEN 1 AND 7));
GO

/**
 * @check chkScheduledCleanup_DayOfMonth Validates day of month
 * @enum {1-31} Day of month
 */
ALTER TABLE [functional].[scheduledCleanup]
ADD CONSTRAINT [chkScheduledCleanup_DayOfMonth] CHECK ([dayOfMonth] IS NULL OR ([dayOfMonth] BETWEEN 1 AND 31));
GO

/**
 * @index ixScanConfiguration_Account
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixScanConfiguration_Account]
ON [functional].[scanConfiguration]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index ixScanOperation_Account
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixScanOperation_Account]
ON [functional].[scanOperation]([idAccount]);
GO

/**
 * @index ixScanOperation_Configuration
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixScanOperation_Configuration]
ON [functional].[scanOperation]([idAccount], [idScanConfiguration]);
GO

/**
 * @index ixScanOperation_Status
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixScanOperation_Status]
ON [functional].[scanOperation]([idAccount], [status]);
GO

/**
 * @index ixIdentifiedFile_Account
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixIdentifiedFile_Account]
ON [functional].[identifiedFile]([idAccount]);
GO

/**
 * @index ixIdentifiedFile_ScanOperation
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixIdentifiedFile_ScanOperation]
ON [functional].[identifiedFile]([idAccount], [idScanOperation]);
GO

/**
 * @index ixRemovalOperation_Account
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixRemovalOperation_Account]
ON [functional].[removalOperation]([idAccount]);
GO

/**
 * @index ixRemovalOperation_ScanOperation
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixRemovalOperation_ScanOperation]
ON [functional].[removalOperation]([idAccount], [idScanOperation]);
GO

/**
 * @index ixRemovedFile_Account
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixRemovedFile_Account]
ON [functional].[removedFile]([idAccount]);
GO

/**
 * @index ixRemovedFile_RemovalOperation
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixRemovedFile_RemovalOperation]
ON [functional].[removedFile]([idAccount], [idRemovalOperation]);
GO

/**
 * @index ixScheduledCleanup_Account
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixScheduledCleanup_Account]
ON [functional].[scheduledCleanup]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index ixScheduledCleanup_Active
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixScheduledCleanup_Active]
ON [functional].[scheduledCleanup]([idAccount], [active])
WHERE [deleted] = 0;
GO