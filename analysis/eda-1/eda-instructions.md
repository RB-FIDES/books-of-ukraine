# EDA Instructions: Separate Window Plotting

## R Function for Separate Window Plotting

Use these functions to display ggplot2 plots in separate windows outside of VS Code:

```r
# Function to display plot in separate window (cross-platform)
show_plot_window <- function(plot_obj, width = 10, height = 6) {
  # Detect operating system and use appropriate graphics device
  os_type <- Sys.info()["sysname"]
  
  if (os_type == "Windows") {
    windows(width = width, height = height)
  } else if (os_type == "Darwin") {  # macOS
    quartz(width = width, height = height)
  } else {  # Linux and others
    x11(width = width, height = height)
  }
  
  print(plot_obj)
  return(plot_obj)
}

# Alternative: Use dev.new() which is cross-platform
show_plot_new_device <- function(plot_obj, width = 10, height = 6) {
  dev.new(width = width, height = height)
  print(plot_obj)
  return(plot_obj)
}
```

## Usage Examples

```r
# Create your ggplot
my_plot <- ggplot(data, aes(x, y)) + 
  geom_point() + 
  theme_minimal()

# Display in separate window
show_plot_window(my_plot)

# Or with custom dimensions
show_plot_window(my_plot, width = 12, height = 8)

# Alternative method
show_plot_new_device(my_plot)
```

## Direct Device Opening

You can also open graphics devices directly:

```r
# Windows
windows(width = 10, height = 6)
print(my_plot)

# macOS
quartz(width = 10, height = 6)
print(my_plot)

# Linux
x11(width = 10, height = 6)
print(my_plot)

# Cross-platform
dev.new(width = 10, height = 6)
print(my_plot)
```

## Benefits

- **Independent viewing**: Plot windows are separate from VS Code
- **Multiple plots**: Can have several plot windows open simultaneously  
- **Resizable**: You can resize plot windows as needed
- **Persistent**: Windows stay open until you close them
- **Better for presentation**: Cleaner view without VS Code interface
