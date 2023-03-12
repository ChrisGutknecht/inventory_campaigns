
{% macro change_month_name_to_german( month ) %}

case
    when {{ month }} = 'January' then 'Januar'
    when {{ month }} = 'February' then 'Februar'
    when {{ month }} = 'March' then 'März'
    /* April same in German */
    when {{ month }} = 'May' then 'Mai'
    when {{ month }} = 'June' then 'Juni'
    when {{ month }} = 'July' then 'Juli'
    /* August, September same in German */
    when {{ month }} = 'October' then 'Oktober'
    /* November same in German */
    when {{ month }} = 'December' then 'Dezember'
end

{% endmacro %}