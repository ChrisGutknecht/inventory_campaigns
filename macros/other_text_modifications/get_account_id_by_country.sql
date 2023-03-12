{% macro get_account_id_by_country(country) %}

    case
        when lower( country ) = 'de' then '784-418-1130'
        when lower( country ) = 'at' then '557-573-8585'
        when lower( country ) = 'ch' then '184-533-1214'
        else '_no_id'
    end

{% endmacro %}