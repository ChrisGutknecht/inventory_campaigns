{% macro filter_keywords_with_policy_violations(keyword) %}

    /* remove old deleted adgroups */
    keyword not like '%holmenkol%'
    and keyword not like '%actos%'
    and keyword not like '%nigor%'

{% endmacro %}