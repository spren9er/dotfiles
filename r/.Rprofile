# load libraries
suppressMessages(library(stats))
suppressMessages(library(utils))
suppressMessages(library(grDevices))

suppressMessages(library(tidyverse))
suppressMessages(library(lubridate))

suppressMessages(library(extrafont))
suppressMessages(library(scales))
suppressMessages(library(grid))

# set options
options(tab.width = 2)
options(width = 80)
options(digits = 8)
options(graphics.record = TRUE)
options(lubridate.week.start = 1)
options(repr.plot.width = 5, repr.plot.height = 5)

# set device
invisible(cairo_pdf())

# define and set palettes
spren9er_palette <- function() {
  black   <- '#333333'
  red     <- '#b50019'
  green   <- '#2a9e46'
  blue    <- '#3766aa'
  cyan    <- '#6b42b8'
  orange  <- '#ec6400'
  yellow  <- '#f7ed42'
  gray    <- '#586e75'

  rep(c(black, red, green, blue, cyan, orange, yellow, gray), times = 3)
}

invisible(palette(spren9er_palette()))

# define and set theme
theme_spren9er <- function(base_size = 9, scale = 1) {
  title.color      <- '#333333'
  background.color <- '#ffffff'
  grid.major.color <- '#dedede'
  axis.text.color  <- '#777777'
  axis.title.color <- '#333333'
  strip.background <- '#f0f0f0'
  strip.color      <- '#333333'

  # use base theme
  theme_bw(base_size = base_size * scale) +

  # set font styles
  theme(
    text = element_text(color = 1, family = 'Source\ Sans\ Pro'),
    title = element_text(face = 'bold')
  ) +

  # format plot
  theme(
    plot.title = element_text(
      color = title.color, size = scale * (base_size + 3),
      vjust = 1.25, hjust = .5, face = 'bold',
      margin = margin(t = 5, b = 5)
    ),
    plot.subtitle = element_text(hjust = 0.5),
    plot.background = element_rect(
      fill = background.color, color = background.color
    )
  ) +

  # format panel
  theme(
    panel.background = element_rect(
      fill = background.color, color = background.color, size = 0
    ),
    panel.border = element_rect(color = background.color)
  ) +

  # format grid
  theme(
    panel.grid.major = element_line(
      color = grid.major.color, size = .25 * scale
    ),
    panel.grid.minor = element_blank()
  ) +

  # format strip
  theme(
    strip.background = element_rect(fill = strip.background, color = NA),
    strip.text.x = element_text(color = title.color),
    strip.text.y = element_text(color = title.color)
  ) +

  # format legend
  theme(
    legend.background = element_rect(fill = background.color),
    legend.text = element_text(
      size = scale * (base_size - 2), color = axis.text.color
    ),
    legend.title = element_text(color = axis.title.color),
    legend.key = element_rect(fill = background.color)
  ) +

  # format axes labels and tick marks
  theme(
    axis.ticks = element_blank(),
    axis.text.x = element_text(
      size = scale * (base_size - 2), color = axis.text.color
    ),
    axis.text.y = element_text(
      size = scale * (base_size - 2), color = axis.text.color
    ),
    axis.title.x = element_text(
      color = axis.title.color, vjust = 0,
      margin = margin(t = 8 * scale, r = 0, b = 0, l = 0)
    ),
    axis.title.y = element_text(
      color = axis.title.color, vjust = 1.25,
      margin = margin(t = 0, r = 8 * scale, b = 0, l = 0)
    )
  )
}

invisible(theme_set(theme_spren9er()))

# set default plot colors
geom_aes_defaults <- function() {
  geom_names <- apropos('^Geom', ignore.case = FALSE)
  geoms <- mget(geom_names, env = asNamespace('ggplot2'))
  map(geoms, ~ .$default_aes)
}

replace_geom_aes_defaults <- function(name, old_aes, new_aes) {
  matching_geoms <-
    map(geom_aes_defaults(), name) %>%
      compact() %>%
      keep(~ !is.na(.) & . == old_aes)
  geoms <- gsub('^Geom(.*)', '\\1', names(matching_geoms))
  walk(geoms, update_geom_defaults, setNames(list(new_aes), name))
}

replace_geom_aes_defaults('colour', 'black', '#333333')
replace_geom_aes_defaults('fill', 'grey35', '#333333')

# redefine ggplot function
ggplot <- function(...) {
  ggplot2::ggplot(...) +
    scale_color_manual(values = spren9er_palette()) +
    scale_fill_manual(values = spren9er_palette())
}

# set device off
invisible(dev.off())
