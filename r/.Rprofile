# load libraries
suppressMessages(library(stats))
suppressMessages(library(utils))
suppressMessages(library(grDevices))

suppressMessages(library(tidyverse))
suppressMessages(library(lubridate))

suppressMessages(library(extrafont))
suppressMessages(library(scales))
suppressMessages(library(grid))
suppressMessages(library(RColorBrewer))
suppressMessages(library(plotly))

# set options
options(tab.width = 2)
options(width = 80)
options(digits = 8)
options(graphics.record = TRUE)
options(lubridate.week.start = 1)

# set device
invisible(pdf(NULL))

# define and set palette
spren9er_palette <- function() {
  black   <- '#555555'
  red     <- '#dc322f'
  green   <- '#859900'
  blue    <- '#268bd2'
  cyan    <- '#2aa198'
  orange <-  '#cb4b16'
  yellow  <- '#b58900'
  gray    <- '#586e75'

  c(black, red, green, blue, cyan, orange, yellow, gray)
}
invisible(palette(spren9er_palette()))

# define and set theme
spren9er_theme <- function() {
  # generate colors
  pal <- brewer.pal(9, 'Greys')
  color.title      <- '#555555'
  color.background <- pal[1]
  color.grid.major <- pal[3]
  color.axis.text  <- pal[6]
  color.axis.title <- pal[7]
  strip.background <- '#f0f0f0'
  strip.color      <- '#555555'

  # use base theme
  theme_bw(base_size = 9) +

  # set font styles
  theme(text = element_text(color = 1)) +
  theme(text = element_text(family = 'Source\ Sans\ Pro')) +

  # set the entire chart region to a light gray color
  theme(
    panel.background =
      element_rect(fill = color.background, color = color.background)
  ) +
  theme(
    plot.background =
      element_rect(fill = color.background, color = color.background)
  ) +
  theme(panel.border = element_rect(color = color.background)) +

  # format grid
  theme(panel.grid.major = element_line(color = color.grid.major, size = .25)) +
  theme(panel.grid.minor = element_blank()) +
  theme(axis.ticks = element_blank()) +

  # format strip
  theme(strip.background = element_rect(fill = strip.background, color = NA)) +
  theme(strip.text.x = element_text(color = color.title)) +
  theme(strip.text.y = element_text(color = color.title)) +

  # format legend
  theme(legend.background = element_rect(fill = color.background)) +
  theme(legend.text = element_text(size = 7, color = color.axis.text)) +
  theme(legend.title = element_text(color = color.axis.title)) +
  theme(legend.key = element_rect(fill = color.background)) +

  # set title and axis labels, and format these and tick marks
  theme(plot.title = element_text(
    color = color.title, size = 12, vjust = 1.25, hjust = .5, face = 'bold')
  ) +
  theme(axis.text.x = element_text(size = 7, color = color.axis.text)) +
  theme(axis.text.y = element_text(size = 7, color = color.axis.text)) +
  theme(axis.title.x =
    element_text(
      color = color.axis.title, vjust = 0,
      margin = margin(t = 8, r = 0, b = 0, l = 0)
    )
  ) +
  theme(axis.title.y =
    element_text(
      color = color.axis.title, vjust = 1.25,
      margin = margin(t = 0, r = 8, b = 0, l = 0)
    )
  ) +

  # plot margins
  theme(plot.margin = unit(c(.35, .2, .3, .35), 'cm'))
}
invisible(theme_set(spren9er_theme()))

# set default plot color
update_geom_default_color <- function(color) {
  geom_names <- apropos("^Geom", ignore.case = FALSE)
  geoms <- mget(geom_names, env = asNamespace("ggplot2"))
  colors <- map(map(geoms, 'default_aes'), 'colour')
  colors <- colors[sapply(colors, function(x) is.character(x))]
  colors <- colors[sapply(colors, function(x) x == 'black')]
  geom_prefixes <- gsub('Geom', '', names(colors))
  geom_prefixes <- sub("^(.[a-z])", "\\L\\1", geom_prefixes, perl = TRUE)
  map(geom_prefixes, update_geom_defaults, list(colour = color))
}
invisible(update_geom_default_color(1))

# redefine ggplot function
ggplot <- function(...) {
  ggplot2::ggplot(...) + scale_color_manual(values = spren9er_palette())
}

# redefine plot_ly function
plot_ly <- function(...) {
  font <- list(
    family = 'Source\ Sans\ Pro',
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

# set device off
invisible(dev.off())
