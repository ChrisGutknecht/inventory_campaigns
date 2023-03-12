-- equipment will be excluded in gender specific models
-- we need to fetch all the equipment terms

{% macro exclude_equipment(column_name) %}

(
    {{ column_name }} not in ('Ausrüstung', 'Uitrusting')
)


{% endmacro %}