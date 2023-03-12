{% macro map_country_code_to_country_name(country) %}

    case 
        when country = 'DE' then 'Germany'
        when country = 'AT' then 'Austria'
        when country = 'CH' then 'Switzerland'
        when country = 'NL' then 'Netherlands'
        when country = 'BE' then 'Belgium'
        else ''
    end

{% endmacro %}