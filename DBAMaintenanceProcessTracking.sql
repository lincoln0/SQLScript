
--| Create schema for tracking processes
create schema tracking;
go

-- drop table tracking.objecttracker
-- drop table tracking.processinfo

--| Create a table for tracking database processes

create table tracking.ProcessInfo (
	ProcessID			int identity(1, 1) not null primary key clustered with fillfactor = 90
,	ProcessDescription	nvarchar(255) not null constraint UQ_ProcessDescription unique(ProcessDescription)
,	CreateDate			datetime2 default sysdatetime()
,	CreatedBy			char(30) NOT NULL default suser_sname()
);

--| Create a table for tracking database objects related to processes

create table tracking.ObjectTracker (
	ObjectTrackerID		int identity(1, 1) not null primary key clustered with fillfactor = 90
,	ProcessID			int not null constraint fk_tracking_ProcessInfo_ProcessID foreign key (ProcessID) references tracking.ProcessInfo (ProcessID)
,	ObjectName			nvarchar(255) not null constraint UQ_ObjectName unique(ObjectName)
,	ObjectDescription	nvarchar(255) not null
,	CreateDate			datetime2 default sysdatetime()
,	CreatedBy			char(30) NOT NULL default suser_sname()
);

--| Insert data into the ProcessInfo table
Insert into tracking.ProcessInfo (ProcessDescription)
select 'Will be used to document and track processes within the DBA Maintenance database.';

--| Insert data into the object tracker table for objects that relate to the process

Insert into tracking.ObjectTracker (ProcessID, ObjectName, ObjectDescription)
select '1', 'tracking.ProcessInfo', 'The base process table, used to link objects to processes and document purpose of processes' union all
select '1', 'tracking.ObjectTracker', 'Used to group objects to processes';

--| Add index for the foreign key
create nonclustered index IX_tracking_ObjectTracker_ProcessID_FK on tracking.ObjectTracker (ProcessID);

--| Validation
select * from tracking.processinfo
select * from tracking.ObjectTracker