/*
	Use this format to test how a query edit changes your results.
	The edited query must have the same columns as the original,
	so this is best used for changes to WHERE clauses, calculations, etc.

	Records marked as "new" are the results of your changes.
	Records marked as "old" were dropped/changed by your query.
*/

with new as (

	-- Your new, edited SELECT statement

),

old as (

	-- Your original, unedited SELECT statement

)

select 'new' as query, new.*
from new except (select 'new' as query, old.* from old)

union all

select 'old' as query, old.*
from old except (select 'old' as query, new.* from new)

order by query
