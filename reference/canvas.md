# Set and get Canvas course, URL, and token

These functions set and retrieve the Canvas course ID, URL, and token
from environment variables. This allows for easy configuration of API
calls to the Canvas API without hardcoding sensitive information in the
code.

## Usage

``` r
set_canvas_course_id(course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"))

get_canvas_course_id()

set_canvas_url(url = Sys.getenv("CANVASQUIZ_URL"))

get_canvas_url()

set_canvas_token(token = Sys.getenv("CANVASQUIZ_TOKEN"))

get_canvas_token()
```

## Arguments

- course_id:

  The Canvas course ID to use for API calls.

- url:

  The base URL for the Canvas instance (e.g., "https://
  canvas.instructure.com").

- token:

  The API token for authenticating with the Canvas API.
