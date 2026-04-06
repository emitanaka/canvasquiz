# Get quiz submission details

Get quiz submission details

## Usage

``` r
submission_info(
  submission_id,
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN")
)
```

## Arguments

- submission_id:

  The ID of the quiz submission to retrieve details for.

- course_id:

  The course id. Defaults to the value of the `CANVASQUIZ_COURSE_ID`
  environment variable.

- url:

  The canvas url. Defaults to the value of the `CANVASQUIZ_URL`
  environment variable.

- token:

  The canvas token. Defaults to the value of the `CANVASQUIZ_TOKEN`
  environment variable.
