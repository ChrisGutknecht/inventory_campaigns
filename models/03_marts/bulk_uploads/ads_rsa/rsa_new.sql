with feed_adgroups as (

    select 
        *, 
        /* preparing calculation for ad fallback text */
        length(headline_text) as headline_length,
        split(headline_text, ' ') as headline_words,
        trim(replace(headline_text, brand_text, '')) as headline_without_brand,

        /* Shorten long brands or long categories to brand initials */
        concat(
            array_to_string(
                array(select left(x,1) from unnest(split(brand_text, ' ')) as x), 
                '.'
            ), 
            '. ', 
            trim(replace(headline_text, brand_text, ''))
        ) as headline_with_brand_initials,
        array_length(split(headline_text, ' ')) as headline_words_length,
        length(brand_text) as brand_length,
        array_length(split(brand_text, ' ')) as brand_words_length,
        length(category_text) as category_length
    from {{ ref('output_filtered') }}

),

adgroups_without_rsas as (

    select
        customer_id_hyphens as customer_id,
        campaign_name,
        adgroup_name
    from {{ ref('int_adgroups_without_rsas') }}

    /* performs select distinct on the union */
    union all

    /* add keywords for new adgroups, after adgroups are created */
    select
        customer_id,
        campaign_name,
        adgroup_name
    from {{ ref('adgroups_new') }}  

), 

rsa_templates as (

    select {{ dbt_utils.star(ref('stg_ads_rsa_templates')) }}
    from {{ ref('stg_ads_rsa_templates') }}

), 

ad_url_prefixes as (

    select
        country as pref_country,
        search_url_prefix
    from {{ ref('stg_search_ad_url_prefixes') }}

),

rsa_ads_new as (

    select
        {{ get_account_id_by_country(country) }} as customer_id,
        campaign_name as campaign,
        adgroup_name as adgroup,

        /*  See RSA template here: 
            https://docs.google.com/spreadsheets/d/1_DdE1rI6yckqiaitwl9TtNY2dRK2Ic1LuaEv5wtDlus/edit?usp=sharing */
        
        /* headline_1 logic */
        case  
            when headline_length > 30 and length(headline_with_brand_initials) <= 30 
            then headline_with_brand_initials

            when headline_length > 30 and length(headline_with_brand_initials) > 30 
            then concat(left(feed.headline_text, 29), '.')
            else feed.headline_text
        end as headline_1,
        /* headline_2 logic */
        case 
            when brand_length <= 12 then concat(brand_text, '© im Bergzeit Shop')
            when brand_length = 13 then concat(feed.brand_text, ' im Bergzeit Shop')
            when brand_length <= 16 then concat(feed.brand_text, '© bei Bergzeit')
            when brand_length = 17 then concat(feed.brand_text, ' bei Bergzeit')
            when brand_length = 21 then concat(feed.brand_text, '© im Shop')
            when brand_length <= 22 then concat(feed.brand_text, ' im Shop')
            when brand_length > 22 or feed.aggregation_type_text = 'B' then 'Jetzt online bestellen'
            else 'Jetzt online bestellen'
        end as headline_2,
        rsa_templates.headline_3,
        rsa_templates.headline_4,
        rsa_templates.headline_5,
        rsa_templates.headline_6,
        rsa_templates.headline_7,
        rsa_templates.headline_8,
        rsa_templates.headline_9,
        rsa_templates.headline_10,
        rsa_templates.headline_11,
        rsa_templates.headline_12,
        rsa_templates.headline_13,
        rsa_templates.headline_14,
        rsa_templates.headline_15,

        /* Contains headline and brand */
        replace(
            replace(description_1, '$$Headline$$', feed.headline_text), 
            '$$Brand$$',
            feed.brand_text
        ) as description_1,
        rsa_templates.description_2,
        rsa_templates.description_3,
        rsa_templates.description_4,
        
        /* path values appear in the displayed URL */
        case 
            when brand_length > 15 
            then replace(left(feed.brand_text, 15), ' ', '_') 
            else replace(replace(lower(feed.brand_text), ' ', '_'), '/','-')
        end as path_1,

        /* path 2 logic */
        case
            /* Use category value as path 2 if shorter than 16 */
            when feed.aggregation_type_text in ('BC', 'BCG', 'BM', 'BMG') and length(feed.category_text) <= 15 
            then replace(lower(trim(feed.category_text)), ' ', '_')

            /* Use keyword without brand if category too long */
            when feed.aggregation_type_text in ('BC', 'BCG', 'BM', 'BMG') and length(feed.category_text) > 15 and length(headline_without_brand) <= 15
            then replace(lower(trim(feed.headline_without_brand)), ' ', '_')

            /* Use brand if aggregation type BG */
            when feed.aggregation_type_text in ('BG') then replace(lower(feed.gender_text), ' ', '_')
            else ''
        end as path_2,

        /* Build search url with url_prefix and keyword */
        concat(
            prefixes.search_url_prefix,
            replace(replace(feed.keyword_full_text, ' ', '+'), '%', '')
        ) as final_url
    from adgroups_without_rsas as account
    inner join feed_adgroups as feed on
        account.campaign_name = feed.target_campaign and
        account.adgroup_name = feed.target_ad_group
    left join rsa_templates on 
        feed.country = rsa_templates.language
    left join ad_url_prefixes as prefixes on
        feed.country = prefixes.pref_country
    where 
        /* find the matching feed data for new and incomplete adgroups */
        account.campaign_name is not null
        and account.adgroup_name is not null

)

select * from rsa_ads_new