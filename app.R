#
# #
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# load shiny package
library(shiny)

# Load data
unigram_words <- readRDS("unigram_words.RDS")
bigram_words <- readRDS("bigram_words.RDS")
trigram_words <- readRDS("trigram_words.RDS")
quadgram_words <- readRDS("quadgram_wordss.RDS")


## Google-profanity-words
profane_words <- read.csv("https://raw.githubusercontent.com/RobertJGabriel/Google-profanity-words/b0431f63daf901eea0bc95f8dcd0298052454974/list.txt")

library(textclean)

cleanInput <- function(input) {
    # 1. Separate words connected with - or /
    input <- gsub("-", " ", input)
    input <- gsub("/", " ", input)
    
    # 2. Establish end of sentence, abbr, number, email, html
    input <- gsub("\\? |\\?$|\\! |\\!$", " EEOSS ", input)
    input <- gsub("[A-Za-z]\\.[A-Za-z]\\.[A-Za-z]\\.[A-Za-z]\\. |[A-Za-z]\\.[A-Za-z]\\.[A-Za-z]\\. |[A-Za-z]\\.[A-Za-z]\\. ", " AABRR ", input)
    input <- gsub("\\. |\\.$", " EEOSS ", input)
    input <- gsub("[0-9]+"," NNUMM ",input)
    input <- gsub("\\S+@\\S+","EEMAILL",input) 
    input <- gsub("[Hh}ttp([^ ]+)","HHTMLL",input) 
    input <- gsub("RT | via"," RTVIA ",input) # retweets
    input <- gsub("@([^ ]+)","ATPPLE",input) # @people
    input <- gsub("[@][a - zA - Z0 - 9_]{1,15}","UUSRNMSS",input) # usernames
    
    # 3. to lower
    input <- tolower(input)
    
    # 4. Remove/replace &, @, 'm, 's, 'are, 'll, etc...
    input <- gsub(" & ", " and ", input)
    input <- gsub(" @ ", " at ", input)
    input <- replace_contraction(input)
    input <- gsub("'s", "", input) 
    input <- gsub("haven't", "have not", input)
    input <- gsub("hadn't", "had not", input)
    
    # 5. Remove emoji's, emoticons
    input <- gsub("[^\x01-\x7F]", "", input)
    
    # 6. Remove g, mg, lbs etc; removes all single letters except "a" and "i"
    
    input <- gsub(" [1-9]+g ", " ", input) # grams
    input <- gsub(" [1-9]+mg ", " ", input) # miligrams, etc
    input <- gsub(" [1-9]+kg ", " ", input)
    input <- gsub(" [1-9]+lbs ", " ", input)
    input <- gsub(" [1-9]+s ", " ", input) # seconds, etc
    input <- gsub(" [1-9]+m ", " ", input)
    input <- gsub(" [1-9]+h ", " ", input)
    input <- gsub(" +g ", " ", input) # grams
    input <- gsub(" +mg ", " ", input) # miligrams, etc
    input <- gsub(" +kg ", " ", input)
    input <- gsub(" +lbs ", " ", input)
    input <- gsub(" +s ", " ", input) # seconds, etc
    input <- gsub(" +m ", " ", input)
    input <- gsub(" +h ", " ", input)
    input <- gsub(" +lbs ", " ", input)
    input <- gsub(" +kg ", " ", input)
    
    # 7. remove punctuation
    input <- gsub("[^[:alnum:][:space:]\']", "",input)
    input <- gsub(" '' ", "", input)
    input <- gsub('"', "", input)
    input <- gsub("'", "", input)
    input <- gsub("'", "", input)
    
    # 8. remove all single letters except i and a
    input <- gsub('u', 'you', input)
    input <- gsub(" [b-hj-z] ", " ", input)
    
    # 9. remove profanity
    input <- removeWords(input, profane_words[,1])
    
    # 10. remove extra spaces
    input <- gsub("^[ ]{1,10}","",input)
    input <- gsub("[ ]{2,10}"," ",input)
    input <- stripWhitespace(input)
    # remove space at end of phrase
    input <- gsub(" $", "", input)
    return(input)
}


## Function to return highly probable word given three successive words.
quadWords <- function(w1, w2,w3,w4, n = 5) {
    quad_words <- quadgram_words
    tri_words <- trigram_words
    bi_words <- bigram_words
    uni_words <- unigram_words
    pwords <- quad_words[.(w1, w2,w3,w4)][order(-Prob)]
    if (any(is.na(pwords)))
        return(triWords(w1,w2,w3, n))
    if (nrow(pwords) > n)
        return(pwords[1:n, word_4])
    count <- nrow(pwords)
    twords <- triWords(w1,w2,w3, n)[1:(n - count)]
    return(c(pwords[, word_4], twords, pwords[, Prob]))
}

triWords <- function(w1, w2,w3, n = 5) {
    tri_words <- trigram_words
    bi_words <- bigram_words
    uni_words <- unigram_words
    pwords <- tri_words[.(w1, w2, w3)][order(-Prob)]
    if (any(is.na(pwords)))
        return(biWords(w1,w2, n))
    if (nrow(pwords) > n)
        return(pwords[1:n, word_3])
    count <- nrow(pwords)
    bwords <- biWords(w1,w2, n)[1:(n - count)]
    return(c(pwords[, word_3], bwords, pwords[, Prob]))
}


# function to return highly probable previous word given a word
biWords <- function(w1,w2, n = 5) {
    bi_words <- bigram_words
    uni_words <- unigram_words
    pwords <- bi_words[.(w1, w2)][order(-Prob)]
    if (any(is.na(pwords)))
        return(uniWords(n))
    if (nrow(pwords) > n)
        return(pwords[1:n, word_2])
    count <- nrow(pwords)
    unWords <- uniWords(n)[1:(n - count)]
    return(c(pwords[, word_2], unWords, pwords[, Prob]))
}


##  tweak the unigram to be used more effectively. Here we single out 50 most occurring unigrams as it is more likely to occur. This will be used as the last resort in backing-off.
uni_words <- unigram_words[order(-Prob)][1:50]

# function to return random words from unigrams
uniWords <- function(n = 5) {  
    return(sample(uni_words[, word_1], size = n))
}


# The prediction app
getWords <- function(str, n=5){
    require(textclean)
    require(quanteda)
    require(tm)
    str <- cleanInput(str)
    tokens <- tokens(x = char_tolower(str))
    tokens <- rev(rev(tokens[[1]])[1:4])
    
    words <- quadWords(tokens[1], tokens[2], tokens[3], tokens[4], n)
    chain_1 <- paste(tokens[1], tokens[2], tokens[3], tokens[4], words[1], sep = " ")
    
    print(words)
}

getWords2 <- function(str){
    require(textclean)
    require(quanteda)
    require(tm)
    str <- cleanInput(str)
    tokens <- tokens(x = char_tolower(str))
    tokens <- rev(rev(tokens[[1]])[1:3])
    
    autocomplete_filtered = quadgram_words[
        startsWith(
            as.character(quadgram_words$word_1), str), 
        c('word_1', 'count')]
    
    #Aggregate across duplicate rows
    autocomplete_summary =aggregate(count ~ word_1, autocomplete_filtered, sum)
    
    #Order in descending order of frequency
    autocomplete_ordered = autocomplete_summary[
        with(autocomplete_summary, order(-count)), ]
    
    #The predictive auto complete list.
    words <- autocomplete_ordered$word_1
    cnt <- autocomplete_ordered$count
    table <-  data.frame(`Predicted Word` = words, Frequency = cnt,
                         stringsAsFactors = FALSE)
    print(table)
}


# begin shiny UI
shinyUI <- pageWithSidebar(
    headerPanel("Word Predictor for Smart Devices "),
    sidebarPanel(
        textInput(inputId="text", label = "Please enter some texts"),
        numericInput('n', 'Define the number of words to show (top 05 words)', 5, min = 1, max = 5, step = 1),
        actionButton("goButton", "Predict next word!"),
        
        textInput(inputId="incomplete_word", label = "Please enter an incomplete word"),
        actionButton("goButton2", "Complete word!")
    ),
    mainPanel(
        column(8, offset=9,
               tags$h5((tags$i("By Anna Huynh"))),
               tags$h5((tags$i("April 10, 2021"))),
               tags$h5("Data source: SwiftKey")
        ),
        h3('Prediction result.'),
        p("The top most likely words are shown below, and list of words would be the prediction result of your incomplete word."),
        h4('Show the top most likely words.'),
        verbatimTextOutput("top5"),
        h4('Prediction result of the incomplete word.'),
        verbatimTextOutput("completed_word")
        
    )
)


shinyServer <- function(input, output) {
    output$top5 = renderPrint({
        input$goButton
        isolate(getWords(input$text,input$n))
    })
    
    output$completed_word = renderPrint({
        input$goButton2
        isolate(getWords2(input$incomplete_word))
    })
    
}

# Run the application 
shinyApp(ui = shinyUI, server = shinyServer)

