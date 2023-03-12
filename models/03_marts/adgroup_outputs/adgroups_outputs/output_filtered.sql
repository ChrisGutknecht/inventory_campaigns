with bm_keywords_to_filter as (

    select 
        keyword_full_text,
        count(target_ad_group) as adgroup_count
    from {{ ref('output_enriched') }}
    where 
        country = 'DE' 
        and model_typ = 'exact'
    group by 1
    having adgroup_count > 1

), 

output_filtered as (

    select 
        {{ dbt_utils.star(ref('output_enriched')) }},
        adgroup_count 
    from {{ ref('output_enriched') }}
    left join bm_keywords_to_filter using (keyword_full_text)
    where     
        /* feed campaign rollout in DACH accounts */
        country in ('DE', 'AT', 'CH')

        /* Books and guide books are filtered at the stage level */   

        /* Only allow adgroups that have passed at least one validation check */
        and (
            check_validation like 'true%'
            or check_min_traffic like 'true%'
        )

        /* Remove duplicate BM adgroups already covered by BC */
        and not (adgroup_count > 1 and aggregation_type_text in ('BM', 'BMG'))
)

select * from output_filtered