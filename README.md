# TextSimilarityExplorer 🔎 📄

A visualization app with which users can explore the similary between texts/documents.

The original app was originally developed for the area of short term answer grading but the code cuould also be
applied with some slight adaptions in other domains.

The web-app can be accessed by clicking on the link below:

https://dario-x.shinyapps.io/text_visuals/

# Controls 🎛️🕹️

The following controls are available in the app for interactio with the visuls

1.  **changing the plot type** this will switch the change the
    network-based visuals to the PCA-ones or visa versa. The control is
    located above the visualization.

2.  **changing the question** this allows the user to easily select the
    question which he would like to analyse

3.  **choose the top n words** this defines how many of the most
    frequent words for each component in the graph are displayed

4.  **choose the similarity threshold** with this tool the control the
    number of edges drawn - the lower this threshold - the more edges
    will be drawn.

5.  **Define the marker size for the PCA plot** - to avoid problems with
    scalablity

6.  **Set a position jitter of the PCA plot** - to avoid problems of
    overlapping points
    
Besides those you have the standard zooming, hovering, taking-a-picture tools by plotly


# Structure of the Remaining Code 🤖 💾

The files in this repository are reponsible for the following tasks

1.  **Preporcessing_and_Experimentation.ipynb**

    This Jupyter-notebook fulfills two basic tasks: first, the
    visualization experiments discussed in section 3 took place there,
    and second, it puts the data into a form usable for visualization -
    this outsourcing of the preprocessing activity makes the app itself
    run faster. Central points here are the cleaning and spell checking,
    as well as the normalization of the texts (norms are moved here into
    the singular, with verbs and other words the root form is found
    (e.g. was becomes is), the stopword removal - this takes place in
    several steps, on the one hand generic stop-words like (also, is, a)
    - are removed and on the other hand those words are removed - which
    occur in the question. After this is done, a principal component
    analysis is performed and the data is saved in a new document.

2.  **app.R** this allows the user to easily select the question which
    he would like to analyse

3.  **hoster.R** - deploys the main app to the web. A shiny user account
    is requested - and a token must be generated before in order to be
    able do the hosting.


