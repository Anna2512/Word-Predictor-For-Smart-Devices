# Word-Predictor-For-Smart-Devices
Project in Natural Language Processing.

This project uses the files named LOCALE.blogs.txt where LOCALE is the each of the four locales and their languages into English (en_US dataset), German (de_DE dataset), Russian (ru_RU dataset) and Finnish (fi_FI dataset). In this capstone, we will be applying data science in building a predictive model in the area of natural language processing.

In the final report, we're going to present an overview of data throughout Exploratory Data Analysis (EDA), predictive algorithm and our plan to bring up a Shiny App for data interaction. There are 02 parts to be introduced:

**Part I: Exploratory Data Analysis**
An overview of data will be illustrated into statistical tables and data visualization.

**Dataset:**
- Using data provided by SwiftKey, we built up the final dataset extracted from the English corpus as a subset of each 1% of the news, blogs, and twitter and then combined them to ensure equal representation and ease of calculation. The binomial distribution will be used to sample the data and remove bias in the sampling process.
- The dataset was split into 80% training, 10% validation and 10% test set.

**Data Transformation:**
1. Word Stemming: 
 - Help reducing inflected or derived word to its basic part.
2. All text to lower case:
 - Removes the problem of beginning of sentence words being “different” than the others.
 - Combined with punctuation, this information could be used for prediction.
 - Ignore capital letters in the beginning of sentence, but keep them elsewhere to catch names and acronyms correctly.
3. Remove numbers: 
 - Remove tokens that consist only of numbers, but not words that start with digits),
4. Remove punctuation
5. Remove separators:
 - Spaces and variations of spaces, plus tab, newlines, and anything else in the Unicode “separator” category.
6. Remove Twitter characters
7. Profanity filtering

**Part II: Algorithm For Shiny App**
Link to Shiny App: https://rpubs.com/Anna_Huynh/753061

**Algorithm works following designed flow:**
- First the function to predict the fourth word (quad-gram), given three previous words.
- If failed at the 1st round of running, return probable word given two successive words.
- If it didn't find a tri-gram with the two given words, algorithm being allowed to back-off to the bi-gram and find the next word given one previous word.
- If it couldn't even find the corresponding bi-gram, we randomly get a word from uni-grams with high probability. This is the last resort for n-grams that are not found in the sampling dataset.
