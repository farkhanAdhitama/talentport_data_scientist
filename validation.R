# ============ Hommer Lemeshow ============
# Load libraries
packages <- c("tidyverse", "glmtoolbox", "caret")
installed <- rownames(installed.packages())
to_install <- setdiff(packages, installed)
if (length(to_install)) install.packages(to_install)
lapply(packages, library, character.only = TRUE)
# Load Data
df <- read.csv("data/credit_scoring.csv")
df <- na.omit(df)
# Hapus kolom tidak relevan
df <- df %>% select(-application_id, -starts_with("leak_col"))
# Ubah target jadi faktor
df$default <- as.factor(df$default)
# Standardisasi fitur numerik
num_cols <- sapply(df_bal, is.numeric)
df_bal[num_cols] <- scale(df_bal[num_cols])
# Fit model logistik
model <- glm(default ~ ., data = df_bal, family = binomial)
# Prediksi dan HL Test
df_bal$pred_prob <- predict(model, type = "response")
hl <- hltest(model, g = 10)


# ============ Calibration Curve ============
# df_bal$bin <- cut(df_bal$pred_prob, breaks = seq(0, 1, 0.1), include.lowest = TRUE)
# cal <- df_bal %>%
#   group_by(bin) %>%
#   summarise(
#     mean_pred = mean(pred_prob),
#     actual = mean(as.numeric(as.character(default)))
#   )

# png("calibration_curve.png", width = 800, height = 600)
# ggplot(cal, aes(x = mean_pred, y = actual)) +
#   geom_line(color = "blue") +
#   geom_point(size = 2) +
#   geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "red") +
#   labs(title = "Calibration Curve (Cleaned)", x = "Predicted Probability", y = "Actual Default Rate") +
#   theme_minimal()
# dev.off()

# ============ Cut-off untuk expected default ≤ 5% ============
cutoff <- 0.05
low_risk <- df_bal %>% filter(pred_prob <= cutoff)

summary_cutoff <- list(
  total = nrow(df_bal),
  low_risk_n = nrow(low_risk),
  low_risk_pct = round(nrow(low_risk) / nrow(df_bal) * 100, 2),
  default_rate_in_low_risk = round(mean(as.numeric(as.character(low_risk$default))) * 100, 2)
)

sink("C_summary.md")
cat("# Cut-off Summary: Expected Default ≤ 5%\n\n")
cat("Total observations:", summary_cutoff$total, "\n")
cat("Low-risk group (≤5%):", summary_cutoff$low_risk_n, 
    "(", summary_cutoff$low_risk_pct, "%)\n")
cat("Actual default rate in this group:", summary_cutoff$default_rate_in_low_risk, "%\n")
sink()