with output_all as (

    select 
        *,
        replace(keyword_full_text, ' ', '') as keyword_no_spaces 
    from {{ ref('output_all') }}       
               
),

/* Add suggest API validation status */
validated_keywords as (

    select distinct
        replace(keyword, ' ', '') as keyword_no_spaces, 
        validation_status
    from {{ ref('stg_validated_keywords') }}
),

/* Add Google Search Console data */ 
gsc_data as (

    select
        query as keyword_full_text,
        impressions as seo_impressions, 
        clicks as seo_clicks
    from {{ ref('stg_gsc_query_data') }}

), 

/* Add Google ads adgroup clicks */
ads_adgroup_data as (

    select
        campaign_name as target_campaign,
        adgroup_name as target_ad_group,
        min_date,
        impressions as ads_impressions, 
        clicks as ads_clicks
    from {{ ref('stg_gads_adgroups') }}

), 

/* Add keyword serving status */
keywords_and_statuses as (

    select distinct
        campaign_name as target_campaign,
        adgroup_name as target_ad_group,
        keyword as keyword_full_text,
        status_serving
    from {{ ref('stg_gads_keywords_and_attributes') }}
    where is_negative = false
    
),


output_enriched as (

    select 
        {{ dbt_utils.surrogate_key(['country', 'target_campaign', 'target_ad_group']) }} as sk_id,
        country,
        model_typ,
        target_campaign,
        target_ad_group,
        keyword_full_text,
        brand_text,
        category_text,
        headline_text,
        nr_models_text,
        aggregation_type_text,
        price_min_text,
        gender_text,
        stock_number,
        discount_number,
        hassaleitems_text,
        sale_item_count_number,

        /* joined from suggest API validation */
        coalesce(validation_status, false) as validation_status,

        /* joined from gsc data */
        coalesce(seo_impressions, 0) as seo_impressions,
        coalesce(seo_clicks, 0) as seo_clicks,

        /* joined from ads data */
        coalesce(ads_impressions, 0) as ads_impressions,
        coalesce(ads_clicks, 0) as ads_clicks,
        
        /* set value to yesterday if adgroup doesn't exist yet */
        coalesce(min_date, date_sub(current_date, interval 1 day)) as min_date,
        coalesce(status_serving, 'ELIGIBLE') as status_serving
    from output_all
    left join validated_keywords using (keyword_no_spaces)
    left join gsc_data using (keyword_full_text)
    left join ads_adgroup_data using (target_campaign, target_ad_group)
    left join keywords_and_statuses using (target_campaign, target_ad_group, keyword_full_text)

), 

output_enriched_and_validated as (

    select
        *,
        /*  Case 1. No ads clicks */
        case 
            when
                /* Allow keywords that were validated via suggest API */
                (validation_status = true
                /* Allow keywords with minimum organic search traffic */
                or seo_impressions >= 5)
                /* Filter keywords that are not serving in the account */
                and status_serving not in ('RARELY_SERVED')
                
                then 'true_validation passed'
            else 'false'
        end as check_validation,
        /*  Case 2. Min x ads clicks */
        case 
            when  
                /* Allow ad groups with minimum traffic in 180 days*/
                (ads_clicks > 0 or ads_impressions > 100)
                and status_serving not in ('RARELY_SERVED')
                then 'true_traffic check passed'
            else 'false'
        end as check_min_traffic
    from output_enriched
    
)

select * from output_enriched_and_validated