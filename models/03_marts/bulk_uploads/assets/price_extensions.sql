-- reference: https://brandee.edu.vn/glossary/7158523-google-en/

with price_extensions as (

    select
        'Add' as action,
        campaign_name as campaign,
        'de' as language,
        'Product categories' as type,
        'from' as price_qualifier, --  34,99 EUR
        link_text as item_header, 
        price_min_text as item_price,
        'some text' as item_description,
        final_url as item_final_url
    from {{ ref('top_20_by_brand_output') }}
    
)

select * from price_extensions