{% macro filter_feed_campaigns() %}

    /* remove old deleted campaigns */
    campaign_status != 'REMOVED'
    and campaign_name not like '%DSA%'
    and campaign_name not like '%SQA%'
    and campaign_name not like '%__All%'
    and campaign_name not like '%zz_paused%'
    and campaign_name not like '%zz_inactive%'
    and campaign_name not like '%_BM_Test_%'
    /* only filter DACH campaigns, as feed campaigns not rolled out to focus yet */
    and (campaign_name like 'CH_%' or campaign_name like 'AT_%' or campaign_name like 'DE_%')
    /* only filter certain generics and brand campaigns */
    and (
        campaign_name like '%_2_%' or 
        /* do not synchronise Generics campaigns marked as Non-Feed */
        (campaign_name like '%_3_%' and campaign_name not like '%(Non-Feed)%')
    )
    -- removed for generic campaigns
    -- and (campaign_name like '%(Top)%' or campaign_name like '%(Other)%')

{% endmacro %}