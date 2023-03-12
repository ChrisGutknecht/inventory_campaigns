with ad_url_prefixes as (

    select
        country,
        search_url_prefix
    from {{ ref('stg_search_ad_url_prefixes') }}

),

sitelinks as (

    select distinct
        country,
        brand_text as brand,
        target_campaign as campaign_name,
        case 
            when length(brand_text) <= 15 and headline_text like '%Damen' and aggregation_type_text = 'BG' then replace(headline_text,'Damen','für Damen') 
            when length(brand_text) <= 14 and headline_text like '%Herren' and aggregation_type_text = 'BG' then replace(headline_text,'Herren','für Herren')
            when length(brand_text) <= 14 and headline_text like '%Kinder' and aggregation_type_text = 'BG' then replace(headline_text,'Kinder','für Kinder')
            else headline_text
        end as link_text,
        trim(replace(headline_text, brand_text, '')) as keyword_without_brand,
        price_min_text, 
        /* Build search url with url_prefix and keyword */
        concat(
            prefixes.search_url_prefix,
            replace(keyword_full_text, ' ', '+')
        ) as final_url,
        'All' as platform_targeting, 
        'All' as device_preference
    from {{ ref('top_20_by_brand_raw') }}
    left join ad_url_prefixes as prefixes using(country)

), 

sitelinks_shortened as (

    select 
        *, 
        case   
            /* Shorten long link texts by using brand initials */
            when length(link_text) >= 26 
            then concat(array_to_string(
                    array(select left(x,1) from unnest(split(brand, ' ')) as x), '.'), 
                    '. ', 
                    keyword_without_brand
                )
            else link_text
        end as link_text_shortened
    from sitelinks

),

sitelinks_final as (

    select *
    from sitelinks_shortened
    where length(link_text_shortened) <= 25
    
)

select * from sitelinks_final
