# observation

## Description
This query loads the "procedure_occurrence" table and adds a few useful columns  by joining it to the concept table.

## Query

```sql
FROM @cdm.procedure_occurrence AS p 
INNER JOIN @vocab.concept as p_name ON p.procedure__concept_id = p_name.concept_id
INNER JOIN @vocab.concept as p_type ON p.procedure_type_concept_id = p_type.concept_id

	
```
