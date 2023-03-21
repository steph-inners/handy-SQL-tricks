/*
	Use this format to test how a query edit changes your results.
	The edited query must have the same columns as the original,
	so this is best used for changes to WHERE clauses, calculations, etc.

	Results marked as "new" are records that show in the new query but not the old.
	Results marked as "old" are records that were dropped/changed by your query.
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
