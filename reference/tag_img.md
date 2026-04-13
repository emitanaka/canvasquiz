# Generate an HTML image tag for a file in a Canvas course

This function creates an HTML `<img>` tag that can be used to display an
image file stored in a Canvas course. The image will be displayed at 50%
width.

## Usage

``` r
tag_img(
  file_id,
  width = "100%",
  class = "",
  course_id = Sys.getenv("CANVAS_COURSE_ID")
)

upload_tag_img(
  file_path,
  width = "100%",
  class = "",
  folder_id = NULL,
  course_id = Sys.getenv("CANVAS_COURSE_ID"),
  url = Sys.getenv("CANVAS_URL"),
  token = Sys.getenv("CANVAS_TOKEN")
)
```

## Arguments

- file_id:

  The file ID of the image in Canvas.

- width:

  The width of the image (default is "100%").

- class:

  Optional CSS class to apply to the `<img>` tag.

- course_id:

  The ID of the Canvas course where the file is stored (default is taken
  from the environment variable `CANVAS_COURSE_ID`).

## Value

A character string containing the HTML `<img>` tag for the specified
image file.
