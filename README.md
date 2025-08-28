# Car Insurance Pricing – Frequency-Severity Modeling
This repository contains the code and analysis for a car insurance pricing project, focusing on predicting pure premium by modeling claim frequency and claim severity separately.

🔍 The project compares multiple modeling techniques and encoding strategies for handling categorical variables, including:

- Dummy Encoding
- Target Encoding
- Entity Embedding

> 🔧 **This project is derived from my master’s thesis.**

## Documentation
Full documentation is hosted on **Notion**:  
👉 [Insurance Pricing Models — Documentation & Analysis](https://persistent-valley-d67.notion.site/Insurance-Pricing-Models-Documentation-Analysis-25b92083189180678bbcd407dab86ce8?source=copy_link)

## Evaluation Metrics
- RMSE (Root Mean Squared Error)

## Dataset

The dataset contains **67,566 observations** with the following key variables:

| Variable     | Description                                              |
|--------------|----------------------------------------------------------|
| `numclaims`  | Number of claims filed                                   |
| `claimcst0`  | Total claim amount (0 if no claim)                       |
| `exposure`   | Fraction of year the policy was active (0–1)             |
| `veh_body`   | Type of vehicle body                                     |
| `veh_age`    | Age of vehicle (1–4)                                     |
| `gender`     | Gender of policyholder (`F`, `M`)                        |
| `area`       | Area of residence (`A`–`F`)                              |
| `agecat`     | Age category of policyholder (1–6)                       |
| `veh_value`  | Value of vehicle (in $10,000s)                           |

> Additional variables like `clm` and `VehicleType` are not used in modeling.

## Models Compared

We evaluated the following modeling approaches:

- **Generalized Linear Models (GLM)**  
- **Tweedie Regression**  
- **XGBoost**

Each model was tested with all three encoding strategies.
  
## Evaluation Metrics
- RMSE (Root Mean Squared Error)

## Key Takeaways

- **XGBoost with Target Encoding** yielded the lowest RMSE.
- **Entity Embedding** performed competitively and may outperform traditional encoding on complicated datasets.

