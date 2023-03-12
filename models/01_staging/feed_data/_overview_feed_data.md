{% docs description_feed_data %}
### Description

Cloud function that writes a reduced core set of columns to a BigQuery table

### When does the job run and how?

* The [daily cloud scheduler job is triggered multiple times per day](https://console.cloud.google.com/cloudscheduler/jobs/edit/europe-west1/write_google_shopping_feed_de?project=feeddataaggregation)

### How does the data land in BigQuery?

* The Google Merchant Center DE feed is updated by ChannelPilot, the URL can be seen in the payload
* The ["import_feed_to_bq" cloud function](https://console.cloud.google.com/functions/details/europe-west1/import_feed_to_bq?env=gen1&project=feeddataaggregation) pulls a specific subset of columns and writes the csv to BigQuery, by overwriting the old values
 
### What type of table is it?

Native.

### How oversees the data pipeline and how? 

Christopher Gutknecht. The cloud function has an email alert if it fails

### Which ticket does the feature refer to?

None

### Which further test coverage and alerts exist beyond dbt?

None

{% enddocs %}