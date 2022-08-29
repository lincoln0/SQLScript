USE DatabaseNameHere;
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/******************************************************************************

Purpose:
   Test: exec dbo.MyStoredProcedureName
-------------------------------------------------------------------------------

CHANGE LOG
Date		Author		Description
05/10/2017	Phil Factor	Creation
-------------------------------------------------------------------------------

*******************************************************************************/
create procedure [dbo].[ ] (
	
	)
as
begin try

truncate table LinkedServerName.DatabaseName.SchemaName.TableName;
go


--| The query goes here

end try


begin catch
	rollback transaction;
	throw;	--| remove this if sql server version is not 2012+
end catch;
go
