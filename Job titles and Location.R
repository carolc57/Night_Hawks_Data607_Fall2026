--
title: "Project 3 Job title and Location"
author: "Night Hawks"
output: html_document
---



library(readr) 
library(RPostgres) 
library(DBI) 
library(tibble) 
library(dbplyr) 
library(tidyverse)
library(ggplot2)

gsearch_jobs <- readr::read_csv("https://raw.githubusercontent.com/carolc57/Night_Hawks_Data607_Fall2026/refs/heads/main/clean_file.csv")

head (gsearch_jobs)

glimpse(gsearch_jobs)

gsearch_salary <- readr::read_csv("https://raw.githubusercontent.com/carolc57/Night_Hawks_Data607_Fall2026/refs/heads/main/salary.csv")

gsearch_salary <- gsearch_salary %>% select(-...1)

glimpse(gsearch_salary)

colSums(is.na(gsearch_jobs))

# Check for missing values

gsearch_jobs %>% 
  summarise( 
    missing_titles = sum(is.na(title)), 
    missing_companies = sum(is.na(company_name)), 
    missing_locations = sum(is.na(location)), 
    missing_skills = sum(is.na(description_tokens))
    )
 # Tthere are 371 missing values in description tokens

# check counts for job titles

gsearch_jobs %>%
  count(title) %>%
  filter(n > 1)

#clean job titles. Standardizing capitalization and remvoing extra spacing

gsearch_jobs <- gsearch_jobs %>%
  mutate(
    title = str_to_title(title),
    title = str_squish(title)
  )

# check for titles containing the following: data, analytics, analyst, machine learning

data_jobs <- gsearch_jobs %>%
  filter(
    str_detect(
      str_to_lower(title),
      "data |analytics|analyst|machine learning"
    )
  )

# table for jobs not posted with above identifying words

other_jobs <- gsearch_jobs %>%
  anti_join(data_jobs, by = "index")

other_jobs %>%
  count(title, sort = TRUE)

# find duplicates and group the job titles together
data_jobs %>%
  count(index) %>%
  filter(n > 1)
  
data_jobs <- data_jobs %>%
  mutate(
    job_group = case_when(
      str_detect(str_to_lower(title), "data scientist") ~ "Data Scientist",
      str_detect(str_to_lower(title), "data analyst") ~ "Data Analyst",
      str_detect(str_to_lower(title), "data engineer") ~ "Data Engineer",
      str_detect(str_to_lower(title), "machine learning") ~ "Machine Learning",
      str_detect(str_to_lower(title), "business intelligence|bi analyst") ~ "Business Intelligence",
      TRUE ~ "Other Data Roles"
    )
  )

data_jobs %>%
  distinct(title) %>%
  arrange(title) %>%
  print(n = 20)

# group job titles into categories

data_jobs <- data_jobs %>%
  mutate(
    job_group = case_when(
      str_detect(str_to_lower(title),
                 "business intelligence|bi analyst") ~ "Business Intelligence & Reporting",
      
      str_detect(str_to_lower(title),
                 "data scientist|predictive analytics") ~ "Data Science & Advanced Analytics",
      
      str_detect(str_to_lower(title),
                 "data engineer|data management|data informatics") ~ "Data Engineering & Management",
      
      str_detect(str_to_lower(title),
                 "clinical|healthcare|claims|compensation|catastrophe") ~ "Specialized / Industry Data Analyst",
      
      str_detect(str_to_lower(title),
                 "business operations|business systems|business/data analyst") ~ "Business & Operations Analyst",
      
      str_detect(str_to_lower(title),
                 "data analyst|client data analyst") ~ "General Data Analyst",
      
      TRUE ~ "Other / Review"
    )
  )

data_jobs %>%
  count(job_group, sort = TRUE)

#plot for job categories

data_jobs %>%
  count(job_group, sort = TRUE) %>%
  ggplot(aes(x = reorder(job_group, n), y = n)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(
    title = "Job Postings by Job Category",
    x = "Job Category",
    y = "Number of Postings"
  ) 
# trying to connect salary to job title

general_analyst <- data_jobs %>%
  filter(job_group == "General Data Analyst",
         !is.na(salary_standardized),
         !is.na(location))

ggplot(general_analyst, aes(x = reorder(location, salary_standardized, FUN = median),
                            y = salary_standardized)) +
  geom_boxplot() +
  coord_flip() +
  labs(
    title = "General Data Analyst Salaries by Location",
    x = "Location",
    y = "Annual Salary ($)"
  )

general_analyst <- data_jobs %>%
  filter(job_group == "General Data Analyst",
         !is.na(salary_standardized),
         !is.na(location)) %>%
  mutate(
    state = str_extract(location, regex("[A-Z]{2}$", ignore_case = TRUE))
  )

view(general_analyst)

# make state names

general_analyst <- general_analyst %>%
  mutate(
    state = str_to_upper(state),
    state = state.name[match(state, state.abb)]
  )

# New plot by state

ggplot(general_analyst, aes(x = reorder(state, salary_standardized, FUN = median),
                            y = salary_standardized)) +
  geom_boxplot() +
  coord_flip() +
  labs(
    title = "General Data Analyst Salaries by Location",
    x = "Location",
    y = "Annual Salary ($)"
  )
