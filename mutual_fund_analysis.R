install.packages("tidyverse")
install.packages("lubridate")
install.packages("DBI")
install.packages("RPostgres")

library(tidyverse)
library(lubridate)
library(DBI)
library(RPostgres)

con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "mutual_fund_analysis",
  host = "localhost",
  port = 5432,
  user = "postgres",
  password = "12345"
)
nav_data <- dbGetQuery(con, "SELECT * FROM mutual_fund_nav_all")

nav_data <- nav_data %>%
  mutate(nav_date = as.Date(nav_date)) %>%
  arrange(fund_name, nav_date)
nav_data <- nav_data %>%
  group_by(fund_name) %>%
  mutate(daily_return = (nav - lag(nav)) / lag(nav)) %>%
  ungroup()
cagr_data <- nav_data %>%
  group_by(fund_name) %>%
  summarise(
    start_nav = first(nav),
    end_nav = last(nav),
    years = as.numeric(difftime(max(nav_date), min(nav_date), units = "days")) / 365,
    CAGR = (end_nav / start_nav)^(1/years) - 1
  )
summary_stats <- nav_data %>%
  group_by(fund_name) %>%
  summarise(
    avg_return = mean(daily_return, na.rm = TRUE),
    std_dev = sd(daily_return, na.rm = TRUE),
    sharpe_ratio = avg_return / std_dev
  )
expense_data <- nav_data %>%
  group_by(fund_name) %>%
  summarise(avg_expense_ratio = mean(expense_ratio, na.rm = TRUE))
final_metrics <- cagr_data %>%
  left_join(summary_stats, by = "fund_name")
risk_return <- nav_data %>%
  group_by(fund_name) %>%
  summarize(
    avg_daily_return = mean(daily_return, na.rm = TRUE),
    sd_daily_return = sd(daily_return, na.rm = TRUE),
    annual_return = avg_daily_return * 252,
    annual_volatility = sd_daily_return * sqrt(252)
  )
if("expense_ratio" %in% colnames(nav_data)) {
  expense_data <- nav_data %>%
    group_by(fund_name) %>%
    summarise(avg_expense_ratio = mean(expense_ratio, na.rm = TRUE))
} else {
  expense_data <- nav_data %>%
    group_by(fund_name) %>%
    summarise(avg_expense_ratio = NA)
}
final_metrics <- cagr_data %>%
  left_join(summary_stats, by = "fund_name") %>%
  left_join(expense_data, by = "fund_name") %>%
  left_join(risk_return, by = "fund_name")
print(final_metrics)
write.csv(final_metrics, "final_metrics.csv", row.names = FALSE)


colSums(is.na(final_metrics))

install.packages("corrplot")
library(corrplot)
numeric_data <- final_metrics %>% select_if(is.numeric)
cor_matrix <- cor(numeric_data, use = "complete.obs")
corrplot(cor_matrix, method = "color", type = "upper", addCoef.col = "black")

library(ggplot2)

ggplot(final_metrics, aes(x = reorder(fund_name, CAGR), y = CAGR, fill = fund_name)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  labs(title = "CAGR by Mutual Fund", x = "Fund Name", y = "CAGR (%)") +
  theme_minimal()
ggplot(final_metrics, aes(x = reorder(fund_name, sharpe_ratio), y = sharpe_ratio, fill = fund_name)) +
  geom_col() +
  coord_flip() +
  labs(title = "Sharpe Ratio by Mutual Fund", x = "Fund Name", y = "Sharpe Ratio") +
  theme_light()
ggplot(final_metrics, aes(x = annual_volatility, y = annual_return, color = fund_name)) +
  geom_point(size = 4) +
  geom_text(aes(label = fund_name), hjust = 0.5, vjust = -1) +
  labs(title = "Risk vs Return", x = "Annual Volatility (Risk)", y = "Annual Return") +
  theme_bw()
ggplot(final_metrics, aes(x = reorder(fund_name, avg_expense_ratio), y = avg_expense_ratio, fill = fund_name)) +
  geom_col() +
  coord_flip() +
  labs(title = "Average Expense Ratio", x = "Fund Name", y = "Expense Ratio") +
  theme_classic()
ggplot(nav_data, aes(x = nav_date, y = nav, color = fund_name)) +
  geom_line() +
  labs(title = "NAV Trend Over Time", x = "Date", y = "NAV") +
  theme_minimal()

install.packages("corrplot", repos = "https://cloud.r-project.org/")

write.csv(nav_data, "nav_data.csv", row.names = FALSE)


