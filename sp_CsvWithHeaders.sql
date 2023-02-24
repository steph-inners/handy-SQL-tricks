
--===== About This Script
/*

This procedure uses Microsoft's XpCmdShell and Bulk Copy (BCP) Utility to place a copy
of your table in a CSV on a drive path of your choosing.
It exports all table data, with a full list of columns in the first row (header row).

*/
--------------------------------------------

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE [dbo].[sp_CsvWithHeaders]

	@database nvarchar(450),
	@schema nvarchar(50),
	@tablename nvarchar(450),
	@server nvarchar(450),
	@drive char(1),
	@folder_path nvarchar(450),
	@fileName nvarchar(450)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @filePath nvarchar(450) = '\\' + @server + '\' + @drive + '$\' + @folder_path + '\' + @fileName + '.csv'

	-- Build column lists

	declare @listToPivot nvarchar(max);
	declare @columnList nvarchar(max);

	declare @cursorResult table (id_list nvarchar(max), col_list nvarchar(max));
	insert into @cursorResult values ('','')

	declare @col_name nvarchar(max), @col_id nvarchar(max);

	declare col_cursor cursor
		for (
			select [column_id], [name]
			from sys.columns
			where object_id = OBJECT_ID(@database+'.'+@schema + '.' + @tablename)
		)
		open col_cursor
		fetch next from col_cursor into @col_id, @col_name

		while @@FETCH_STATUS = 0
		begin
			update @cursorResult
			set id_list = id_list + '[' + @col_id + '], ',
				col_list = col_list + 'rtrim(' + @col_name + '), '

			fetch next from col_cursor into @col_id, @col_name
		end

	close col_cursor
	deallocate col_cursor

	update @cursorResult
		set id_list = left(id_list,(select len(id_list) from @cursorResult)-1),
			col_list = left(col_list,(select len(col_list) from @cursorResult)-1);

	-- Query content for CSV

	declare @SqlStatement nvarchar(max);

	set @listToPivot = (select id_list from @cursorResult)	-- shows in format [1], [2], [3], etc...
	set @columnList = (select col_list from @cursorResult)

	print @listToPivot
	print @columnList

	set @SqlStatement = N'

	with file_contents as
		(
			SELECT ''0'' as [index], ' + @listToPivot + ' FROM (
				select [name],[column_id]
				from sys.columns
				where object_id = OBJECT_ID(N'''+@database+'.'+@schema + '.' + @tablename+''')
			) as col
			PIVOT (
			  max([name])
			  FOR [column_id]
			  IN (
				'+@ListToPivot+'
			  )
			) AS PivotTable

			union all

			select ''1'' as [index], ' + @columnList + '
			from ' + @database + '.' + @schema + '.' + @tablename + '
		)'
		+
-- create a table to hold results with headers. This table will be dropped later.
		'select *
		into ' + @database + '.' + @schema + '.CSV_' + @tablename + '_' + convert(nvarchar(450),getdate(),112) + ' ' +
		'from file_contents
		order by [index] asc
	  ';
 
	EXEC(@SqlStatement)


	declare @bcpCommand varchar(8000) = 'bcp ' + '"'
		+ 'select ' + @ListToPivot + @database + '.' + @schema + '.CSV_' + @tablename + '_' + convert(nvarchar(450),getdate(),112)
		+ ' order by [index] asc"' 
		+ ' queryout ' +  '"' + @filePath +'"' +' -c -T -t ,'

	exec master..xp_cmdshell @bcpCommand;

-- drop the table we created to temporarily hold the data for export

	set @SqlStatement = 

	'drop table ' + @database + '.' + @schema + '.CSV_' + @tablename + '_' + convert(nvarchar(450),getdate(),112);

	exec (@sqlStatement);

END
GO


