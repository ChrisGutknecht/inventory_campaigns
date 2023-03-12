{% macro rename_brand_names_and_remove_characters( brand ) %}

    case
        when brand like '%.%' then replace(brand, '.', '')
        else brand
    end

{% endmacro %}