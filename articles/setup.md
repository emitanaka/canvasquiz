# Setup Canvas API environment variables

``` r
library(canvasquiz)
```

To use the functions in this package, you need to set up your
environment variables for the Canvas API. This involves setting the
following environment variables:

- `CANVASQUIZ_URL`: The base URL of your Canvas instance (e.g.,
  `https://canvas.anu.edu.au`).
- `CANVASQUIZ_TOKEN`: Your Canvas API token, which you can generated in
  your Canvas account settings under “Approved Integrations”.
- `CANVASQUIZ_COURSE_ID`: The ID of the course you want to interact
  with. The course ID can be found in the URL of your course in Canvas.
  For example if your course URL is
  `https://canvas.anu.edu.au/courses/12345`, then the course ID is
  `12345`.

You can set these environment variables in your `.Renviron` file, which
is a hidden file in your home directory. You can edit this file using
the `usethis` package:

``` r
usethis::edit_r_environ()
```

This will open your `.Renviron` file in a text editor. You can add the
following lines to set your environment variables:

    CANVASQUIZ_URL=https://canvas.instructure.com
    CANVASQUIZ_TOKEN=your_canvas_api_token
    CANVASQUIZ_COURSE_ID=your_course_id

Make sure to replace `your_canvas_api_token` and `your_course_id` with
your actual Canvas API token and course ID. After saving the `.Renviron`
file, you will need to restart your R session for the changes to take
effect.

Alternatively, you can set the environment variables directly in your R
session using the
[`Sys.setenv()`](https://rdrr.io/r/base/Sys.setenv.html) function:

``` r
Sys.setenv(CANVASQUIZ_URL = "https://canvas.instructure.com")
Sys.setenv(CANVASQUIZ_TOKEN = "your_canvas_api_token")
Sys.setenv(CANVASQUIZ_COURSE_ID = "your_course_id")
```

Or even more conveniently, you can use the following functions from the
`canvasquiz` package:

``` r
set_canvas_course_id("your_course_id")
set_canvas_token("your_canvas_api_token")
set_canvas_url("https://canvas.instructure.com")
```
