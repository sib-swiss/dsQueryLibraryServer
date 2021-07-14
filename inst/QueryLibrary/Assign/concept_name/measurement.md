# measurement

## Query

```sql
SELECT m_name.concept_name as measurement_name, m_typ.concept_name as measurement_type, m_unit.concept_name as unit, m.*
FROM @cdm.measurement AS m
INNER JOIN @vocab.concept as m_name ON m.measurement_concept_id = m_name.concept_id
INNER JOIN @vocab.concept as m_typ ON m.measurement_type_concept_id = m_typ.concept_id
INNER JOIN @vocab.concept as m_unit ON m.unit_concept_id = m_unit.concept_id
	
```

