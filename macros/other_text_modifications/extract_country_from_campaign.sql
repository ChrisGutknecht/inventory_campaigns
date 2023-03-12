{% macro extract_country_from_campaign( campaign_name ) %}

    -- All campaign names should have a country prefix like 'DE_'
    split(campaign_name, '_')[safe_offset(0)]

{% endmacro %}