declare @sql varchar(5000)   

if exists (select name from tempdb..sysobjects where name = '##results')    
   begin    
       drop table ##results    
   end   
      
create table ##results (
	[DatabaseName] sysname
,	[FileName] sysname
,	[TotalSizeInMB] int
,	[DBFreeSpaceMB] int
)   

SELECT @sql =    
'use [?] insert into ##Results([DatabaseName], [FileName], [TotalSizeInMB], [DBFreeSpaceMB])    
select db_name()
, [name] AS [FileName]
, [TotalSizeInMB] = case ceiling([size]/128) when 0 then 1 else ceiling([size]/128) end
, [DBFreeSpaceMB] = case ceiling([size]/128) when 0 then (1 - cast(fileproperty([name], ''SpaceUsed''' + ') as int) /128)   
else (([size]/128) - cast(fileproperty([name], ''SpaceUsed''' + ') as int) /128) end
from sys.database_files
order by [file_id]'  

--Print the command to be issued against all databases   
PRINT @sql   

--Run the command against each database   
EXEC sp_MSforeachdb @sql 
declare @sizeInfo as table (
    sizeInfo            int identity(1,1) not null primary key clustered
,   Instance            nvarchar(255) not null
,   DatabaseId          int not null
,   DatabaseName        nvarchar(255) not null
,   [Filename]          nvarchar(255) not null
,   DatabaseFileSizeGB  decimal(18,2) not null
,   DatabaseFreeSpaceMB decimal(18,2) null
,   MountPoint          nvarchar(255) not null
,   LogicalDriveName    nvarchar(255) not null
,   LUNTotalGB          decimal(18,2) not null
,   LUNAvailableGB      decimal(18,2) not null 
,   LUNFreeSpace        decimal(18,2) not null 
)

insert into @sizeInfo (Instance,DatabaseId,DatabaseName,[FileName],DatabaseFileSizeGB,MountPoint,LogicalDriveName,LUNTotalGB,LUNAvailableGB,LUNFreeSpace)

select distinct convert(char(100), serverproperty('Servername')) as Instance
     , a.Database_id
     , b.Name
     , a.Name FileName 
     , (a.size * 8 / 1024) / 1024 DatabaseSizeGB
     , volume_mount_point [Disk]
     , logical_volume_name LogicalDriveName
     , convert(decimal(18,2), total_bytes / 1073741824.0) as LUNTotalGB
     , convert(decimal(18,2), available_bytes / 1073741824.0) as LUNAvailableGB
     , cast(cast(available_bytes as float)/ cast(total_bytes as float) as decimal(18,2)) * 100 as LUNSpaceFree
  from sys.master_files a
  join sys.databases b
    on a.database_id = b.database_id
 cross apply sys.dm_os_volume_stats(a.database_id, file_id)
 where a.database_id > 4

    update @sizeInfo 
    set DatabaseFreeSpaceMB = DBFreeSpaceMB
    from ##Results x
    join @sizeInfo b
        on x.FileName = b.FileName

select *
  from @sizeInfo





