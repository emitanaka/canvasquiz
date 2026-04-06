# List quiz submissions

List quiz submissions

## Usage

``` r
list_submissions(
  quiz_id,
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN"),
  n = count_submissions(quiz_id, course_id, url, token),
  tz = Sys.timezone()
)
```

## Arguments

- quiz_id:

  The ID of the quiz to retrieve statistics for.

- course_id:

  The course id. Defaults to the value of the `CANVASQUIZ_COURSE_ID`
  environment variable.

- url:

  The canvas url. Defaults to the value of the `CANVASQUIZ_URL`
  environment variable.

- token:

  The canvas token. Defaults to the value of the `CANVASQUIZ_TOKEN`
  environment variable.

- n:

  The maximum number of quiz submissions to retrieve.

- tz:

  The timezone to use for the started_at and finished_at columns.
  Defaults to the system timezone.
