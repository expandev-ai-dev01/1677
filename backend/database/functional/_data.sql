/**
 * @load scanConfiguration
 */
INSERT INTO [functional].[scanConfiguration]
([idAccount], [name], [directoryPath], [includeSubdirectories], [temporaryExtensions], [namingPatterns], [minimumAgeDays], [minimumSizeBytes], [includeSystemFiles])
VALUES
(1, 'Default Configuration', 'C:\\Temp', 1, '[".tmp",".temp",".cache",".bak",".log","~",".swp"]', '["temp*","*_temp","*_old","*_bak","~*"]', 7, 0, 0);
GO