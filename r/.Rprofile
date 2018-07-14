# system settings
invisible(Sys.setlocale('LC_CTYPE', 'de_DE.UTF-8'))
setwd('~/Development/r')

# load libraries
suppressMessages(library(stats))
suppressMessages(library(tidyverse))
suppressMessages(library(lubridate))

suppressMessages(library(extrafont))
suppressMessages(library(ggthemes))

suppressMessages(library(plotly))

# set options
options(tab.width = 2)
options(width = 80)
options(digits = 8)
options(graphics.record = TRUE)
options(lubridate.week.start = 1)

# set styles
theme_set(
  theme_gray() +
  theme(
    text = element_text(size = 9, family = 'Inconsolata'),
    plot.title = element_text(hjust = 0.5, face = 'bold')
  )
)

# redefine ggplot function
ggplot <- function(...) ggplot2::ggplot(...) + scale_color_solarized()

# redefine plot_ly function
plot_ly <- function(...) {
  font <- list(
    family = 'Inconsolata',
    size = 10,
    color = '#333333'
  )

  p <- plotly::plot_ly(...) %>%
         plotly::layout(
           font = font, hovermode = FALSE,
           autosize = TRUE, width = 480,
           xaxis = list(fixedrange = TRUE),
           yaxis = list(fixedrange = TRUE)
         ) %>%
         plotly::config(displayModeBar = FALSE)

  tryCatch({
    json <- plotly:::to_JSON(plotly_build(p)$x)
    mimebundle <- list('application/vnd.plotly.v1+json'=json)
    return(IRdisplay::publish_mimebundle(mimebundle))
  },
    warning = function(c) {
      msg <- conditionMessage(c)
      if (grep("IRdisplay.*", msg)) return(p)
      print(msg)
    },
    error = function(c) return(p)
  )
}
