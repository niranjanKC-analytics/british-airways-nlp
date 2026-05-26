# British Airways NLP — Sentiment Analysis & Topic Modeling

**Course:** CIS 428 Text Analytics (Data Analytics II) — Towson University | Spring 2026  
**Team:** Niranjan K C · Sofia Foutzitzi · Pradip Raj Dhakal  
**Tools:** R · tidytext · tm · e1071 · topicmodels · ggplot2  

---

## Overview

This project applies a full text analytics pipeline to 3,701 British Airways 
customer reviews sourced from Kaggle. The goal was to extract actionable 
business intelligence from unstructured passenger feedback using both 
supervised and unsupervised NLP techniques.

---

## Research Questions

- What themes appear most frequently in British Airways customer reviews?
- Does traveler type (economy vs. business) influence review sentiment?
- How does textual sentiment correlate with numerical review ratings?
- Which service factors (delays, staff, comfort) drive negative reviews?
- Can review text predict customer satisfaction levels?

---

## Dataset

- **Source:** Kaggle — British Airways Reviews (Chaudhary & Risinahani, 2023)
- **Size:** 3,701 reviews · 20 features
- **Sentiment split:** 52.7% Negative · 35.7% Positive · 11.6% Neutral
- **Cabin breakdown:** 52.1% Economy · 32.4% Business Class

---

## Methods

### Preprocessing
- Converted reviews to corpus, lowercased, removed punctuation/digits/stopwords
- Built Document-Term Matrix (DTM): 3,701 documents × 14,218 terms
- Created sentiment labels: Positive (7–10), Neutral (5–6), Negative (1–4)
- 80/20 train-test split (2,961 train / 740 test)

### Classification (Supervised)
| Model | Accuracy |
|---|---|
| Naive Bayes | 66.4% |
| KNN (k=5) | 59.62% |

- **Naive Bayes:** Binary word-presence DTM + Laplace smoothing
- **KNN:** Normalized DTM, cross-validated k=1 to 30, best at k=3

### Lexicon-Based Sentiment Analysis
- **Bing:** Binary positive/negative classification
- **AFINN:** Numeric scores from -5 to +5
- **NRC:** Emotion categories (anger, fear, joy, trust)

### Topic Modeling (Unsupervised)
LDA with k=3 topics revealed:
- **Topic 1:** Overall flight experience & service quality
- **Topic 2:** Airline operations & business class experience
- **Topic 3:** Airport experience, seating & travel time (Heathrow focus)

---

## Key Findings

- Economy Class passengers were significantly more negative than Business/First Class
- Delays, staff behavior, and seat comfort were the top drivers of negative reviews
- Textual sentiment (AFINN/Bing) broadly aligned with numerical ratings
- Neutral reviews (mid-range 5–6) were hardest to classify due to ambiguous language
- Naive Bayes outperformed KNN on high-dimensional sparse text data

---

## Repository Structure
british-airways-nlp/
├── data/
│   ├── BA_AirlineReviews.csv
│   ├── BA_Reviews_Cleaned.csv
│   └── BA_Reviews_Tidy_Tokens.csv
├── scripts/
│   ├── D3_Airline_Preprocessing_EDA.R
│   └── D3_TextMining.Rmd
├── report/
│   ├── Final_Report_COMPLETE.docx
│   └── D3_Report_TextMining.pdf
├── presentation/
│   └── D5_Final_Presentation_TITLEFIXED.pptx
└── README.md

---

## R Packages Used

`tm` · `tidytext` · `e1071` · `class` · `topicmodels` · `ggplot2` · 
`wordcloud` · `dplyr` · `lubridate` · `caret`

---

## References

Chaudhary, A., & Risinahani, M. (2023). Airline reviews. Kaggle.Lacic, E., Kowald, D., & Lex, E. (2016). arXiv:1604.00942 
Srinivas, S., & Ramachandiran, S. (2020). arXiv:2012.08000  
Yakut, I., et al. (2015). arXiv:1512.03632

---

## Author

**Niranjan K C**  
Data Analyst | B.S. Information Technology — Towson University, May 2026  
[LinkedIn](https://www.linkedin.com/in/niranjan-k-c-44b681334/) · 
[GitHub](https://github.com/niranjanKC-analytics) · 
[Tableau](https://public.tableau.com/app/profile/niranjan.k.c5704/vizzes)
