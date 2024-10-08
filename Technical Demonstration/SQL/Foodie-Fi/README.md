Foodie-Fi Subscription Analysis

This project focuses on analyzing customer subscription data for Foodie-Fi, a video streaming service. The analysis explores customer sign-up behavior, plan upgrades, downgrades, and churn rates. The project utilizes SQL queries to extract insights from customer subscription and plan data.

Data Overview
The dataset consists of two main tables:

1) plans: This table contains information about the various subscription plans offered by Foodie-Fi:

- Basic Plan: Limited streaming access, priced at $9.90/month.

- Pro Plan: Unlimited streaming and offline downloads, priced at $19.90/month or $199/year.

- Free Trial: A 7-day free trial that transitions to the Pro plan unless canceled, downgraded to Basic, or upgraded to an annual Pro plan during the trial period.

- Churn Plan: Customers who cancel their service have a churn plan with no price, but their current plan continues until the end of the billing period.

2) subscriptions: This table tracks customer subscriptions, detailing the plan_id and the exact start date of each plan for every customer. It also captures changes in plan due to upgrades, downgrades, or cancellations, reflecting when the actual plan takes effect.

Project Objectives: The goal of this project is to derive key insights and patterns from the subscription data using SQL queries. The analysis addresses the following areas:

- Customer Growth: Identify the total number of customers who have signed up for Foodie-Fi.

- Plan Distribution: Analyze the monthly distribution of free trial sign-ups, and study the evolution of subscription plans over time.

- Churn Analysis: Calculate the churn rate, customer retention, and patterns of plan downgrades or cancellations.

- Upgrade Behavior: Track the number of customers upgrading to annual plans and determine how long, on average, it takes for a customer to upgrade from their initial plan.

- Plan Breakdown: Examine the distribution of all plan types as of specific dates (e.g., 2020-12-31) and study customer transitions between different plans.

- Customer Tenure and Churn: Analyze customer tenure, determine if they are still subscribed or have churned, and calculate month-on-month churn rates.

SQL Queries and Solutions: A series of SQL queries were developed to answer critical business questions, including:

- Total customer count and monthly distributions of plan sign-ups.

- Breakdown of customer plans and churn rates over time.

- Analysis of customer upgrades, downgrades, and transitions between plans.

- Time-to-upgrade analysis, providing insights into customer behavior.

- Month-on-month churn rate calculations and customer tenure tracking.
