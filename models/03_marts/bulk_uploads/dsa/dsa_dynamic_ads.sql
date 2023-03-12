with dsa_ads_upload as (
    
    select
        customer_id_hyphens as customer_id,
        'Add' as action,
        campaign_name as campaign,
        concat (brand, ' | DSA') as ad_group,
        'Expanded dynamic search ad' as ad_type,
        concat(brand, ' Bekleidung & Ausrüstung. Ab 99€ versandkostenfrei bestellen') as description_1,
        if(
            campaign_name like 'CH_2_%', 
            'Lieferzeit in 2-4 Tagen. CHF5 Newsletter Rabatt',
            'Lieferzeit in 2-4 Tagen. 5€ Newsletter Rabatt'
        )
        as description_2
    from {{ ref('int_campaigns_without_dsa_adgroups') }}

) 

select * from dsa_ads_upload