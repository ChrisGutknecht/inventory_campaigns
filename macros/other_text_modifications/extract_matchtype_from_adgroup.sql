{% macro extract_matchtype_from_adgroup( adgroup_name ) %}

    -- All adgroup names should have a matchtype suffix prefix like '{e}'
    case 
        when adgroup_name like '%{bmm}%' then 'Phrase match'
        when adgroup_name like '%{e}%' then 'Exact match'
        when adgroup_name like '%{e;p}%' then 'Exact match'
        when adgroup_name like '%{e;bmm}%' then 'Exact match'
        else 'Exact match'
    end

{% endmacro %}