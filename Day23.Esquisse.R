# Using {esquisse} ----
## This script will provide a template for working with the {esquisse}
## package to help you build plots/graphs in R through a GUI-type interface.

# Step 1: Install the Packages ----
## Uncomment and run the following commands; be sure to re-comment out when done.
# install.packages("esquisse")
# install.packages("yarrr")

# install.packages("plotly") # Optional to install

# Step 2: Load the Package ----
library(esquisse)

# Step 3: Load the Data ----
data("pirates", package = "yarrr")

# Step 4: Run the esquisser Command ----
esquisser(
  data = pirates,
  viewer = "browser" # Opens the tool up in your default browser instead of RStudio
)

## NOTE: After running the esquisser command, this will take control of your
## R console until you fully quit the command.