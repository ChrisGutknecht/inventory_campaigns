-- de feed gender uses english terms
-- nl feed is already in nl
-- needs to be transferred to country language for gender adgroups

{% macro text_to_country_language(column_name) %}

(
    replace(replace( {{ column_name }}, 'female', 'Damen'), 'male', 'Herren')
)


{% endmacro %}