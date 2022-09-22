# TextSimilarityExplorer 🔎 📄

A visualization app with which users can explore the similarity between texts/documents.

The original app was originally developed for the area of short-term answer grading but the code could also be
applied with some slight adaptions in other domains.

The web app can be accessed by clicking on the link below:

https://dario-x.shinyapps.io/TextSimilarityExplorer/

# Controls 🎛️🕹️

The following controls are available in the app for interaction with the visuals

1.  **changing the plot type** will switch the change the
    network-based visuals to the PCA-ones or visa versa. The control is
    located above the visualization.

2.  **changing the question** This allows the user to easily select the
    The question which he would like to analyze

3.  **choose the top n words** this defines how many of the most
    frequent words for each component in the graph are displayed

4.  **choose the similarity threshold** with this tool the control the
    number of edges drawn - the lower this threshold - the more edges
    will be drawn.

5.  **Define the marker size for the PCA plot** - to avoid problems with
    scalability

6.  **Set a position jitter of the PCA plot** - to avoid problems of
    overlapping points
    
Besides those you have the standard zooming, hovering, and taking-a-picture tools by plotly


# Structure of the Remaining Code 🤖 💾

The files in this repository are responsible for the following tasks

1.  **Preporcessing_and_Experimentation.ipynb**

    This Jupyter-notebook fulfills two basic tasks: first, the
    visualization experiments discussed in section 3 took place there,
    and second, it puts the data into a form usable for visualization -
    this outsourcing of the preprocessing activity makes the app itself
    run faster. Central points here are the cleaning and spell checking,
    as well as the normalization of the texts (norms are moved here into
    the singular, with verbs and other words the root form is found
    (e.g. was becomes is), the stopword removal - this takes place in
    several steps, on the one hand, generic stop-words like (also, is, a)
    are removed and on the other hand, those words are removed - which
    occur in the question. After this is done, a principal component
    the analysis is performed and the data is saved in a new document.

2.  **app.R** This allows the user to easily select the question which
    he would like to analyze

3.  **hoster.R** - deploys the main app to the web. A shiny user account
    is requested - and a token must be generated before to be
    able to do the hosting.

![pipelne](https://user-images.githubusercontent.com/75636666/176884052-88c4e44c-89be-461d-ac4c-ec6b80ced12f.JPG)


