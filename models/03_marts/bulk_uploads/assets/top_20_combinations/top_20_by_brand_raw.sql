with combinations_filtered as (

    select *
    from {{ ref('output_filtered') }}
    where 
        aggregation_type_text in ('BC', 'BG')
        and model_typ = 'exact'

), 

combinations_ranked_by_brand as (

    select 
        *,
        rank() over (partition by target_campaign order by nr_models_text desc) as rank_per_brand
    from combinations_filtered

),

top_20_combinations_by_brand as (

    select 
        *,
        row_number() over(partition by target_campaign order by rank_per_brand) as row_number
    from combinations_ranked_by_brand
    order by target_campaign, row_number

)

select * from top_20_combinations_by_brand
where 
    row_number <= 20
    and nr_models_text >=10