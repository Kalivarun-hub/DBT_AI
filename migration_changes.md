# Matillion → dbt Migration Changes

## Migration Details
- Source: Matillion ETL transformation job `01_RAW_to_SILVER_LAYER.tran.json`
- Target platform: Snowflake
- dbt project: `tpch_demo`
- Total transformation components inventoried: 7 (orchestration/EL components: 0)

## Architecture
- Chosen: layered — confirmed by the migrator. The Matillion raw inputs are represented by existing dbt sources, and the transformation is a staging/silver view.
- Layer/DAG overview: TPCH CUSTOMER, NATION, and REGION sources → `stg_asia_customers`.

## Model decisions
| Model | Materialization | Why |
|---|---|---|
| `stg_asia_customers` | view | The original job creates a view and the joins/filter are inexpensive reference-data transformations. |

## Migration Status
- Final compile: 0 errors, 0 warnings
- Models built / tests passed: 1/1 model; 5/5 model tests passed
- Parity: transformation logic and development output validated; direct legacy-view parity is pending its fully qualified name
- Coverage: 7/7 components mapped and validated = 100%

## Component → dbt Object
| Pipeline component | dbt object | Layer | Validation |
|---|---|---|---|
| `CUSTOMER` | `source('tpch', 'CUSTOMER')` | source | queried |
| `NATION` | `source('tpch', 'NATION')` | source | queried |
| `REGION` | `source('tpch', 'REGION')` | source | queried |
| `Join 0` | `stg_asia_customers` CTE joins | staging | built |
| `Filter 0` | `where regions.r_name = 'ASIA'` | staging | accepted-values test passed |
| `Calculator 0` | `audit_runtime_ist` expression | staging | output previewed |
| `Create View 0` | `stg_asia_customers` | staging | built |

## Snapshots
- None. The job has no Detect Changes/SCD2 component.

## Out of Scope
- None. This export contains only a transformation pipeline.

## Residual
- Legacy production view parity and warehouse-cost comparison require the fully qualified name of Matillion's `VW_ASIA_CUSTOMER` output and its query-history attribution.

## Notes
- `stg_asia_customers` retains all Matillion output fields while applying dbt naming conventions.
- The `audit_runtime_ist` column is evaluated when the view is queried, matching the original dynamic calculator expression.
