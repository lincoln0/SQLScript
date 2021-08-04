
 ;with cte as (
	select database_name
		 , type
		 , max(backup_start_date) LatestBackup
	  from msdb.dbo.backupset
	 where database_name not in ( 'master', 'msdb', 'model', 'tempdb' )
		   and backup_finish_date > dateadd(y, -7, sysdatetime())
		   and type = 'D'
  group by database_name, type  
			)

	, cte2 as (

    select database_name
		 , type
		 , max(backup_start_date) LatestBackup
	  from msdb.dbo.backupset
	 where database_name not in ( 'master', 'msdb', 'model', 'tempdb' )
		   and backup_finish_date > dateadd(day, -10, sysdatetime())
		   and type = 'L'
  group by database_name, type   
			)

	select a.name 
		 , a.recovery_model_desc
		 , b.type
		 , b.LatestBackup D_LatestBackup
		 , c.type
		 , c.LatestBackup L_LatestBackup
	  from sys.databases a
 left join cte b
		on a.name = b.database_name
 left join cte2 c
		on a.name = c.database_name
	 where a.database_id > 4
	 order by 2 desc
