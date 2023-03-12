-- collect title data from all countries

{% set countries =  ['de'] %}

with all_title_data as (

    {% for country in countries %}
        {% set source_country = 'bz_title_data_' + country %}
        
    select distinct
        {{ dbt_utils.surrogate_key(['id', 'title_short']) }} as sk_id,
        '{{ country }}' as country,
        id as t_id,
        title_short,
        SPLIT(title_short,' ')[safe_OFFSET(0)] as title_level1,
        concat(SPLIT(title_short,' ')[safe_OFFSET(0)], ' ', SPLIT(title_short,' ')[safe_OFFSET(1)]) as title_level2
    from {{ source('feed_campaign_product_data', source_country) }}
    where title_short is not null

        {% if not loop.last -%} union all {%- endif %}
    {% endfor %}

)

select * from all_title_data