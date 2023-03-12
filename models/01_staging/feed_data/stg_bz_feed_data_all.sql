/* collect feed data from all countries */
{% set countries = ['de','nl'] %}

with all_feed_data as (

    {% for country in countries %}
        {% set source_country = 'bz_feed_' + country %}

        select
            {{ dbt_utils.surrogate_key(['id', 'title']) }} as sk_id,
            '{{ country }}' as base_country,
            id,
            title,
            description,
            link,
            {{ rename_brand_names_and_remove_characters(brand) }} as brand,
            coalesce(color, 'standard') as color,
            coalesce(pattern, 'standard') as pattern,
            condition,
            gender,
            age_group,
            cast(material as string) as material,
            cast(split(cast(price as string),' ')[safe_offset(0)] as numeric) as price,
            cast(split(cast(sale_price as string),' ')[safe_offset(0)] as numeric) as sale_price,
            product_type,
            /* Rename brands and remove characters are not permitted in Google Ads */
            {{ rename_brand_names_and_remove_characters(brand) }} as brand_text,
            cast(split(cast(price as string),' ')[safe_offset(0)] as numeric) as price_number,
            cast(split(cast(sale_price as string),' ')[safe_offset(0)] as numeric) as sale_price_number,

            /* get kids as third gender for combinations from age_group */
            case
                when lower(age_group) in ('kids', 'kinder') then 'Kinder'
                else initcap( {{text_to_country_language('gender')}} )
            end as gender_cleaned,
            /* Remove Konfiguratoren top category */
            replace(trim(split(product_type,' > ')[safe_OFFSET(0)]), 'Konfiguratoren', 'Ausrüstung') as product_type_level1,
            trim(split(product_type,' > ')[safe_OFFSET(1)]) as split_product_type_level2,
            trim(split(product_type,' > ')[safe_OFFSET(2)]) as split_product_type_level3,
            trim(split(product_type,' > ')[safe_OFFSET(3)]) as split_product_type_level4,
            concat(substring(id,1,7), '-', lower(coalesce(pattern, 'standard'))) as parent_id_color
    
        from {{ source('feed_campaign_product_data', source_country) }}
        where 
            brand is not null
            /* removing Bergzeit brand */
            and brand != 'Bergzeit'
            /* removing low price accesories */
            and cast(split(cast(price as string),' ')[safe_offset(0)] as numeric) >= 5
            and cast(split(cast(sale_price as string),' ')[safe_offset(0)] as numeric) >= 5
            
            /* removing product brands and categories not suitable for adgroups */
            and (regexp_contains(brand, 'Landesamt') = False or regexp_contains(title, 'Landesamt') = False)
            and (regexp_contains(brand, 'Verlag') = False)
            and (product_type not like '%Bücher%' and product_type not like '%Karten%')


    {% if not loop.last -%} union all {%- endif %}
    {% endfor %}

)

select * from all_feed_data