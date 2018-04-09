USE master;

BACKUP LOG BigLog TO DISK = 'C:\Backup\BigLog.trn' WITH COMPRESSION, STATS = 5;
BACKUP LOG SmallLog TO DISK = 'C:\Backup\SmallLog.trn' WITH COMPRESSION, STATS = 5;