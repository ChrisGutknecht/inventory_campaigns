{% docs description_feedcampaigns %}
### Description

transfer sql dbt output into csv files that will be uploaded to google ads

### What happens after dbt? Final data product and process from marts table

* Two cloud scheduler cron jobs trigger a cloud function with two differnt POST payload, one job each for 1. [category combinations](https://console.cloud.google.com/cloudscheduler/jobs/edit/europe-west1/write_feedcampaign_csv_cat?project=bergzeit) and 2. [model combinations](https://console.cloud.google.com/cloudscheduler/jobs/edit/europe-west1/write_feedcampaign_csv_mod?project=bergzeit). 

* A ["write to table csv" cloud function](https://console.cloud.google.com/functions/details/europe-west3/write_table_to_csv?env=gen1&project=bergzeit) stores a number of csv files in a [Cloud Storage bucket feedcampaign_output](https://console.cloud.google.com/storage/browser/feedcampaign_output;tab=objects?forceOnBucketsSortingFiltering=false&project=feeddataaggregation&prefix=&forceOnObjectsSortingFiltering=false), with each file representing a combination of entity (cat or model), matchtype (exact/bmm) and country.

* In a set of Google Ads scripts per country account, a javascript excecution fetches the csv feeds and updates the Google Ads account structure with csv the feed as the defining state.

### How oversees the data product and how? 

Christopher Gutknecht. A regular check of the scripts executions is performed to monitor the health of the full data product?

### Is there a visual flow chart for the entire data pipeline

Confluence tbd

### Which branch and ticket does the feature refer to?

WEBA-467

### Which further test coverage exists beyond dbt?

Alerts on cloud function and Google Ads scripts executions exist, sending emails to the main owner.

{% enddocs %}