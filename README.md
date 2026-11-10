# Comparing Insurance Pricing Models

This project compares classical actuarial and machine-learning approaches for automobile insurance pricing. The objective is to estimate **pure premium**: the expected claim cost per unit of policy exposure.

Two modeling strategies are explored:

1. **Frequency-severity modeling**, where claim frequency and average claim severity are estimated separately and multiplied.
2. **Direct aggregate-loss modeling**, where annualized claim cost is predicted in one step with a compound Poisson-Tweedie model.

The experiments compare generalized linear models (GLMs), Tweedie regression, and XGBoost under three treatments of categorical risk factors: dummy encoding, target encoding, and learned entity embeddings.

> This repository contains the modeling work developed from my master's thesis. A longer discussion is available in the [project documentation](https://persistent-valley-d67.notion.site/Insurance-Pricing-Models-Documentation-Analysis-25b92083189180678bbcd407dab86ce8?source=copy_link).

## Actuarial formulation

For policy characteristics `x`, the frequency-severity approach estimates:

```text
Expected pure premium(x)
    = Expected claim frequency(x) × Expected claim severity(x)
```

- **Frequency** measures the expected number of claims per unit of exposure.
- **Severity** measures the expected cost of one claim, conditional on a claim occurring.
- **Exposure** represents the fraction of the year for which a policy was active.

Separating the two components allows the models to account for the large number of zero-claim policies while using positive-claim policies to learn claim size.

## Dataset

The analysis uses the adjusted Australian automobile insurance `dataCar` dataset, available from the R package [`actuaRE`](https://cran.r-project.org/package=actuaRE). The dataset contains **67,566 one-year motor policies**, of which **4,589 (6.8%)** recorded at least one claim.

The original policies were written in 2004 or 2005. The adjusted version removes extreme loss ratios and vehicle-body categories with insufficient total exposure. The data originates from De Jong and Heller's *Generalized Linear Models for Insurance Data*.

| Variable | Description |
| --- | --- |
| `numclaims` | Number of claims reported by the policy |
| `claimcst0` | Total claim amount; zero when no claim occurred |
| `exposure` | Fraction of the year for which the policy was active |
| `veh_body` | Vehicle body type |
| `veh_age` | Vehicle-age category |
| `gender` | Policyholder gender |
| `area` | Policyholder area of residence |
| `agecat` | Policyholder age category |
| `veh_value` | Vehicle value in units of AUD 10,000 |

The raw data is not committed to this repository. `R/00_data_setup.R` loads the reproducible public version directly from `actuaRE` and prepares the categorical variables used by the models.

## Models

| Approach | Frequency component | Severity or aggregate-loss component |
| --- | --- | --- |
| Poisson-Gamma GLM | Poisson GLM with log link and `log(exposure)` offset | Gamma GLM with log link, fitted on positive-claim policies |
| Compound Poisson-Tweedie | Modeled directly | Compound Poisson GLM fitted to aggregate claim cost |
| XGBoost | `count:poisson` objective | `reg:gamma` objective fitted on positive-claim policies |

The XGBoost models use a learning rate of `0.01`, maximum tree depth of `4`, row and feature subsampling of `0.7`, and early stopping.

## Categorical-variable representations

### Dummy encoding

Categorical levels are represented as indicator variables. This provides an interpretable baseline and is the standard treatment used by the GLMs.

### Target encoding

Each category is replaced by a numeric summary derived from the response or category distribution. Smoothing is used for vehicle-body categories to reduce instability in small groups.

### Entity embeddings

Small neural networks learn three-dimensional representations of vehicle body, vehicle age, area, and policyholder age category. The learned coordinates are then used as numerical inputs to the pricing models.

## Experimental design

- Random seed: `123`
- Training set: `70%`
- Test set: `30%`
- Frequency models: all policies
- Severity models: policies with at least one claim
- Main evaluation metric: root mean squared error (RMSE)
- Additional XGBoost metric: mean absolute error (MAE)

### Recorded GLM results

The values below are the results recorded in the current GLM script. Pure-premium RMSE is evaluated on the positive-claim test subset used by the severity model.

| Encoding | Frequency RMSE | Severity RMSE | Pure-premium RMSE |
| --- | ---: | ---: | ---: |
| Dummy | 7.6636 | 3,291.17 | 28,185.93 |
| Target | 7.6637 | 3,285.02 | 28,185.92 |
| Entity embedding | 7.6636 | 3,289.60 | 28,186.08 |

The three encodings produced almost identical GLM pure-premium RMSE in this experiment. Tweedie and XGBoost metrics should be regenerated from the scripts before making a cross-model performance claim.

## Repository structure

```text
.
|-- R/
|   `-- 00_data_setup.R     Load and prepare the public dataset
|-- baseline(glm).R         Poisson-Gamma GLMs and encoding experiments
|-- tweedie.R               Compound Poisson-Tweedie models
|-- xgb.R                   XGBoost frequency and severity models
|-- run_analysis.R          Run the scripts in their required order
`-- README.md
```

## Requirements

The project uses R 4.x and the following packages:

```r
install.packages(c(
  "actuaRE",
  "data.table",
  "ggplot2",
  "tweedie",
  "cplm",
  "xgboost",
  "keras"
))
```

The entity-embedding experiment additionally requires a working Keras/TensorFlow backend.

## Running the analysis

From the repository root, run:

```r
source("run_analysis.R")
```

The scripts currently run in sequence because the Tweedie and XGBoost experiments reuse the train-test split and encoded variables created by `baseline(glm).R`.

## Current limitations

- The scripts reflect the original thesis workflow and are not yet independent modules.
- The target-encoding and entity-embedding XGBoost sections are incomplete in the public script.
- Model evaluation is not yet standardized on one common holdout sample across every approach.
- Results are based on one random split rather than repeated cross-validation.

Planned improvements include fitting all encoders exclusively on training data, introducing a separate validation split for early stopping, exporting a common results table, and adding repeated out-of-sample evaluation.

