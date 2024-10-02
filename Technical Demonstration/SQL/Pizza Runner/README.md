This project involves analyzing and cleaning the Pizza Runner dataset, followed by solving several use cases using SQL queries. Below is an overview of the tables and the tasks performed:

Database Schema:

-> runners: runner_id, registration_date

-> customer_orders: order_id, customer_id, pizza_id, exclusions, extras, order_time

-> runner_orders: order_id, runner_id, pickup_time, distance, duration, cancellation

-> pizza_names: pizza_id, pizza_name

-> pizza_recipes: pizza_id, toppings

-> pizza_toppings: topping_id, topping_name


Data Cleaning

-> Pizza Recipes: Cleaned toppings from comma-separated values to row-wise data.

-> Runner Orders: Handled NULL values and corrected data formats (e.g., converting 20.0 km to integers in distance, and 12 mins to integers in duration).

Key Use Cases Solved:

-> Total number of pizzas and unique customer orders.

-> Successful deliveries by each runner.

-> Analysis of pizza types (Vegetarian vs Meat Lovers) ordered by customers.

-> Time-based analysis (orders per hour, day of the week).

-> Runner performance metrics: average delivery time, distance traveled, speed trends, and successful delivery percentage.

-> Ingredient analysis: most common exclusions, extras, and the total quantity of ingredients used.

-> Financial insights: revenue and cost analysis with and without delivery fees and charges for extras.
