{% macro extract_keyword_from_adgroup( adgroup_name ) %}

    -- All adgroup names should contain the keyword before the '|' character
    replace(
        split(adgroup_name, ' | ')[safe_offset(0)],
        '_',
        ' '
    )

{% endmacro %}