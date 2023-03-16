# Welcome to the SQL-based PPC inventory campaigns repository! (by Bergzeit)

## High-level description: What is this repository about?

This repository takes item-level product data and performs SQL transformations to generate bulk upload formats for specific Google Ads entities such as campains, adgroups, keywords etc. This documentation describes all necessary business logic in SQL and configuration in YAML to perform the necessary transformations. All code was written by the Bergzeit Analytics and Performance team, primarily Christopher Gutknecht and Stephanie Hubert. The content includes all data lineage from source to output, the SQL code, meta data description and configured data tests implemented in the dbt framework.

For a PPC introduction, reference this SMX deck: 

https://www.slideshare.net/ChristopherGutknecht/scaling-search-campaigns-with-bulk-uploads-and-ad-customizers-smx-2023

An interactive documentation of the project can be explored here:
https://inventory-campaigns-bergzeit-demo.netlify.app/#!/overview

<img width="361" alt="dbt_bz" src="https://user-images.githubusercontent.com/6991865/225361573-008c683f-8dee-4f0e-b3d8-bdac0afab6af.png">

---

## Prerequisites: Which skills and tools do I need to implement this framework?

This repository builds on the *dbt* (data build tool) framework, the industry standard for large scale SQL transformation in modern data warehouses. 

- You need solid working *knowledge of SQL* (or a data team) to model your data transformation of product item inventory
- For an introduction to the dbt framework, see here: https://www.getdbt.com/blog/what-exactly-is-dbt/
- To learn the necessary fundamentals of dbt, see this course: https://courses.getdbt.com/courses/fundamentals
- To get startetd with *dbt cloud* (recommended for beginners), see here: https://docs.getdbt.com/docs/get-started/dbt-cloud-features

For a dbt cloud project, you will need to connect 1) a *data warehouse* (BigQuery recommended) and 2) a *version control system* (github recommended)

---

## Installation: How can I setup inventory-driven PPC campaigns?

This is a step-by-step guide to setup the inventory campaign project:

1. Have your dbt cloud account setup and connect your data warehouse. For BigQuery, see here: https://docs.getdbt.com/reference/warehouse-setups/bigquery-setup
2. Clone the github repository into your dbt cloud project: https://github.com/ChrisGutknecht/inventory_campaigns

If you've successfully cloned the github repo above, your own github repo should populate with a set of six folder and further config files. The next steps build on having the repo successfully installed:

3. Configure you ```dbt_project.yml``` file in the following way:

3.1. Basic configuration

Under ```models``` > ```01_staging```, set the ```project``` attribute to your Google cloud project and ```dataset``` to you BigQuery dataset for the following subfolders: 

- ```account_structure```. The staging tables storage destination for your account structure. In the current implementation the used source tables are not the original Google Ads Transfer source tables, but already joined marts tables built in a different project. We might add these previous transformation steps to the project at a later stage.

- ```ad_templates```. The staging tables for your ad template source.

- ```feed_data```.The staging tables  for your product feed data.

- ```lookup_tables```. The staging tables for your product feed data.

- ```seo_data```. The staging tables for your search console data.

- ```validated_keywords```. The staging tables for your keywords validated from the suggest API.

Note that ```materialized: view``` guarantees that all tables are always up-to-date. The alternative materialization ```materialized: "{{ 'view' if env_var('DBT_ENVIRON_FEED') == 'ci' else 'table' }}"``` will materialize the model as a table in the production environment but keep a view table for the continuous integration environment for easy CI/CD checks on pull requests.

3.2. Advanced configuration

- you can update the default path values under if necessary.
```yaml
model-paths: ["models"]
analysis-paths: ["analysis"]
test-paths: ["tests"]
seed-paths: ["seeds"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]
```
- there is a deactived on-run-end command for storing test results. This can be helpful if you want to generate a history of failed and successful tests. More on run hooks here: https://docs.getdbt.com/reference/project-configs/on-run-start-on-run-end
```yaml
on-run-end:
  # - "{% if env_var('DBT_ENVIRON_FEED') == 'prod' %} {{ store_test_results(results)}} {% endif %}"
```

4. Review your ```packages.yml``` file. 

The repo currently leverages the following packages: 
- ```dbt_utils``` for syntactical abstractions and tests, 
- ```dbt_expectations``` for data quality tests and 
- ```codegen``` for more scalable documentation.

After reviewing the required packages, run the ```dbt deps``` to install the packages, which can be seen in the dbt_packages folder. The existing package list can be easily extended: https://docs.getdbt.com/docs/build/packages

5. Data source configuration

Open the ```_source_*.yml``` files for every staging folder mentioned in 3.1. and configure your source tables. 

Example for ```01_staging``` > ```account_structure```:
- ```database``` represents the Google cloud project
- ```schema``` represents the Google BigQuery dataset
- ```tables``` > ```name``` is the source table name. This can take an additional ```identifier``` parameter for a nicer table name in your source reference.

```yaml
sources:
  - name: account_structure
    database: your_gcp_project
    schema: dbt_sea_analytics
    description: The status of current Google Ads entities per country

    tables:
      - name: gads_ads_and_parent_statuses
        description: the status of ads, adgroups and campaigns
````

Change the three attribute values for ```database```, ```schema```, ```tables```. 

6. Macro configuration

In the ```macros``` folder, there are three subfolders with the following purposes:
- ```account_structure_filters```. These statements contain all customized filter statements that define the synchronisation scope for the inventory campaigns.
- ```language_modifications```. This is an extensible collection for multi-language setups. 
- ```other_text_modifications```. This is a collection of various, necessary text modifications based on Google Ads' character restrictions

## How do I make sure my setup and code generates high-quality outputs? 

Go through three the layers of dbt models step by step: 

For ```01_staging```, make sure all stage models build without errors and all data tests pass. You can extend tests to your needs.

In ```02_intermediate```, there are two subfolders that need to correctly return intermediate data outputs: 
- ```account_structure``` contains all the account entities and their states, in some cases including statistics to add to the filter model.
- ```feed_transformation``` holds all transformations from extending the product input data into a usable form to aggregate by different attributes. ```int_feed_title_manu_combined.sql``` is the last model on item-level before the transformations happen.

In the ```03_marts``` folder, all the custom aggregations happen, which are then combined to one model with all combinations. All 5 currently supported combinations are condensed into the following models: 
- ```brand_all``` holds all current brands in stock as keywords / adgroups
- ```brand_cat_all``` holds all brand category combinations, e.g. Patagonia jackets.
- ```brand_gender_all``` holds all combinations like Patagonia women.
- ```brand_mod_all``` holds all brand product model combinations, like Patagonia R1.
- ```cat_all``` holds all brand-agnostic category values like down jackets, climbing shoes etc.

In the following steps, the outputs are combined and filtered:
- ```output_all``` is the essential model holding all unioned combinations mentioned above
- ```output_enriched``` adds the data sources suggest API, search console and keyword serving status from the account
- ```output_filtered``` applies where clause filters on the provided additional data to limit the adgroups and keywords to those with reliable search volume.

The main model flow of combinining, enriching and filtering can be seen here in this dbt graph:
<img width="458" alt="image" src="https://user-images.githubusercontent.com/6991865/225435848-4112c8f6-e787-400b-8561-148f030cf1f1.png">

After the ```output_filtered``` model, the marts models branch out into their specific Google Ads entities in the ```bulk_uploads``` subfolder: 
- campaigns, new and status updates
- adgroups
- keywords
- RSAs or responsive search ads
- DSAs or dynamic search ads (still in progress)
- assets (formerly ad extensions)

All subfolders implement the specific bulk upload templates to generate (almost) upload-ready marts models. The final marts tables can either be queried from Google Sheets via Connected Sheets or written into Cloud Storage via a Cloud Function

NOTE that the columns are "almost" upload-ready, as the template expects spaces in the column names, which BigQuery does not allow. The column name change is performed by a cloud function seen below as addon.

## Is there a documentation website that I can explore?

The dbt cloud framework provides a documentation format that is exported to Netlify:
https://inventory-campaigns-bergzeit-demo.netlify.app/#!/overview

## Who are the maintainers of this project? 

- Stephanie Hubert: https://github.com/shubert-bz
- Christopher Gutknecht: https://github.com/ChrisGutknecht

--- 

If you have any further question, please reach out by raising an issue on github or reach out via Linkedin: 
https://www.linkedin.com/in/chrisgutknecht/ 

Happy building and optimizing, 
Chris👋

--- 
 
## ADDON 1: Cloud function to write a BigQuery table to cloud storage

Add these packages to your requirements.txt

```
google-cloud-storage
google-cloud-bigquery
pandas
pandas-gbq
google-auth
```

Python Code: Name the entry function ```write_query_results_to_storage```:
```python
from google.cloud import bigquery
from google.cloud import storage
import json
import pandas as pd
import google.auth


def write_query_results_to_storage(request):
    """
    Entry method to entire logic of parsing request object, executing query and storage write

    Parameters
    ----------
    request : object
        A flask request object containing the parameters project id, table name, bucket and file name

    Returns
    -------
    response_header : tuple
        A flask response header for the invoked cloud function
    """

    # Parsing the request object for the upload parameters
    request = request.get_data()
    try: 
        request_json = json.loads(request.decode())
        print(request_json)
    except ValueError as e:
        print(f"Error decoding JSON: {e}")
        return ("JSON Error", 400)

    project_id = request_json.get('project_id')
    full_table_name = request_json.get('full_table_name')
    bucket_name = request_json.get('bucket_name')
    file_name = request_json.get('file_name')
    columns_renamed =  request_json.get('columns_renamed')

    # Executing the query in BigQuery, returning a dataframe
    query_df = run_query(project_id, full_table_name)
    if columns_renamed: 
        query_df = query_df.rename(columns=columns_renamed)

    # Write dataframe to Cloud Storage
    save_to_storage(query_df, bucket_name, file_name)

    return ('Data written to storage', 200)


def run_query(project_id, full_table_name):
    """
    Builds and executing query to return a dataframe

    Parameters
    ----------
    project_id : string
        The cloud platform project name
    full_table_name : string
        The full string of project id, dataset and table name

    Returns
    -------
    df : object
        A dataframe with the query result
    """

    query = 'select * from `{}`'.format(full_table_name)
    df = pd.io.gbq.read_gbq(query, project_id=project_id, dialect='standard')  

    return df


def save_to_storage(df, bucket_name, file_name):
    """
    Writes the dataframe as a csv file to cloud storage

    Parameters
    ----------
    data : object
        The dataframe resulting from the query
    bucket_name : string
        The name of the cloud storage bucket to write the csv to
    file_name : string
        The file name to be created or overwritten

    Returns
    -------
    None
        No return value
    """

    storage_client = storage.Client()
    bucket = storage_client.get_bucket(bucket_name)
    blob = bucket.blob(file_name)
    df.to_csv('/home/{}'.format(file_name), index=False, encoding='utf-8-sig')
    blob.upload_from_filename('/home/{}'.format(file_name))
    print('Feed uploaded')
```
Invoke the cloud function with an example POST payload like this. All column names need to upper cased and the words spaced. If you apply this method and write to Cloud Storage, fetch the public URL of the file to reference it in the Google Ads bulk upload.

```json
{
  "project_id":"bergzeit",
"full_table_name":"your_project.dbt_feed_campaigns.adgroups_new_upload",
  "bucket_name" : "your_feedcampaign_bulk_upload_bucket",
  "file_name":"adgroups_new_upload.csv", 
  "columns_renamed" : {
    "customer_id" : "Customer ID", 
    "action" : "Action", 
    "campaign" : "Campaign", 
    "ad_group" : "Ad group",
    "ad_group_type" : "Ad group type"
   }
}
```
--- 

## ADDON 2: How to call the Suggest API with a list of unvalidated keywords

Add these packages to your requirements.txt

```
xmltodict
fuzzywuzzy
python-Levenshtein
pandas_gbq==0.19.1
datetime
```

Python Code: Name the entry function ```write_validated_keywords_to_storage```:
```python
import json
import pandas as pd
import pandas_gbq

import requests
import xmltodict
import time
from datetime import date
from fuzzywuzzy import fuzz
from fuzzywuzzy import process


def write_validated_keywords_to_storage(request):
    
    #get variables from request body
    request = request.get_data()
    try: 
        request_json = json.loads(request.decode())
    except ValueError as e:
        print(f"Error decoding JSON: {e}")
        return ("JSON Error", 400)

    #get the specifications of the table the results are written to
    project_id = request_json.get('project_id')
    dataset_name = request_json.get('dataset_name')
    table_name = request_json.get('table_name')
    full_table_name = dataset_name + '.' + table_name

    table_schema = [
        {'name': 'keyword', 'type': 'STRING'},
        {'name': 'validation_status', 'type': 'BOOLEAN'},
        {'name': 'similarity_to_next_validated', 'type': 'FLOAT'},
        {'name': 'validated_keywords', 'type': 'STRING', 'mode':'REPEATED'},
        {'name': 'validated_on_date', 'type': 'DATE'}
        ]

    #get the input keyword list
    sql = request_json.get('sql')
    keywords_df = pd.io.gbq.read_gbq(sql, project_id='bergzeit', dialect='standard')

    print('# of unvalidated keywords')
    print(keywords_df.shape)

    #reduce the amount of keywords sent to the suggest API due to quota limits
    keywords_validated = keywords_df[0:300]
    keywords_validated = keywords_validated.apply(lambda row: validate_keywords_via_suggest_api(row), axis=1)

    # Write the results to BigQuery
    pandas_gbq.to_gbq(keywords_validated, full_table_name, project_id='bergzeit', if_exists='append', table_schema=table_schema)
    return ('Validated keywords written to storage', 200)


#Functions_________________________________________________________________

def validate_keywords_via_suggest_api(row):

    keyword = row['keyword']
    row['similarity_to_next_validated'] = None
    row['validation_status'] = None
    row['validated_keywords'] = None
    row['validated_on_date'] = None

    suggest_api_base_url = 'https://suggestqueries.google.com/complete/search?output=toolbar&hl=de&q='
    request_url = suggest_api_base_url + keyword.replace(' ', '+').replace('-', '+')
    #print(request_url)
    response_content = requests.get(request_url).content.decode('iso8859-1','ignore')
    dict_data = {}

    try:
        dict_data = xmltodict.parse(response_content)

        if dict_data.get('toplevel'):
            validated_keyword_list = dict_data.get('toplevel').get('CompleteSuggestion')
            validation_score_list = []

            if isinstance(validated_keyword_list, list):
                # Find partial full matches via fuzz package
                validation_score_list = [fuzz.partial_ratio(entry.get('suggestion').get('@data').replace(' ', ''), keyword.replace(' ', '')) for entry in validated_keyword_list]
                
                # Sort word order
                token_sorted_list = [fuzz.token_set_ratio(entry.get('suggestion').get('@data'), keyword) for entry in validated_keyword_list]

                # Find fuzzy matches for 90% matching
                fuzzy_match_list = [fuzz.WRatio(entry.get('suggestion').get('@data').replace(' ', ''), keyword.replace(' ', '')) for entry in validated_keyword_list]

                # Full keyword match
                validated_keywords = [entry.get('suggestion').get('@data') for entry in validated_keyword_list]

            # Suggest response only has single entry
            else:
                # Sort keywords and remove spaces
                #print('single_entry')
                base_keyword_no_spaces = keyword.replace(' ', '')
                suggest_keyword_no_spaces = validated_keyword_list.get('suggestion').get('@data').replace(' ', '')
                suggest_keyword = validated_keyword_list.get('suggestion').get('@data')

                validated_keywords = [suggest_keyword] 
                validation_score_list = [fuzz.partial_ratio(suggest_keyword_no_spaces, base_keyword_no_spaces) for entry in validated_keyword_list]
                
                fuzzy_match_list = [fuzz.WRatio(suggest_keyword_no_spaces, base_keyword_no_spaces) for entry in validated_keyword_list]

                token_sorted_list = [fuzz.token_set_ratio(validated_keyword_list.get('suggestion').get('@data'), keyword) for entry in validated_keyword_list]

            if keyword in validated_keywords or 100 in validation_score_list or 100 in token_sorted_list:               
                row['validation_status'] = True
                row['similarity_to_next_validated'] = 100
                row['validated_keywords'] = validated_keywords
                row['validated_on_date'] = date.today()
                
            elif (max(fuzzy_match_list) >= 90 or max(token_sorted_list) >= 90) and keyword not in validated_keywords and 100 not in validation_score_list and 100 not in token_sorted_list: 
                row['validation_status'] = True
                max_match_value = max([max(fuzzy_match_list), max(token_sorted_list)])
                row['similarity_to_next_validated'] = max_match_value
                row['validated_keywords'] = validated_keywords
                row['validated_on_date'] = date.today()
                
            else:
                row['validation_status'] = False
                row['similarity_to_next_validated'] = 0
                row['validated_on_date'] = date.today()
            
        else:
            row['validation_status'] = False
            row['similarity_to_next_validated'] = 0
            row['validated_on_date'] = date.today()

        #print(row['validation_status'])

    except Exception as e:
        row['validation_status'] = False
        row['similarity_to_next_validated'] = 0
        print(e)
        print(response_content)
        print(dict_data)

    return row
```
