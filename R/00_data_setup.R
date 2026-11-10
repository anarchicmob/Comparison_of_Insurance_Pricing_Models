# Load the adjusted Australian automobile insurance dataset used in the thesis.

required_packages <- c("actuaRE", "data.table")
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages) > 0) {
  stop(
    "Install the required packages before running the analysis: ",
    paste(missing_packages, collapse = ", ")
  )
}

data_environment <- new.env(parent = emptyenv())
utils::data("dataCar", package = "actuaRE", envir = data_environment)

if (!exists("dataCar", envir = data_environment, inherits = FALSE)) {
  stop("The actuaRE::dataCar dataset could not be loaded.")
}

cleandata <- data.table::as.data.table(
  data.table::copy(data_environment$dataCar)
)

required_columns <- c(
  "numclaims",
  "claimcst0",
  "exposure",
  "veh_body",
  "veh_age",
  "gender",
  "area",
  "agecat",
  "veh_value"
)

missing_columns <- setdiff(required_columns, names(cleandata))
if (length(missing_columns) > 0) {
  stop(
    "The dataset is missing required columns: ",
    paste(missing_columns, collapse = ", ")
  )
}

categorical_columns <- c("veh_body", "veh_age", "gender", "area", "agecat")
cleandata[, (categorical_columns) := lapply(.SD, as.factor),
          .SDcols = categorical_columns]
cleandata[, numclaims := as.numeric(as.character(numclaims))]

if (any(cleandata$exposure <= 0, na.rm = TRUE)) {
  stop("Policy exposure must be strictly positive.")
}

message(
  "Loaded ", format(nrow(cleandata), big.mark = ","),
  " policies from actuaRE::dataCar."
)

rm(
  data_environment,
  required_packages,
  missing_packages,
  required_columns,
  missing_columns,
  categorical_columns
)

