# What:software
#When Octuber 16
# where library UM
#Who Pamela
# packages
install.packages('RSQLite')

library(RSQLite)

conn <- dbConnect(SQLite(), dbname="/Users/marschmi/Desktop/survey.sqlite")

tables <- dbListTables(conn)
tables

class(tables)

surveys <- dbGetQuery(conn, 'SELECT * FROM surveys')
head(surveys)
summary(surveys)
surveys <- dbGetQuery(conn, 'SELECT * FROM surveys
                      JOIN species ON surveys.species_id = species.species_id
                      JOIN plots ON surveys.plot_id = plots.plot_id;')

dbDisconnect(conn)
rm(conn)

surveys <- read.csv("~/Desktop/ecology.csv")

class(surveys)

x1 <- c(1, 2, 3)
class(x1)
typeof(x1) # Double precision is the default in R, unlike SQL!

x2 <- c("a", "b", "c")

head(surveys["year"])

surveys$sex
nlevels(surveys$sex) # how many factor levels?

spice <- factor(c("low", "medium", "low", "high"))
nlevels(spice)

spice <- ordered(c("high", "medium", "low"))
nlevels(spice)
max(spice)

?factor

tabulation <- table(surveys$taxa)
tabulation

barplot(tabulation)

my_taxa <- ordered(surveys$taxa, 
                   levels = c("Rodent", "Bird", "Rabbit", "Reptile"))
barplot(table(my_taxa))


#Cross tabultion
table(surveys$year, surveys$taxa)

with(surveys, table(year, taxa))

order(surveys$weight) # Order of the indices
sort(surves$weight) # Values in order

# To sort the entire data frame by one of its columns: 
surveys[order(surveys$weight)]

# What was the median weight of each rodent species between 1980 and 1990?
surveys$taxa == "Rodent"
length(surveys$taxa == "Rodent")
dim(surveys)

surveys[surveys$taxa == "Rodent", "taxa"]
length(surveys[surveys$taxa == "Rodent", "taxa"])

# Re-write the line below so that we are subsetting the data frame to those records between 1980 and 1990 inclusive
surveys[surveys$year %in% c(1980:1990) & surveys$taxa == "Rodent",]


library(dplyr)

output <- select(surveys, year, taxa, weight)
head(output)

filter(surveys, taxa == "Rodent")

rodent_surveys2 <- surveys %>% 
  filter(taxa == "Rodent" & year %in% c(1980:1990)) %>%
  select(year, taxa, weight)
  
dim(rodent_surveys2)


surveys %>% 
  mutate(weight_kg = weight/1000.0) %>%
  head()

# Split apply combine
med_weight_species <- surveys %>% 
  filter(weight != "NA" & year %in% 1980:1990) %>% # !is.na(weight) also works
  group_by(species_id, genus) %>%
  summarize(med_weight = median(weight)) 


ggplot(med_weight_species, aes(x = species_id, y = med_weight, colour = genus)) + 
  geom_point()


surveys_complete <- surveys %>% 
  filter(weight != "NA" & year %in% 1980:1990) %>% # !is.na(weight) also works
  group_by(species_id, genus) 


common_species <- surveys %>%
  group_by(species_id) %>%
  tally() %>%
  filter(n >= 50) %>%
  select(species_id)

common_surveys <- surveys_complete %>%
  filter(species_id %in% common_species$species_id)

ggplot(data = common_surveys, 
       aes(x = weight, y = hindfoot_length, colour = species_id)) + 
  geom_point()

