# EDA-2 Presentation Instructions

## Important: Interactive Tools in Presentations

**⚠️ Recommendation: Avoid Interactive Widgets in RevealJS Presentations**

For RevealJS presentations (.qmd files), it's recommended to **avoid using interactive tools** such as:
- **Plotly charts** (`library(plotly)`)
- **DT interactive tables** (`library(DT)`)
- **Leaflet maps** (`library(leaflet)`)
- **Other HTML widgets**

**Why avoid interactive tools in presentations?**
- **Performance issues**: Can slow down slide transitions and rendering
- **Compatibility problems**: May not work consistently across different browsers/devices
- **Display issues**: Interactive toolbars and sidebars can interfere with slide layout
- **Presentation flow**: Interactive elements can distract from the main presentation narrative
- **Export limitations**: PDF export and printing may not work properly with interactive elements

**Better alternatives for presentations:**
- **Static ggplot2 charts**: Fast, reliable, and print-friendly
- **Static tables with knitr::kable()**: Clean, professional appearance
- **Static maps with ggplot2**: Consistent rendering across platforms
- **Images and static visualizations**: Always work reliably

**When to use interactive tools:**
- **Exploratory analysis documents** (separate .qmd or .Rmd files)
- **Web dashboards and reports**
- **Interactive data exploration sessions**
- **Standalone HTML documents**

## Quality Assurance: Check for Empty Slides

**⚠️ Important: Always Check for Empty Slides Before Presenting**

Empty or broken slides can disrupt presentation flow and appear unprofessional. Always perform a quality check:

**Common causes of empty slides:**
- **Data loading errors**: Missing or inaccessible data files
- **Code chunk failures**: R code errors that prevent content generation
- **Missing images**: Broken image paths or missing files
- **Failed table generation**: Data processing errors
- **Rendering issues**: Quarto/knitr processing problems

**How to check for empty slides:**

1. **Visual Review**: Open the rendered HTML and scroll through every slide
2. **Check for Error Messages**: Look for R error outputs or warning messages
3. **Verify Data Content**: Ensure all charts, tables, and statistics display correctly
4. **Test Navigation**: Use arrow keys to navigate through all slides
5. **Review in Overview Mode**: Press ESC to see all slides in grid view

**Pre-presentation checklist:**
- ✅ All slides contain expected content
- ✅ No error messages or warnings visible
- ✅ All charts and visualizations render properly
- ✅ Tables display correctly with data
- ✅ All inline R code produces expected values
- ✅ Images and logos appear correctly
- ✅ Footer and header information displays on all slides

**Quick fix for common issues:**
- **Missing data**: Check file paths and data availability
- **Code errors**: Review R chunks for syntax or logic errors
- **Image problems**: Verify image file paths and existence
- **Rendering failures**: Re-run `quarto render` and check console output

**Best practice**: Always do a complete slide review after any code changes or data updates.

## Complete Feature Overview

This RevealJS presentation includes multiple interactive and professional features configured in the YAML header.

### Current Configuration Summary

```yaml
format: 
  revealjs:
    theme: simple                    # Clean, professional appearance
    slide-number: true              # Show slide numbers for navigation
    chalkboard:                     # Interactive drawing functionality
      theme: chalkboard
      boardmarker-width: 3
      chalkwidth: 4
      chalkeffect: 1.0
      storage: true
    preview-links: auto             # Link previews in presentation
    logo: "../../libs/images/ukraine-flag.png"  # Ukraine flag logo
    footer: "Ukrainian Book Publishing Trends | 2005-2023"  # Footer info
    progress: true                  # Progress bar at bottom
    hash: true                      # URL updates with slide numbers
    overview: true                  # ESC key shows all slides
    highlight-style: github         # GitHub-style code highlighting
    code-line-numbers: true         # Line numbers in code blocks
    code-copy: true                 # Copy buttons for code
    smaller: true                   # Enable smaller text class
    scrollable: false               # Allow slide content to scroll
    touch: true                    # Enable touch/swipe navigation
    controls-tutorial: true        # Show control tutorial overlay
    controls-layout: bottom-right  # Position of navigation controls
    menu:                          # Navigation menu system
      numbers: true                # Show slide numbers in menu
      titles: true                 # Show slide titles in menu
      useTextContentForMissingTitles: true
      themes: true                 # Theme switcher in menu
      transitions: true            # Transition effects menu
      openButton: true             # Show menu button
```

### Feature Categories

**🎨 Visual & Theme:**
- **Theme**: Simple, clean professional look
- **Slide Numbers**: Visible numbering for easy reference
- **Logo**: Ukraine flag in top corner
- **Footer**: Project title and timeframe on every slide

## Theme Selection Guide

**⚠️ Always Ask Client for Theme Preference**

Before creating or modifying a presentation, ask the client which theme they prefer:

**Available Themes (with brief descriptions):**

**Professional Themes:**
- **`simple`** - Clean, minimal (current default)
- **`white`** - Classic white background
- **`beige`** - Warm, professional

**Dark Themes:**
- **`night`** - Dark with white text (great for projectors)
- **`black`** - High contrast dark
- **`moon`** - Dark blue modern

**Creative Themes:**
- **`sky`** - Blue gradient
- **`blood`** - Dark with red accents
- **`league`** - Gray professional

**Example question to ask:**
*"Which presentation theme would you prefer? I recommend **`simple`** for clean data presentations, **`night`** for projector use, or **`white`** for classic look. Would you like to see all options?"*

**How to update theme:**
```yaml
theme: night  # Change this value in the YAML header
```

## Scrollable Configuration

**⚠️ Important: Always Keep Scrollable Set to False**

For professional presentations, always ensure `scrollable: false` in the RevealJS configuration:

```yaml
scrollable: false  # Disable slide content scrolling
```

**Why scrollable should be false:**
- **Professional appearance**: Content fits within slide boundaries
- **Traditional presentation experience**: No unexpected scrolling during presentation
- **Better flow control**: Forces concise, well-structured slide content
- **Consistent viewing**: All audience members see the same content layout
- **Print-friendly**: Better PDF export and printing results

**Best practice**: Design slide content to fit within standard slide dimensions rather than relying on scrolling.

## Color Palette Selection

**⚠️ Always Ask Client for Color Palette Preference**

Before setting slide background colors, always ask the client which color approach they prefer:

### Option 1: Fade/Gradient Palette

**Description**: Smooth transition from one color to another across all slides

**Example gradients:**
- **Red to Green**: `#FF4444` → `#226644` (bright to dark)
- **Blue to Purple**: `#4A90E2` → `#8E44AD` (cool transition)
- **Orange to Blue**: `#FF6B35` → `#1E3A8A` (warm to cool)
- **Yellow to Red**: `#FFD700` → `#DC143C` (energetic)
- **Green to Blue**: `#228B22` → `#1E3A8A` (natural)

**How to ask:**
*"Would you like a color gradient across slides? For example, starting bright red and ending dark green, or blue transitioning to purple?"*

### Option 2: Theme-Based Colors

**Description**: Colors that match the overall presentation theme and content

**Professional Business Themes:**
- **Corporate Blue**: Various shades of blue (`#003366`, `#0066CC`, `#3399FF`)
- **Academic Gray**: Professional grays (`#2F4F4F`, `#696969`, `#A9A9A9`)
- **Finance Green**: Money/growth colors (`#006400`, `#228B22`, `#32CD32`)

**Ukraine-Specific Themes:**
- **National Colors**: Blue and yellow variations (`#005BBB`, `#FFD700`)
- **Regional Colors**: Different colors for different Ukrainian regions
- **Cultural Heritage**: Traditional Ukrainian color combinations

**Data-Focused Themes:**
- **Chart Colors**: Match the colors used in your data visualizations
- **Categorical**: Different colors for different data categories
- **Sequential**: Light to dark for ordered data

**Example questions:**
*"Would you prefer colors that match the Ukrainian flag (blue and yellow), professional corporate colors, or colors that complement your data visualizations?"*

### Option 3: Custom Colors

**Description**: Client specifies exact colors they want to use

**How to ask:**
*"Do you have specific brand colors or preferred colors you'd like me to use? Please provide hex codes (like #FF0000) or color names."*

**Common custom requests:**
- **Brand Colors**: Company/organization specific colors
- **Personal Preference**: Client's favorite colors
- **Accessibility Colors**: High contrast for visibility
- **Print-Friendly**: Colors that work well in black and white

### Color Selection Template

**Always ask this question before setting colors:**

*"For the slide backgrounds, I can create:*
1. *A **gradient/fade** from one color to another (like red to green)*
2. *A **theme-based** color scheme (Ukrainian national colors, professional business, academic)*
3. *Your **custom colors** (if you have specific preferences)*

*Which approach would you prefer? If gradient, which two colors? If theme-based, which theme? If custom, what colors?"*

### Default Color Theme

**⚠️ Important: Use Dark Theme as Default if Client Doesn't Specify**

If the client does not provide specific color preferences or does not respond to your color palette questions, **always use the Dark Theme as the default**:

**Default Dark Theme Implementation:**
```yaml
# Title slide
title-slide-attributes:
  data-background-color: "#2C3E50"  # Dark blue-gray

# Content slides
## Slide 1 {background-color="#34495E"}  # Medium dark gray
## Slide 2 {background-color="#2C3E50"}  # Dark blue-gray
## Slide 3 {background-color="#1A252F"}  # Darker gray
## Slide 4 {background-color="#273746"}  # Dark slate
## Slide 5 {background-color="#212F3D"}  # Very dark blue
```

**Why Dark Theme as Default:**
- ✅ **Professional Appearance**: Sophisticated and modern look
- ✅ **High Contrast**: Excellent text readability with light text
- ✅ **Projector Friendly**: Works well in various lighting conditions
- ✅ **Eye Comfort**: Reduces eye strain during presentations
- ✅ **Universally Appropriate**: Suitable for all professional contexts
- ✅ **Print Compatible**: Converts well to grayscale for handouts

**When to use default:**
- Client doesn't respond to color preference questions
- Client says "whatever you think is best"
- No specific brand or theme requirements mentioned
- Time constraints prevent detailed color discussion

### Technical Implementation

**Gradient Implementation:**
```yaml
# Slide 1 (brightest)
## Introduction {background-color="#FF4444"}

# Slide 2 
## Data Overview {background-color="#FF6A33"}

# ... continue progression ...

# Final slide (darkest)
## Conclusion {background-color="#226644"}
```

**Theme Implementation:**
```yaml
# Ukrainian National Theme
## Introduction {background-color="#005BBB"}  # Ukrainian blue
## Data {background-color="#FFD700"}         # Ukrainian yellow
## Analysis {background-color="#0066CC"}     # Lighter blue
```

**Custom Implementation:**
```yaml
# Use client's specified colors
## Introduction {background-color="#CLIENT_COLOR_1"}
## Data {background-color="#CLIENT_COLOR_2"}
```

### Color Best Practices

- ✅ **High Contrast**: Ensure text is readable on background
- ✅ **Consistent Progression**: Logical color flow across slides  
- ✅ **Professional Appearance**: Avoid overly bright or jarring colors
- ✅ **Cultural Sensitivity**: Consider cultural meanings of colors
- ✅ **Accessibility**: Test with colorblind-friendly tools
- ✅ **Print Compatibility**: Colors should work in grayscale

**🎮 Interactive Drawing:**
- **Chalkboard Mode** (`C` key): Dark overlay with chalk drawing
- **Notes Mode** (`B` key): Draw directly on slides with marker
- **Persistent Storage**: Drawings saved in browser
- **Customizable Tools**: Different pen widths and colors

**📊 Navigation & Progress:**
- **Progress Bar**: Visual progress indicator at bottom
- **Hash URLs**: Each slide gets bookmarkable URL
- **Overview Mode** (`ESC` key): Grid view of all slides
- **Slide Numbers**: Easy reference and navigation

**📝 Speaker Support:**
- **Speaker Notes** (`S` key): Toggle notes overlay
- **Code Highlighting**: GitHub-style syntax highlighting
- **Code Features**: Line numbers and copy buttons

**🔧 Technical Features:**
- **Link Previews**: Automatic preview of external links
- **Responsive Design**: Works on desktop and mobile
- **Browser Integration**: Back/forward buttons work
- **Menu System**: Navigation menu with themes and transitions
- **Touch Controls**: Swipe navigation with tutorial overlay
- **Text Options**: Smaller text and scrollable content support

## Speaker Notes and Speaker Mode

This RevealJS presentation includes speaker notes functionality that allows you to access presentation notes during your talk.

### Speaker Notes Configuration

The speaker notes are configured in the YAML header with default behavior:

```yaml
format: 
  revealjs:
    # No show-notes setting = default behavior
    # Notes are hidden by default, accessible with S key
```

### Speaker Notes vs Speaker Mode

**Speaker Notes (`S` key):**
- Shows only the notes content as overlay
- Simple popup with just your `:::notes` text
- No additional interface elements
- Toggle on/off with same key

**Speaker Mode (full speaker view):**
- Complete presenter interface
- Shows current slide, next slide, notes, timer
- Opens in separate window/tab
- Professional presentation tool

### Keyboard Controls for Notes

| Key | Function |
|-----|----------|
| `S` | Toggle speaker notes overlay (recommended) |
| `F` | Enter fullscreen mode |
| `ESC` | Exit fullscreen or overview modes |

### How to Use Speaker Notes

1. **Add Notes to Slides:**
   ```markdown
   ::: notes
   Your speaker notes content goes here.
   This text will appear when you press S.
   :::
   ```

2. **During Presentation:**
   - Press `S` to show notes overlay
   - Press `S` again to hide notes
   - Notes appear as semi-transparent overlay on current slide

3. **Notes Content:**
   - Only visible to presenter
   - Audience sees normal slide content
   - Can include detailed talking points, reminders, data explanations

### Speaker Notes Best Practices

- **Keep notes concise** - Easy to read at a glance
- **Use bullet points** - Quick reference format
- **Include key statistics** - Numbers, percentages, important facts
- **Add timing cues** - "Pause here", "Ask questions", "2 minutes on this slide"
- **Note transitions** - "Next slide shows...", "Building on this..."

### Configuration Options

Different speaker notes behaviors:

```yaml
# Default (recommended): Notes hidden, toggle with S
# No show-notes setting

# Always show notes below slides
show-notes: true

# Hide notes completely (disable S key)
show-notes: false

# Full speaker view in separate window
show-notes: separate-page
```

## Navigation Features

This presentation includes several navigation and progress tracking features to enhance the user experience.

### Progress Bar

A progress bar is displayed at the bottom of the presentation showing your position:

```yaml
progress: true
```

**Features:**
- **Visual Progress** - Shows how far through the presentation you are
- **Audience Awareness** - Helps audience know remaining time
- **Color-coded** - Matches presentation theme
- **Always Visible** - Appears at bottom of every slide

### Hash URLs (Bookmarkable Slides)

Each slide gets a unique URL for easy sharing and bookmarking:

```yaml
hash: true
```

**Benefits:**
- **Shareable Links** - Send specific slide URLs to others
- **Browser History** - Back/forward buttons work with slides
- **Bookmarks** - Save important slides for later reference
- **Deep Linking** - Start presentation from any slide

**Usage:**
- URL updates automatically as you navigate: `presentation.html#/slide-3`
- Share specific slides: Copy URL from address bar
- Bookmark key slides for quick access

### Overview Mode

Press `ESC` to see all slides at once in a grid layout:

```yaml
overview: true
```

**How to Use:**
1. **Press `ESC`** - Enter overview mode
2. **Click any slide** - Jump directly to that slide
3. **Use arrow keys** - Navigate in overview
4. **Press `ESC` again** - Exit overview mode

**Benefits:**
- **Quick Navigation** - Jump to any slide instantly
- **Presentation Structure** - See overall flow and organization
- **Q&A Sessions** - Perfect for finding specific slides during questions
- **Slide Review** - Easy way to review all content at once

### Footer Information

The presentation includes a persistent footer with key information:

```yaml
footer: "Ukrainian Book Publishing Trends | 2005-2023"
```

**⚠️ Important: Customize Footer Based on Your Data**

**Always update the footer to reflect the actual data you're presenting:**

- **Update Time Period**: Match the actual years in your dataset
  ```yaml
  # Example for different time periods:
  footer: "Ukrainian Book Publishing Trends | 2010-2022"  # If data spans 2010-2022
  footer: "Ukrainian Book Publishing Trends | 2005-2020"  # If data ends in 2020
  ```

- **Update Geographic Scope**: Reflect the actual geographic coverage
  ```yaml
  # Examples for different geographic scopes:
  footer: "Kyiv Region Book Publishing | 2005-2023"       # Regional analysis
  footer: "Western Ukraine Publishing Trends | 2005-2023" # Multi-regional
  footer: "Ukrainian Publishing: Urban vs Rural | 2005-2023" # Comparative analysis
  ```

- **Update Content Focus**: Match the specific analysis being presented
  ```yaml
  # Examples for different content focuses:
  footer: "Ukrainian vs Russian Publications | 2005-2023"  # Language comparison
  footer: "Academic Publishing in Ukraine | 2005-2023"     # Genre-specific
  footer: "Digital vs Print Publishing | 2005-2023"        # Format comparison
  ```

**Footer Best Practices:**
- ✅ **Accurate Time Range**: Use exact start and end years from your data
- ✅ **Specific Geographic Scope**: Be precise about regions covered
- ✅ **Clear Content Description**: Briefly describe what's being analyzed
- ✅ **Consistent Throughout**: Same footer appears on every slide
- ✅ **Concise Format**: Keep it short for visual clarity

**Footer Contents:**
- **Project Title** - "Ukrainian Book Publishing Trends" (or your specific focus)
- **Time Period** - "2005-2023" (or your actual data range)
- **Always Visible** - Appears on every slide
- **Consistent Branding** - Maintains presentation identity

### Keyboard Controls for Navigation

| Key | Function |
|-----|----------|
| `ESC` | Toggle overview mode (see all slides) |
| `Arrow Keys` | Navigate slides in normal or overview mode |
| `Space` | Next slide |
| `Shift + Space` | Previous slide |
| `Home` | First slide |
| `End` | Last slide |
| `F` | Fullscreen mode |

### Navigation Best Practices

- **Use Overview Mode** during Q&A to quickly find relevant slides
- **Share Hash URLs** to point colleagues to specific findings
- **Monitor Progress Bar** to manage presentation timing
- **Bookmark Key Slides** for follow-up discussions
- **Use Footer Info** to remind audience of scope and timeframe

## Interactive Drawing/Writing on Slides

This RevealJS presentation includes chalkboard functionality that allows you to draw and write directly on slides during presentation.

### How to Enable Drawing Mode

The drawing functionality is already configured in the YAML header:

```yaml
format: 
  revealjs:
    theme: simple
    slide-number: true
    chalkboard: 
      theme: chalkboard
      boardmarker-width: 3
      chalkwidth: 4
      chalkeffect: 1.0
      storage: true
    preview-links: auto
    logo: "../../libs/images/ukraine-flag.png"
    footer: "Ukrainian Book Publishing Trends | 2005-2023"
```

### Keyboard Controls

| Key | Function |
|-----|----------|
| `S` | Toggle speaker notes overlay |
| `ESC` | Toggle overview mode (see all slides) |
| `C` | Toggle chalkboard mode (dark background with chalk) |
| `B` | Toggle notes mode (draw on current slide with marker) |
| `DEL` | Clear all drawings on current slide |
| `D` | Download drawings as JSON file |
| `F` | Enter fullscreen mode |
| `Arrow Keys` | Navigate slides |
| `Space` | Next slide |
| `Home/End` | First/Last slide |

### Drawing Modes

1. **Chalkboard Mode (`C` key)**:
   - Creates a dark overlay where you can draw with chalk
   - Realistic chalk effect and texture
   - Good for temporary annotations and explanations

2. **Notes Mode (`B` key)**:
   - Draw directly on the current slide
   - Uses marker-style drawing
   - Ideal for highlighting and annotating slide content

### Drawing Tools

When in drawing mode, a toolbar appears with:
- **Color palette** - Multiple colors for drawing
- **Pen/Chalk tool** - Primary drawing tool
- **Eraser** - Remove specific drawings
- **Clear button** - Remove all drawings from current slide
- **Download** - Save drawings as file

### Features

- ✅ **Persistent Storage**: Drawings are automatically saved in browser
- ✅ **Customizable Pen Width**: Boardmarker (3px), Chalk (4px)
- ✅ **Realistic Effects**: Chalk texture and opacity effects
- ✅ **Cross-slide Navigation**: Drawings preserved when navigating slides

### Usage Tips

1. **Start Drawing**: Press `C` or `B` to activate drawing mode
2. **Select Tool**: Use toolbar to choose colors and tools
3. **Draw/Write**: Click and drag to create annotations
4. **Exit Mode**: Press the same key (`C` or `B`) to exit
5. **Navigate**: Use arrow keys or space to move between slides
6. **Clear**: Use `DEL` to clear current slide or eraser for selective removal

### Best Practices

- Use **chalkboard mode** for temporary explanations
- Use **notes mode** for permanent annotations on slides
- Choose contrasting colors for visibility
- Save important drawings using the download function
- Test drawing functionality before presenting

### Technical Configuration

The chalkboard settings can be customized in the YAML header:

```yaml
chalkboard: 
  theme: chalkboard          # Visual theme
  boardmarker-width: 3       # Marker pen width
  chalkwidth: 4             # Chalk width
  chalkeffect: 1.0          # Chalk opacity effect
  storage: true             # Enable persistent storage
```

### Troubleshooting

- **Drawings not appearing**: Ensure JavaScript is enabled in browser
- **Toolbar missing**: Try refreshing the page and pressing `C` again
- **Drawings not saving**: Check browser local storage permissions
- **Performance issues**: Clear old drawings or disable storage temporarily

## Menu System

The presentation includes a comprehensive menu system accessible via:
- **Access**: Click the menu button (bottom-right corner)
- **Navigation**: Shows slide numbers and titles for easy jumping
- **Theme Switcher**: Change visual themes during presentation
- **Transition Effects**: Modify slide transitions on the fly
- **Slide Navigation**: Jump directly to any slide

### Menu Features
- **Slide Numbers**: Shows numbered list of all slides
- **Slide Titles**: Displays slide titles for context
- **Theme Options**: Switch between different visual themes
- **Transition Control**: Change slide transition effects
- **Always Available**: Menu button stays visible during presentation

### How to Use Menu
1. Click the menu button (appears in bottom-right corner)
2. Select from available options:
   - **Slides**: Jump to any slide by number or title
   - **Themes**: Try different visual styles
   - **Transitions**: Change how slides animate
3. Menu closes automatically after selection

## Touch and Mobile Features

Enhanced mobile and touch device support for presentations:

### Touch Navigation
- **Swipe Navigation**: Left/right swipes change slides
- **Touch Drawing**: Use finger to draw on chalkboard (if enabled)
- **Responsive Design**: Adapts to different screen sizes
- **Mobile Optimized**: Works smoothly on tablets and phones

### Control Tutorial
- **Tutorial Overlay**: First-time users see control instructions
- **Help System**: Shows available gestures and controls
- **Position Control**: Controls positioned for easy mobile access
- **Touch-Friendly**: Large touch targets for mobile interaction

### Configuration Options
```yaml
touch: true                    # Enable touch/swipe navigation
controls-tutorial: true        # Show control tutorial overlay
controls-layout: bottom-right  # Position of navigation controls
```

