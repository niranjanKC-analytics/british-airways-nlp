# ============================================================
# CIS 428: Text Analytics
# D3: Data Collection & Preprocessing
# Project: Text Analytics on Airline Customer Reviews
# Group Members: Sofia Foutzitzi | Niranjan K C | Pradip Raj Dhakal
# Date: March 2026
# ============================================================


# ------------------------------------------------------------
# STEP 1: Install & Load Required Packages
# ------------------------------------------------------------

if (!require(pacman)) install.packages("pacman")
library(pacman)

p_load(
  tidyverse,     # data manipulation and ggplot2
  tidytext,      # text mining and tokenization
  tm,            # text mining: VCorpus, DocumentTermMatrix
  wordcloud,     # word cloud visualizations
  wordcloud2,    # enhanced word clouds
  stringr,       # string manipulation
  dplyr,         # data wrangling
  ggplot2,       # data visualization
  lubridate,     # date parsing
  scales,        # axis formatting
  RColorBrewer   # color palettes
)


# ------------------------------------------------------------
# STEP 2: Set Working Directory & Load Dataset
# ------------------------------------------------------------

setwd("~/Desktop/CIS428/FInal Project")
getwd()

# Load the British Airways airline reviews dataset from Kaggle
# Source: Chaudhary, A., & Risinahani, M. (2023). Airline reviews [Data set].
#         Kaggle. https://doi.org/10.34740/KAGGLE/DS/404107
ba_reviews <- read.csv("BA_AirlineReviews.csv", stringsAsFactors = FALSE)

# Basic dataset inspection
dim(ba_reviews)           # number of rows and columns
str(ba_reviews)           # structure and data types
colnames(ba_reviews)      # column names
summary(ba_reviews)       # summary statistics


# ------------------------------------------------------------
# STEP 3: Data Cleaning & Transformation
# ------------------------------------------------------------

# Remove the unnamed index column (artifact from CSV export)
ba_reviews <- ba_reviews %>%
  select(-X)

# Rename columns for easier reference
# Note: R auto-converts special characters like & to dots in column names
ba_reviews <- ba_reviews %>%
  rename(
    Rating        = OverallRating,
    Header        = ReviewHeader,
    Review        = ReviewBody,
    Traveller     = TypeOfTraveller,
    Seat          = SeatType,
    Verified      = VerifiedReview,
    Food          = Food.Beverages,
    Entertainment = InflightEntertainment
  )

# Convert character columns that should be numeric
ba_reviews$Food          <- as.numeric(ba_reviews$Food)
ba_reviews$Entertainment <- as.numeric(ba_reviews$Entertainment)
ba_reviews$ValueForMoney <- as.numeric(ba_reviews$ValueForMoney)

# Convert Recommended to a clean factor
ba_reviews$Recommended <- factor(ba_reviews$Recommended,
                                 levels = c("yes", "no"),
                                 labels = c("Recommended", "Not Recommended"))

# Convert Traveller and Seat to factors
ba_reviews$Traveller <- factor(ba_reviews$Traveller)
ba_reviews$Seat      <- factor(ba_reviews$Seat)

# Parse date column
ba_reviews$Datetime <- dmy(ba_reviews$Datetime)

# Create binary sentiment label based on OverallRating
# Rating >= 7 = Positive, Rating <= 4 = Negative, 5-6 = Neutral
ba_reviews <- ba_reviews %>%
  mutate(Sentiment = case_when(
    Rating >= 7 ~ "Positive",
    Rating <= 4 ~ "Negative",
    TRUE        ~ "Neutral"
  ))

ba_reviews$Sentiment <- factor(ba_reviews$Sentiment,
                               levels = c("Positive", "Neutral", "Negative"))

# Check dimensions and missing values after cleaning
dim(ba_reviews)
colSums(is.na(ba_reviews))

# Check sentiment label distribution
table(ba_reviews$Sentiment)
prop.table(table(ba_reviews$Sentiment))


# ------------------------------------------------------------
# STEP 4: Exploratory Data Analysis (EDA) - Structured Fields
# ------------------------------------------------------------

# --- 4.1 Overall Rating Distribution ---
ggplot(ba_reviews %>% filter(!is.na(Rating)), aes(x = factor(Rating))) +
  geom_bar(fill = "steelblue") +
  labs(title = "Figure 1: Distribution of Overall Ratings",
       x = "Overall Rating (1-10)",
       y = "Number of Reviews") +
  theme_minimal()

# --- 4.2 Recommended vs Not Recommended ---
ggplot(ba_reviews, aes(x = Recommended, fill = Recommended)) +
  geom_bar() +
  scale_fill_manual(values = c("Recommended" = "steelblue",
                               "Not Recommended" = "tomato")) +
  labs(title = "Figure 2: Recommended vs Not Recommended",
       x = "Recommendation",
       y = "Number of Reviews") +
  theme_minimal() +
  theme(legend.position = "none")

# --- 4.3 Reviews by Type of Traveller ---
ba_reviews %>%
  filter(!is.na(Traveller)) %>%
  count(Traveller, sort = TRUE) %>%
  mutate(Traveller = reorder(Traveller, n)) %>%
  ggplot(aes(x = Traveller, y = n, fill = Traveller)) +
  geom_col() +
  coord_flip() +
  labs(title = "Figure 3: Reviews by Type of Traveller",
       x = "Traveller Type",
       y = "Number of Reviews") +
  theme_minimal() +
  theme(legend.position = "none")

# --- 4.4 Reviews by Seat Type ---
ba_reviews %>%
  filter(!is.na(Seat)) %>%
  count(Seat, sort = TRUE) %>%
  mutate(Seat = reorder(Seat, n)) %>%
  ggplot(aes(x = Seat, y = n, fill = Seat)) +
  geom_col() +
  coord_flip() +
  labs(title = "Figure 4: Reviews by Seat Type (Cabin Class)",
       x = "Seat Type",
       y = "Number of Reviews") +
  theme_minimal() +
  theme(legend.position = "none")

# --- 4.5 Average Rating by Seat Type (Professor's Feedback Focus) ---
ba_reviews %>%
  filter(!is.na(Seat), !is.na(Rating)) %>%
  group_by(Seat) %>%
  summarise(avg_rating = mean(Rating, na.rm = TRUE)) %>%
  mutate(Seat = reorder(Seat, avg_rating)) %>%
  ggplot(aes(x = Seat, y = avg_rating, fill = Seat)) +
  geom_col() +
  coord_flip() +
  labs(title = "Figure 5: Average Rating by Seat Type",
       x = "Seat Type",
       y = "Average Rating") +
  theme_minimal() +
  theme(legend.position = "none")

# --- 4.6 Sentiment Distribution by Seat Type ---
ba_reviews %>%
  filter(!is.na(Seat)) %>%
  count(Seat, Sentiment) %>%
  ggplot(aes(x = Seat, y = n, fill = Sentiment)) +
  geom_bar(stat = "identity", position = "fill") +
  scale_fill_manual(values = c("Positive" = "steelblue",
                               "Neutral"  = "gold",
                               "Negative" = "tomato")) +
  coord_flip() +
  scale_y_continuous(labels = percent_format()) +
  labs(title = "Figure 6: Sentiment Distribution by Seat Type",
       x = "Seat Type",
       y = "Proportion of Reviews") +
  theme_minimal()

# --- 4.7 Review Volume Over Time ---
ba_reviews %>%
  filter(!is.na(Datetime)) %>%
  mutate(YearMonth = floor_date(Datetime, "month")) %>%
  count(YearMonth) %>%
  ggplot(aes(x = YearMonth, y = n)) +
  geom_line(color = "steelblue", size = 1) +
  geom_point(color = "steelblue") +
  labs(title = "Figure 7: Review Volume Over Time",
       x = "Date",
       y = "Number of Reviews") +
  theme_minimal()


# ------------------------------------------------------------
# STEP 5: Text Preprocessing
# ------------------------------------------------------------

# --- 5.1 Subset the Review Text Column ---
text_df <- ba_reviews %>%
  select(Review, Sentiment, Seat, Recommended)

head(text_df)

# --- 5.2 Tokenization (Unigrams) ---
# Break each review into individual words
tidy_reviews <- text_df %>%
  unnest_tokens(word, Review)

head(tidy_reviews)

# Count raw word frequency before cleaning
word_freq_raw <- tidy_reviews %>%
  count(word, sort = TRUE)

head(word_freq_raw, 20)

# --- 5.3 Remove Standard Stopwords ---
data("stop_words")

tidy_clean <- tidy_reviews %>%
  anti_join(stop_words, by = "word")

# Count frequency after stopword removal
word_freq_clean <- tidy_clean %>%
  count(word, sort = TRUE)

head(word_freq_clean, 20)

# --- 5.4 Remove Custom Airline-Specific Stopwords ---
# These are common but uninformative words in airline reviews
custom_stopwords <- data.frame(
  word = c("flight", "british", "airways", "ba", "airline",
           "london", "heathrow", "just", "also", "really",
           "one", "get", "got", "time", "will")
)

tidy_final <- tidy_clean %>%
  anti_join(custom_stopwords, by = "word")

# Count frequency after custom stopword removal
word_freq_final <- tidy_final %>%
  count(word, sort = TRUE)

head(word_freq_final, 30)


# ------------------------------------------------------------
# STEP 6: EDA - Text Visualizations
# ------------------------------------------------------------

# --- 6.1 Top Frequent Words Bar Chart ---
tidy_final %>%
  count(word, sort = TRUE) %>%
  filter(n > 300) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(title = "Figure 8: Most Frequent Words in Airline Reviews",
       x = "Word",
       y = "Frequency") +
  theme_minimal()

# --- 6.2 Word Cloud - All Reviews ---
word_counts <- tidy_final %>%
  count(word, sort = TRUE) %>%
  filter(n > 50)

wordcloud(words = word_counts$word,
          freq  = word_counts$n,
          max.words = 80,
          colors = brewer.pal(8, "Dark2"),
          scale = c(4, 0.5),
          random.order = FALSE)

# --- 6.3 Word Cloud - Positive Reviews Only ---
positive_words <- tidy_final %>%
  filter(Sentiment == "Positive") %>%
  count(word, sort = TRUE) %>%
  filter(n > 30)

wordcloud(words = positive_words$word,
          freq  = positive_words$n,
          max.words = 60,
          colors = brewer.pal(8, "Blues"),
          scale = c(4, 0.5),
          random.order = FALSE)

# --- 6.4 Word Cloud - Negative Reviews Only ---
negative_words <- tidy_final %>%
  filter(Sentiment == "Negative") %>%
  count(word, sort = TRUE) %>%
  filter(n > 30)

wordcloud(words = negative_words$word,
          freq  = negative_words$n,
          max.words = 60,
          colors = brewer.pal(8, "Reds"),
          scale = c(4, 0.5),
          random.order = FALSE)

# --- 6.5 Top Words by Seat Type (Professor Feedback: different seating for different emotions) ---
tidy_final %>%
  filter(!is.na(Seat)) %>%
  count(Seat, word, sort = TRUE) %>%
  group_by(Seat) %>%
  top_n(10, n) %>%
  ungroup() %>%
  mutate(word = reorder_within(word, n, Seat)) %>%
  ggplot(aes(word, n, fill = Seat)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~Seat, scales = "free_y") +
  coord_flip() +
  scale_x_reordered() +
  labs(title = "Figure 9: Top Words by Seat Type",
       x = "Word",
       y = "Frequency") +
  theme_minimal()


# ------------------------------------------------------------
# STEP 7: Bigram Analysis
# ------------------------------------------------------------

# --- 7.1 Generate Bigrams ---
bigrams <- text_df %>%
  unnest_tokens(bigram, Review, token = "ngrams", n = 2) %>%
  drop_na()

head(bigrams)

# --- 7.2 Separate & Clean Bigrams ---
bigram_sep <- bigrams %>%
  separate(bigram, c("term1", "term2"), sep = " ")

# Remove stopwords from both terms
bigram_clean <- bigram_sep %>%
  filter(!term1 %in% stop_words$word) %>%
  filter(!term2 %in% stop_words$word) %>%
  filter(!term1 %in% custom_stopwords$word) %>%
  filter(!term2 %in% custom_stopwords$word)

# --- 7.3 Count & Plot Bigrams ---
bigram_united <- bigram_clean %>%
  unite(bigram, term1, term2, sep = " ")

bigram_united %>%
  count(bigram, sort = TRUE) %>%
  filter(n > 50) %>%
  mutate(bigram = reorder(bigram, n)) %>%
  ggplot(aes(bigram, n)) +
  geom_col(fill = "darkgreen") +
  coord_flip() +
  labs(title = "Figure 10: Most Common Bigrams in Airline Reviews",
       x = "Bigram",
       y = "Frequency") +
  theme_minimal()


# ------------------------------------------------------------
# STEP 8: Export Cleaned Data for D4 (Text Mining Methods)
# ------------------------------------------------------------

# Save cleaned dataframe for use in next deliverable
write.csv(ba_reviews, "BA_Reviews_Cleaned.csv", row.names = FALSE)

# Save the tidy tokenized data
write.csv(tidy_final, "BA_Reviews_Tidy_Tokens.csv", row.names = FALSE)

cat("D3 Preprocessing Complete. Files saved to working directory.\n")