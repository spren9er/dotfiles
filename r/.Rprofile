# load libraries
suppressMessages(library(stats))
suppressMessages(library(tidyverse))

# set options
options(tab.width = 2)
options(width = 80)
options(digits = 8)
options(graphics.record = TRUE)
options(lubridate.week.start = 1)
options(
  repr.plot.width = 6.67,
  repr.plot.height = 6.67,
  repr.plot.res = 100,
  repr.plot.quality = 100,
  repr.plot.pointsize = 11
)

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

# define and set theme
spren9er_theme <- function(base_size = 11, scale = 1) {
  text_color       <- '#333333'
  caption_color    <- '#cccccc'
  background_color <- '#ffffff'
  grid_major_color <- '#dedede'
  axis_text_color  <- '#777777'
  axis_title_color <- '#333333'
  strip_background <- '#f0f0f0'

  # use base theme
  theme_bw(base_size = base_size * scale) +

  # set font styles
  theme(
    text = element_text(color = text_color, family = 'Source\ Sans\ Pro'),
    title = element_text(face = 'bold', family = 'Source\ Sans\ Pro')
  ) +

  # format plot
  theme(
    plot.title = element_text(
      color = text_color,
      size = scale * (base_size + 3),
      hjust = 0.5,
      face = 'plain',
      margin = margin(t = 10 * scale, b = 5 * scale)
    ),
    plot.subtitle = element_text(
      hjust = 0.5,
      size = scale * (base_size + 1),
      face = 'bold',
      margin = margin(t = 5 * scale, b = 12 * scale)
    ),
    plot.caption = element_text(
      color = caption_color,
      size = scale * (base_size - 2),
      face = 'plain',
      hjust = 1,
      margin = margin(t = 8 * scale, b = 0)
    ),
    plot.background = element_rect(
      fill = background_color,
      color = background_color
    ),
    plot.margin = margin(rep(10 * scale, 4))
  ) +

  # format panel
  theme(
    panel.background = element_rect(
      fill = background_color,
      color = background_color,
      size = 0
    ),
    panel.border = element_rect(color = background_color)
  ) +

  # format grid
  theme(
    panel.spacing.x = unit(1.5 * scale, 'lines'),
    panel.spacing.y = unit(1.5 * scale, 'lines'),
    panel.grid.major = element_line(
      color = grid_major_color,
      size = 0.25 * scale
    ),
    panel.grid.minor = element_blank()
  ) +

  # format strip
  theme(
    strip.background = element_rect(fill = strip_background, color = NA),
    strip.text.x = element_text(color = text_color, face = 'plain'),
    strip.text.y = element_text(color = text_color, face = 'plain')
  ) +

  # format legend
  theme(
    legend.background = element_rect(fill = background_color),
    legend.text = element_text(
      size = scale * (base_size - 2),
      color = axis_text_color
    ),
    legend.title = element_text(color = axis_title_color),
    legend.key = element_rect(fill = background_color)
  ) +

  # format axes labels and tick marks
  theme(
    axis.ticks = element_blank(),
    axis.text.x = element_text(
      size = scale * (base_size - 2),
      color = axis_text_color
    ),
    axis.text.y = element_text(
      size = scale * (base_size - 2),
      color = axis_text_color
    ),
    axis.title.x = element_text(
      color = axis_title_color, vjust = 0,
      margin = margin(t = 8 * scale, r = 0, b = 0, l = 0)
    ),
    axis.title.y = element_text(
      color = axis_title_color, vjust = 1.25,
      margin = margin(t = 0, r = 8 * scale, b = 0, l = 0)
    )
  )
}

# set default plot colors
geom_aes_defaults <- function() {
  geom_names <- utils::apropos('^Geom', ignore.case = FALSE)
  geoms <- mget(geom_names, env = asNamespace('ggplot2'))
  map(geoms, ~ .$default_aes)
}

replace_geom_aes_defaults <- function(name, old_aes, new_aes) {
  matching_geoms <-
    map(geom_aes_defaults(), name) %>%
      compact() %>%
      keep(~ !is.na(.) & . == old_aes)
  geoms <- gsub('^Geom(.*)', '\\1', names(matching_geoms))
  walk(geoms, update_geom_defaults, stats::setNames(list(new_aes), name))
}

replace_geom_aes_defaults('colour', 'black', '#333333')
replace_geom_aes_defaults('fill', 'grey35', '#333333')

# redefine ggplot function
ggplot <- function(...) {
  ggplot2::ggplot(...) +
    scale_color_manual(values = spren9er_palette()) +
    scale_fill_manual(values = spren9er_palette())
}

# set spren9er palette and theme
invisible(grDevices::palette(spren9er_palette()))
invisible(theme_set(spren9er_theme()))
