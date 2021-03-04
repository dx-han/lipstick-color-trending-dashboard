FROM rocker/shiny-verse:3.6.0

RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libsodium-dev

RUN R -e "install.packages(c('shiny', 'shinyjs', 'data.table', 'tidyverse', 'readxl', 'reticulate', 'devtools', 'DT', 'shinyWidgets', 'farver', 'psych', 'highcharter', 'sodium', 'keyring', 'shinythemes'))"
RUN R -e "install.packages('plotly', repos='http://cran.rstudio.com/')"
RUN R -e "devtools::install_github('rstudio/rscrypt')"
RUN R -e "remotes::install_github('ericrayanderson/shinymaterial')"
RUN R -e "remotes::install_github('datastorm-open/shinymanager')"


COPY shiny_dashboard.Rproj /srv/shiny-server/
COPY app /srv/shiny-server/lipstick/app

EXPOSE 3838
RUN sudo chown -R shiny:shiny /srv/shiny-server
CMD ["/usr/bin/shiny-server"]