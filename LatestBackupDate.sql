  
  
  
with cte as (  
    select database_name
         , type 
         , backup_finish_date
         , row_number() over (partition by database_name, type order by backup_finish_date desc) ranking
      from msdb.dbo.backupset
     where database_name not in ( 'master', 'msdb', 'model', 'tempdb' )
       and backup_finish_date > dateadd(y, -1, sysdatetime())
		  )

    select [database_name] DatabaseName
	    , case 
		  when [type] = 'D'
			 then 'database'
		  when [type] = 'L'
			 then 'log'
		  when [type] = 'I'
			 then 'diff'
		  else 'other'
		 end DatabaseType
	    , backup_finish_date BackupFinishDate
	 from cte
	where ranking = 1;


