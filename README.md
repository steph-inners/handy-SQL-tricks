# handy-SQL-tricks
Cozy little solutions to mildly annoying SQL problems.

1. **sp_CsvWithHeaders** uses Microsoft's XpCmdShell and Bulk Copy (BCP) Utility to place a copy of your table in a CSV on a drive path of your choosing. It exports all table data, with a full list of columns in the first row (header row).
