options(tab.width = 2)
options(width = 80)
options(digits = 4)
options(graphics.record = TRUE)

.First <- function(){
  suppressMessages(library(stats))
  suppressMessages(library(tidyverse))
  suppressMessages(library(lubridate))

  suppressMessages(library(extrafont))
  suppressMessages(library(ggthemes))

  theme_set(
    theme_gray() +
    theme(
      text = element_text(size = 12, family = 'Inconsolata'),
      plot.title = element_text(hjust = 0.5, face = 'bold')
    )
  )

  ggplot <- function(...) ggplot2::ggplot(...) + scale_colour_solarized()
}
