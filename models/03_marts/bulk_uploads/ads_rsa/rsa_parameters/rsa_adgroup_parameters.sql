with rsa_adgroup_parameters as (

    select
        {{ get_account_id_by_country(country) }} as customer_id,
        target_campaign as campaign,
        target_ad_group as ad_group,
        nr_models_text as Customizer_adgroup_min_count__int,
        sale_item_count_number as Customizer_adgroup_min_sale_count__int,	
        case 
            when target_campaign like 'CH_2_%' or target_campaign like 'CH_3_%' then concat('CHF',price_min_text) 
            else concat(price_min_text, '€') 
        end as Customizer_adgroup_min_price__price,	
        '20%' as Customizer_adgroup_max_discount__pct
    from {{ ref('output_filtered') }}

)

select * from rsa_adgroup_parameters
where 
    customer_id != '_no_id'
    and campaign is not null
