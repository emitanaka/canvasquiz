# Generate an HTML link to download a file in a Canvas course This function creates an HTML link that allows users to download a file stored in a Canvas course. The link will point to the download URL for the specified file.

Generate an HTML link to download a file in a Canvas course This
function creates an HTML link that allows users to download a file
stored in a Canvas course. The link will point to the download URL for
the specified file.

## Usage

``` r
tag_file(file_id, text = "Download")

upload_tag_file(
  file_path,
  text = "Download",
  folder_id = NULL,
  course_id = Sys.getenv("CANVAS_COURSE_ID"),
  url = Sys.getenv("CANVAS_URL"),
  token = Sys.getenv("CANVAS_TOKEN")
)
```

## Arguments

- file_id:

  The file ID of the file in Canvas.

- text:

  The text to display for the download link (default is "Download").

## Value

A character string containing the HTML link to download the specified
file.
