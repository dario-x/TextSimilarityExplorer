# Libraries ---------------------------------------------------------------
#for plotting graph
library(visNetwork)
#for generating docterm matrix
library(superml)
library(lsa)
#for getting connected components
library(igraph)
#for running app
library(shiny)
#for data manipulation
library(dplyr)
#for making interactive charts
library(plotly)
#for changing color style
library(RColorBrewer)
#for manipulating strings
library(stringr)
#for error checking
library(berryFunctions)




#setwd("C:/Users/user/1) Jupyter/Text visuals")
data = read.csv("./data/input_data_visulalization.csv")



#defines the main layout of the web application
ui <- bootstrapPage(
  
  #user interface
  #set styling
  theme = shinythemes::shinytheme("lumen"),
  tags$style(type = "text/css", "html, body {width:100%;height:100%}", 
                                 "#answer{color: green;
                                 font-size: 20px;
                                 font-style: italic;
                                 hr {border-top: 30px solid #000000;}
                                 }"),
  
  
    
  absolutePanel(top = 60, right = 20, draggable = TRUE, width = "350pt",
    #Dropdown for choosing question
    selectInput("question", "Choose a question you are interested in",
                choices = unique(data$question), width ="800px"),
    
    p("Reference Answer:"),
    #Text Output showing reference solution
    textOutput("answer"),
    
    
    br(),
    
    sidebarLayout(
    sidebarPanel(width = 250,
    p("For Network Visualization:"),
    #slider for top words
    sliderInput('top_n_words', '
                Show how many words to display',
                value=5, min=1,max= 9, step = 1, sep = ""),
    
    #slider for top words
    sliderInput('similarity_threshold', '
                Defining initial similarity threshold',
                value=0.13, min=0.01,max= 1, step = 0.01, sep = ""),
    p("The lower this threshold - the more edges the graph will have"),
    
    #checkboxInput("stopwords_remove", "Remove additional Stop Words?", value = FALSE),

    ),
    
    sidebarPanel(width = 250,
      
      p("For PCA Plot:"),
      #slider for marker size
      sliderInput('marker_size', '
                  Set a value for the marker size',
                  value=10, min=0.01,max= 20, step = 0.01, sep = ""),
      #slider for position jitter
      sliderInput('jitter_value', '
                  Set a value for the position jitter',
                  value=10, min=0,max= 50, step = 1, sep = ""),
    ),
    ),
    
  ),
  
  tabsetPanel(
    #graph output
    tabPanel("Network Visualization", visNetworkOutput("network", width = "750pt", height = "550pt")),
    #PCA Plot
    tabPanel("PCA Plot", plotlyOutput("PCA_plot", width = "700pt", height = "550pt")),
  )

  
  
  
  
  
)
server <- function(input, output, session) {
  
  
  
  output$PCA_plot = renderPlotly({
    
    question_data = data %>% filter(question == input$question)
    #transform text for readablity
    question_data$student_answer = lapply(question_data$student_answer, str_wrap)
    
    fig = plot_ly(question_data, 
            x = ~jitter(X0, factor = input$jitter_value), 
            y = ~X1,
            
            #adjust style of points in scatter plot
            marker = list(
              color=~score_me,
              size=input$marker_size,
              opacity=.9,
              colorscale='Cividis',
              colorbar=list(title='Score'),
              line = list(color = 'black', width = 1)
              ),
            
            mode = 'markers',
            type = 'scatter',
            
            #show the student answer when hovering over a point
            text=question_data$student_answer,
            hoverinfo="text") %>% layout( xaxis = list(title = 'Principal Component 1'), yaxis = list(title = 'Principal Component 2'))
  }) 
  
  output$network = renderVisNetwork({
    
    #filter for selected question
    question_data = data %>% filter(question == input$question)
    
    # initialize the class
    cfv = CountVectorizer$new(max_features = 4000, remove_stopwords = FALSE)
    
    # create doc term matrix
    doc_term_matrix = data.frame(cfv$fit_transform(question_data$student_answer))
    
    # create dataframe for empty df for edges and list nodes
    edges = data.frame(matrix(ncol = 3, nrow = 0))
    colnames(edges) = c("from", "to", "value")
    
    # draw edges based on a certain similarity
    # when to draw an edge is controlled over the similarity threshold
    # and 
    similarity_threshold_subsequent_nodes = 0.1
    similarity_threshold = input$similarity_threshold
      #0.01
      #as.integer(input$clustering_factor)
    
    
    #similarity_threshold = 0.01
    nodes = rownames(doc_term_matrix)
    
    while (similarity_threshold >= 0.00001) {
      
      
      #if we have no nodes more in our nodes object we will run
      #into an error when trying to create new nodes
      #which is actually no problem - because we then have assigned all nodes 
      #an edges but we should check this with the following code
      if (is.error( combn(nodes, 2, simplify = FALSE))) {
        similarity_threshold = 0
      }else{
        list_of_node_combination = combn(nodes, 2, simplify = FALSE)
      }
      
    
      for (i in list_of_node_combination) {
        
        first_node = as.integer(i[1])
        second_node = as.integer(i[2])
        similarity = cosine(as.numeric(as.vector(doc_term_matrix[first_node,])), 
                            as.numeric(as.vector(doc_term_matrix[second_node,])))
        
        
        if (similarity > similarity_threshold) {
          edges[nrow(edges) + 1,] = c(first_node, second_node, similarity)
          
          nodes = nodes[nodes != first_node]
          nodes = nodes[nodes != second_node]
        }
      }
      similarity_threshold=similarity_threshold-similarity_threshold_subsequent_nodes
        
      
    }
    
    
    nodes_in_graph = data.frame(matrix(ncol = 2, nrow = 0))
    colnames(nodes_in_graph) = c("id", "group")
    for (i in rownames(doc_term_matrix)) {
      nodes_in_graph[nrow(nodes_in_graph) + 1,] = c(i, 1)
    } 
    
    
    #getting components for the grouping the data 
    g = graph_from_data_frame(edges, directed=FALSE, vertices=nodes_in_graph)
    nodes_in_graph$group = components(g)$membership
    
    #for all groups extract the most common words for that group
    for (group in unique(nodes_in_graph$group)) {
      
      nodes_in_group = nodes_in_graph[nodes_in_graph$group == group,]$id
      group_doc_term_matrix = doc_term_matrix[nodes_in_group,]
      n=input$top_n_words
      
      group_doc_term_matrix = group_doc_term_matrix[colSums(group_doc_term_matrix) > 0]
      doc_term_group = colSums(group_doc_term_matrix)
      top_n_words = names(sort(doc_term_group, decreasing = TRUE)[1:n])
      top_n_words = paste(top_n_words, collapse = '-')
      
      for (i in 1:n) {
        top_n_words = str_replace(top_n_words, "-NA", "")
      }
      
      #introduce line breaks to have a better overview
      top_n_words = str_wrap(top_n_words,width=20)
      nodes_in_graph$group[nodes_in_graph$group == group] = top_n_words
      
    }
    
    #show original student answer when hovering over a text
    nodes_in_graph$title = lapply(question_data$orginal_student_answer, str_wrap, width=10)
    
    visNetwork(nodes_in_graph, edges, width = "100%") %>% 
                    visLegend() %>% 
                    #adds navigation tools
                    #and style the hover text to get line breaks and a nice looking text
                    visInteraction(navigationButtons  = TRUE,
                    tooltipStyle = 'position: fixed;visibility:hidden;padding: 5px;
                    font-size:15px;font-color:#000000;background-color: #c5dbe6;
                    max-width:300px;word-break: normal') %>% 
                    visOptions(highlightNearest = TRUE) %>%
                    #makes network reproducible - not needed at the moment
                    #visLayout(randomSeed = 123) %>%
                    #stops the network from moving around too much
                    visPhysics(maxVelocity = 6, forceAtlas2Based = c(centralGravity = 0.9))

  })
  
  
  
  
  output$answer <- renderText({
    
    unique(data[data[,'question']==input$question,]$reference_answer)
    
  })
  
}
shinyApp(ui, server)