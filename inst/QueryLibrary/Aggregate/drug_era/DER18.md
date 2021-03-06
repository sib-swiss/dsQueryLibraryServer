<!---
Group:drug era
Name:DER18 Distribution of age, stratified by drug
Author:Patrick Ryan
CDM Version: 5.3
-->

# DER18: Distribution of age, stratified by drug

## Description
This query is used to provide summary statistics for the age across all drug era records stratified by drug (drug_concept_id): the mean, the standard deviation, the minimum, the 25th percentile, the median, the 75th percentile, the maximum and the number of missing values. The age value is defined by the earliest exposure. The input to the query is a value (or a comma-separated list of values) of a drug_concept_id. If the input is omitted, age is summarized for all existing drug_concept_id values.

## Query
```sql
WITH parms as (select cid as cid  from unnest(regexp_split_to_array( nullif($1::text, '')::text, '\s*,\s*')) as cid)
SELECT drug_concept_id
,      min_value
,      max_value
,      avg_value
,      MIN(CASE WHEN order_nr < .25 * population_size THEN 9999 ELSE stat_value END)::numeric AS percentile_25
,      MIN(CASE WHEN order_nr < .75 * population_size THEN 9999 ELSE stat_value END)::numeric AS percentile_75
,      MIN(CASE WHEN order_nr < .50 * population_size THEN 9999 ELSE stat_value END)::numeric AS median_value
FROM (
         SELECT tt.drug_concept_id
         ,      tt.stat_value
         ,      cast(MIN(tt.stat_value) OVER (partition by tt.drug_concept_id) as integer) AS min_value
         ,      cast(MAX(tt.stat_value) OVER (partition by tt.drug_concept_id) as integer) AS max_value
         ,      cast(AVG(tt.stat_value) OVER (partition by tt.drug_concept_id) as integer) AS avg_value
         ,      ROW_NUMBER() OVER (PARTITION BY tt.drug_concept_id ORDER BY tt.drug_concept_id, tt.stat_value) order_nr
         ,      population_size
         FROM (
                  SELECT date_part('year', (min(t1.drug_era_start_date) over (partition by t1.person_id, t1.drug_concept_id))) - p1.year_of_birth as stat_value
                  ,      t1.drug_concept_id
                  FROM @cdm.drug_era t1,
                       @cdm.person p1
                  WHERE t1.person_id = p1.person_id
                    AND t1.drug_concept_id in (select cid::integer from parms)
              ) tt
         INNER JOIN (
             SELECT t2.drug_concept_id
             ,      COUNT(t2.drug_concept_id)::integer as population_size
             FROM @cdm.drug_era t2,
                  @cdm.person p2
             WHERE t2.person_id = p2.person_id
               AND t2.drug_concept_id in (select cid::integer from parms)
             GROUP BY t2.drug_concept_id
         ) population_sizes
         ON tt.drug_concept_id = population_sizes.drug_concept_id
     ) ordered_data
GROUP BY ordered_data.drug_concept_id
,        min_value
,        max_value
,        avg_value
```

## Input

|  Parameter |  Example |  Mandatory |  Notes |
| --- | --- | --- | --- |
| list of concept_id | 1300978, 1304643, 1549080 | Yes |   |

## Output

|  Field |  Description |
| --- | --- |
| Drug_concept_id | Unique identifier for drug |
| Min_value | Minimum number of drug era records for drug |
| Max_value | Maximum number of drug era records for drug |
| Avg_value | Average number of drug era records for drug |
| percentile_25_date | 25th percentile number of drug era records for drug |
| median_date | Median number of drug era records for drug |
| percentile_75_date | the 75th percentile number of drug era records for drug |

## Example output record

|  Field |  Description |
| --- | --- |
| Drug_concept_id | 1304643 |
| Min_value | 0 |
| Max_value | 108 |
| Avg_value | 69 |
| percentile_25_date | 59 |
| median_date | 70 |
| percentile_75_date | 80 |

## Documentation
https://github.com/OHDSI/CommonDataModel/wiki/
