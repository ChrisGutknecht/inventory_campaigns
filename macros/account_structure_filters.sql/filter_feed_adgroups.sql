{% macro filter_feed_adgroups() %}

    /* remove old deleted adgroups */
    adgroup_status != 'REMOVED'
    /* only focus on feed adgroups for sync */
    and adgroup_name like '%| Feed_%'
    and adgroup_name not like '%} | Len %'
    and adgroup_name not like '%DUPLICATE%'
    and adgroup_name not like '%_some %'
    and adgroup_name not like '%_mis %'
    and adgroup_name not like '%_buy %'
    and adgroup_name not like '%(e)%'
    and adgroup_name not like '%(bmm)%'
    and adgroup_name not like '%zz_inactive%'
    and adgroup_name not like '%zz_paused%'
   

{% endmacro %}