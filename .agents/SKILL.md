---
name: matillion-to-dbt-wizard
description: Convert Matillion orchestration and transformation JSON exports into complete dbt implementations in an existing repository. Use for inventory, generation, updates, dependency reuse, validation, reconciliation, or troubleshooting. Discover and follow the target project's conventions rather than assuming one fixed layout.
metadata:
  version: 1.2.0
  author: Data Engineering
  last_updated: 2026-09-02
---

# Matillion to dbt Wizard

## Contents
- [Rule precedence](#rule-precedence)
- [Example invocations](#example-invocations)
- [Discover project context](#discover-project-context)
- [Locate and parse inputs](#locate-and-parse-inputs)
- [Inventory and reconcile](#inventory-and-reconcile)
- [Folders and naming](#folders-and-naming)
- [Dependency reuse](#dependency-reuse)
- [Preserve transformation behavior](#preserve-transformation-behavior)
- [Matillion Python and script components](#matillion-python-and-script-components)
- [Configuration, variables, and exports](#configuration-variables-and-exports)
- [Error recovery](#error-recovery)
- [Model-first validation and execution](#model-first-validation-and-execution)
- [Completion report](#completion-report)

## Purpose
Convert Matillion JSON exports into complete, maintainable dbt implementations. The Matillion export is the source of truth for transformation behavior. The target repository is the source of truth for dbt structure and implementation conventions.

Build every required model first. Attempt execution when possible, but do not leave model files incomplete because credentials, permissions, ownership, connectivity, or warehouse access are unavailable.

## Rule precedence
When instructions conflict, use this order:
1. Preserve source business logic and output behavior from the Matillion export.
2. Prevent data loss, missing transformations, duplicate ownership, and unsafe overwrites.
3. Follow explicit user requirements for the current conversion.
4. Follow the target repository's established conventions and contracts.
5. Reuse verified shared/core assets.
6. Apply this skill's defaults only when the project has no governing convention.
7. Prefer maintainability or optimization only after faithful conversion is complete.

A repository convention may change folder placement, naming, materialization, or formatting. It must not silently change joins, filters, calculations, grain, null handling, or other business behavior. If faithful behavior and a repository constraint cannot both be satisfied, stop the affected node, document the conflict, and mark it `Blocked` or `Manual Review Required`.

## Example invocations

```text
Use the matillion-to-dbt-wizard skill to convert SALES_DAILY. Find the matching Matillion JSON in the repository, include all child jobs, follow the current project's conventions, and build every relation-producing model.
```

```text
Convert inputs/ORCH_CUSTOMER_ACTIVITY.json to dbt. Preserve SQL and calculations exactly, reuse verified shared-package models, update existing canonical models in place, and attempt dbt build after structural validation.
```

```text
Reconcile the BILLING_MONTH_END Matillion job against the current dbt project. Identify missing transformations, create or update the missing models, and report anything blocked by malformed input, circular dependencies, model collisions, or warehouse permissions.
```

## Discover project context
Before generating files, inspect:
- `dbt_project.yml` and configured model paths
- dependency files and installed packages
- existing model, source, macro, test, contract, tag, and snapshot conventions
- database/schema routing and materializations
- naming and folder patterns by domain and layer
- project variables and environment-variable patterns
- export or unload macros
- available parse, compile, run, test, and build commands
- any established migration pipeline, documentation, templates, logs, and summaries

Do not assume fixed folders such as `PRODUCTION`, `OPERATIONS`, `ELT_TRANSFORMATION`, or `DATAMARTS`. Do not assume prefixes such as `INT_` or `FCT_`. Follow the target project when a clear convention exists. If no convention exists, choose a simple consistent structure, document it, and avoid inventing unnecessary layers.

## Locate and parse inputs
Use the JSON path supplied by the user. If only a job name is supplied, search reasonable project-defined locations, including:
- `seeds/matillion_to_dbt/`
- `mat_input/`
- `migration_inputs/`
- `inputs/`
- another documented migration folder

Do not treat JSON stored under `seeds/` as dbt seed data unless the project explicitly requires it.

Select the root orchestration and include every available direct and transitive child job. Parse minified JSON locally. Do not require formatting changes when the file is readable.

If the repository has an existing migration pipeline, use it when helpful. Treat generated artifacts as drafts until reconciled with the canonical repository.

## Inventory and reconcile
Before editing canonical models, inventory every:
- root orchestration, child job, and branch
- relation-producing transformation and final target
- source relation and dependency edge
- variable and dynamic SQL token
- pre-SQL and post-SQL operation
- unload or export operation
- external-orchestration-only component
- unknown or unsupported component

For each relation-producing transformation record:
- original component name
- expected dbt node name
- target relation
- destination layer/folder
- upstream dependencies
- candidate shared/core or local equivalent
- equivalence evidence when reused
- final status

Allowed statuses:
- Created locally
- Updated locally
- Already current locally
- Reused from shared/core project with evidence
- Not relation-producing, with reason
- Blocked, with exact reason

Enforce:

```text
Total relation-producing JSON transformations
= Created locally
+ Updated locally
+ Already current locally
+ Reused with evidence
+ Blocked with exact reason
```

No relation-producing transformation may disappear from the inventory. Unexplained missing transformations must equal zero.

## Folders and naming
Follow the target project's configured paths and nearby canonical models. Determine placement from transformation purpose, domain, and published target, not merely from orchestration name.

Valid patterns may include:

```text
models/PRODUCTION/ELT_TRANSFORMATION/<DOMAIN>/<TARGET>/
models/PRODUCTION/DATAMARTS/<DOMAIN>/<TARGET>/
```

or:

```text
models/staging/<source>/
models/intermediate/<domain>/
models/marts/<domain>/
```

If a branch does not produce a published fact, dimension, mart, or equivalent final relation, create only the required transformation models. Do not create artificial wrappers.

Use the target project's naming convention. When the project requires Matillion names to be retained, a common rule is:

```text
TRANS_<remaining_name> -> INT_<remaining_name>
```

Keep final target names unchanged when required. Do not rename CTEs, aliases, columns, business terms, or suffixes merely for readability. Use `alias` only when needed to preserve a required physical target name.

## Dependency reuse
Use the target project's preferred dependency order. Recommended default:
1. Verified exact model in an installed shared/core project.
2. Verified canonical model in the current project.
3. Existing declared dbt source.
4. New local model only when no correct reusable dependency exists.

Verify candidates through repository search, dependency files, installed packages, manifests, and dbt discovery. Use `ref()` for dbt models and `source()` only for declared sources. Use package-qualified `ref()` only when required and supported.

A downstream shared/core model does not automatically replace upstream Matillion transformations. Mark `Reused with evidence` only when the candidate is addressable and equivalent in grain, columns, joins, filters, calculations, null behavior, and business rules, and reuse does not remove a branch-specific dependency.

Never infer equivalence from names alone. If a shared target exists but upstream JSON transformations are unique, build those transformations. If faithful local creation would collide with shared ownership, mark the node `Blocked` or `Manual Review Required` rather than silently skipping, renaming, or duplicating it.

## Preserve transformation behavior
Preserve:
- active SQL structure and statement order
- CTE names and aliases
- selected columns and output grain
- join type, order, conditions, and predicates
- filters and qualification logic
- expressions, calculations, aggregations, and grouping
- window functions and partitions
- union and distinct semantics
- casts, types, null handling, and defaults
- ordering, timestamps, and time-zone behavior
- latest-record and snapshot selection
- sequence, pivot, rank, transpose, deduplication, and change-detection behavior
- parameter-grid mappings and component settings that generate SQL behavior

Do not optimize, simplify, condense, or refactor business logic during faithful conversion. Generated SQL is a draft until reconciled with the source component.

Permitted compatibility changes:
1. Replace model dependencies with `ref()`.
2. Replace declared sources with `source()`.
3. Remove target-writing syntax replaced by dbt materialization while preserving query behavior.
4. Convert variables to the project's approved pattern.
5. Add materialization, alias, tags, tests, contracts, and hooks required by source behavior or repository convention.
6. Apply the minimum adapter-specific syntax changes without changing semantics.

Operational audit updates, notifications, fan-out, and failure connectors may be excluded when the user scopes work to relation-producing logic. Document the exclusion. Never use that exclusion to hide SQL-bearing transformations.


## Matillion Python and script components
Treat Matillion Python Script, Bash Script, command, API, file-processing, and other executable-code components as first-class migration inputs. Preserve their functionality, inputs, outputs, control conditions, error behavior, side effects, and dependency order. Adapt the implementation to dbt standards without changing what the component does.

For every executable-code component, inventory:
- component name and type
- complete source code or command text
- interpreter/runtime and required libraries
- input variables, environment variables, secrets, and credentials
- upstream tables, files, APIs, and parameters
- output tables, files, API calls, logs, and status values
- transaction, retry, exception, and failure behavior
- execution conditions and downstream dependencies
- network, filesystem, package, and platform assumptions

Classify the component before converting:

1. **SQL-producing transformation**: If Python only constructs or executes deterministic SQL that can be represented safely in dbt, translate the resulting transformation into a dbt SQL model, macro, test, snapshot, seed, or hook. Preserve the generated SQL behavior exactly.
2. **Reusable deterministic logic**: If Python implements reusable deterministic transformations suitable for the target dbt adapter, convert it to the project's approved dbt abstraction, such as a macro or supported Python model. Use a dbt Python model only when the target platform, adapter, repository, and deployment process explicitly support Python models.
3. **Validation or data-quality logic**: Convert assertions and checks into dbt tests, singular tests, generic tests, contracts, or audit models when semantics can be preserved.
4. **Pre-run or post-run behavior**: Convert to a pre-hook, post-hook, on-run-start, on-run-end, or operation macro only when dbt execution semantics can preserve the same behavior and ordering.
5. **External side effect or orchestration**: Keep API calls, notifications, file movement, shell commands, service invocation, secret rotation, and other non-warehouse side effects in the appropriate external orchestrator unless the target project has an approved dbt mechanism.
6. **Unsupported or ambiguous behavior**: Preserve the original code and metadata, convert unaffected dependencies, and mark the component `Manual Review Required`. Do not guess.

### Python fidelity rules
- Preserve algorithms, branching, loops, filters, mappings, calculations, ordering, default values, data types, and error handling.
- Preserve input and output contracts, including table grain, file format, API payloads, path conventions, and expected status values.
- Do not replace Python with SQL solely for consistency unless equivalence is demonstrated.
- Do not convert external side effects into a dbt model merely to keep all logic inside dbt.
- Do not embed secrets, credentials, tokens, or environment-specific endpoints in models or macros. Reuse the project's approved environment variables, secret manager, profiles, or orchestration configuration.
- Do not introduce new libraries or network dependencies without repository approval.
- Do not retain Matillion-specific runtime calls when dbt cannot execute them. Isolate them behind a documented external boundary.
- Preserve comments that explain non-obvious business behavior. Remove only Matillion boilerplate that has no functional effect.

### Python conversion evidence
For each Python/script component, record:
- original component and code location
- selected target implementation type
- why that target is appropriate
- input/output mapping
- dependency mapping
- variables and secrets mapping
- behavior preserved
- behavior intentionally moved to external orchestration
- validation performed
- remaining manual work

Allowed statuses:
- Converted to dbt SQL model
- Converted to dbt Python model
- Converted to macro
- Converted to test or audit model
- Converted to hook or operation
- Retained in external orchestration
- Reused from existing implementation with evidence
- Manual Review Required
- Blocked

### Python validation
When execution is available, compare the Matillion component and converted implementation using appropriate evidence such as:
- row counts and schema
- column-level values and null behavior
- checksums or deterministic samples
- generated SQL comparison
- file names, formats, and record counts
- API request structure without exposing secrets
- expected exceptions, retries, and exit statuses

When execution is unavailable, perform static reconciliation of code paths, inputs, outputs, dependencies, variables, imports, and side effects. Mark the result `Structurally Reconciled, Execution Not Validated`.

Python conversion must follow the same rule precedence as SQL conversion: preserve functionality first, then adapt packaging, naming, placement, configuration, and execution to the target project's dbt standards.

## Configuration, variables, and exports
Use inherited project configuration and nearby canonical models first. Do not copy example materializations blindly. Determine table, view, incremental, ephemeral, unique key, merge, truncate, alias, hook, contract, and test behavior from source semantics and repository conventions.

Before generating an unload/export, inspect project and package variables, environment-variable patterns, export macros, and similar models. Reuse semantically correct bucket, folder, stage, path, prefix, or connection variables. Do not hardcode environment-specific values when configurable patterns exist.

If no suitable variable exists:
1. Add a meaningful variable in the established namespace.
2. Follow existing environment-driven patterns.
3. Reference the new variable through the approved helper.
4. Document required environment inputs.
5. Avoid duplicate variables for the same resource.
6. If the value is unknown, mark `Manual Configuration Required` rather than inventing it.

Attach an export hook to the producing model when supported. Otherwise retain the export in the appropriate external orchestrator and document the boundary.

## Error recovery
Handle errors without abandoning the complete model inventory.

### Malformed or unreadable JSON
- Capture the parser error and file location.
- Validate encoding and JSON syntax.
- If repair is unambiguous, create a temporary normalized copy without altering source semantics.
- Never overwrite the source export automatically.
- If repair is ambiguous, mark the input `Blocked` and report the exact malformed section.

### Missing child exports
- Continue inventorying available jobs.
- Mark all dependencies relying on the missing child as `Blocked` or `Partial`.
- Do not fabricate the missing transformation or claim complete coverage.

### Circular dependencies
- Detect and report the exact cycle.
- Determine whether the cycle is orchestration control flow, mutable-table behavior, or a true model dependency.
- Do not generate circular `ref()` chains.
- Preserve faithful SQL for unaffected nodes.
- Mark the affected cycle for redesign/manual review and suggest a project-appropriate break such as snapshot, seed, source boundary, incremental state, or orchestration step only when supported by the source behavior.

### Conflicting source and target conventions
- Apply the Rule precedence section.
- Preserve source business behavior first.
- Adapt non-semantic elements such as path, naming, formatting, and materialization where possible.
- If a target convention would change grain, calculations, filtering, ordering, or output contract, stop the affected node and document the conflict.

### Duplicate model or physical-relation ownership
- Locate all owners and package nodes.
- Do not silently rename or overwrite.
- Reuse an exact equivalent with evidence or mark the collision `Blocked`.

### Unsupported or unknown components
- Preserve all available metadata and parameters.
- Do not guess implementation behavior.
- Convert unaffected components and mark the unknown component `Manual Review Required`.

### Validation or execution failures
- Classify the failure as generated-code, dependency, configuration, permissions, ownership, connectivity, or environment related.
- Fix only conversion-caused defects automatically.
- Do not alter business logic to bypass environment failures.
- Continue building remaining independent models.

## Model-first validation and execution
Priority order:
1. Complete inventory.
2. Build/update all model files and folders.
3. Preserve source behavior.
4. Resolve dependencies, configuration, variables, and hooks.
5. Reconcile every transformation.
6. Run structural validation.
7. Attempt warehouse execution.
8. Report blockers without leaving models incomplete.

Use project-supported commands. For standard dbt projects, attempt:

```text
dbt parse
dbt ls --select <complete_selector_set>
dbt compile --select <complete_selector_set>
dbt build --select <complete_selector_set>
```

If execution is blocked by credentials, permissions, relation ownership, connectivity, unavailable dependencies, or environment conditions:
- finish every possible model
- run all available structural checks
- report the exact blocker
- provide the exact manual command
- mark `Models Built, Execution Not Validated`
- do not claim warehouse validation

Completion statuses:
- Models Built and Warehouse Validated
- Models Built and Structurally Validated
- Models Built, Execution Not Validated
- Models Partially Built
- Blocked

## Secondary consistency check
After generation and validation:
1. Compare source inventory with normalized/planning artifacts.
2. Compare planned inventory with canonical files.
3. Compare canonical files with dbt discovery.
4. Compare discovery with compile/build results.
5. Confirm reuse evidence.
6. Confirm every calculation-bearing transformation is implemented or proven equivalent.
7. Reconcile blocked, external-only, manual-review, skipped, failed, omitted, and unmatched items.
8. Confirm every referenced variable exists.

Do not declare completion until unexplained missing transformations, targets, branches, child jobs, refs, sources, and variables equal zero.

## Completion report
Return:
- input files and root orchestration
- child jobs included and missing
- excluded operational components
- branches and migration classification
- complete transformation inventory and statuses
- models created, updated, already current, reused, and blocked
- reuse evidence and unresolved dependencies
- canonical folders and dependency flow
- sources, aliases, physical targets, hooks, and exports
- variables reused, created, or requiring configuration
- unknown or unsupported components
- pipeline and validation commands used
- structural and warehouse validation results
- exact errors, blockers, omissions, and unresolved items

## Prohibited behavior
- Do not create placeholder or condensed SQL and call it complete.
- Do not create unrequested helper models.
- Do not rename models or aliases merely for readability.
- Do not skip upstream transformations because a shared project owns a downstream target.
- Do not infer equivalence from names alone.
- Do not force one repository's layout or variable namespace onto another.
- Do not hardcode environment-specific export values when configurable patterns exist.
- Do not report completion with missing transformations or required child jobs.
- Do not report compile as warehouse execution.
- Do not leave models incomplete because execution is blocked.
- Do not hide manual-review items, malformed inputs, cycles, unknown components, unresolved variables, Python side effects, unsupported runtimes, collisions, or omissions.

## Final rule
Adapt to the target project while preserving Matillion behavior. Build every required dbt model first. Reuse assets only when exact equivalence is verified. Attempt execution when possible; otherwise complete the models, run available structural validation, document blockers, and provide manual commands. Completion requires every relevant SQL or Python transformation, target, branch, dependency, reuse decision, variable, side effect, and export operation to have a canonical implementation or documented exception, with zero unexplained gaps.
