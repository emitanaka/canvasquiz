# Get quiz submissions with question-level answers

Get quiz submissions with question-level answers

## Usage

``` r
quiz_submissions(
  quiz_id,
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN"),
  n = count_submissions(quiz_id, course_id, url, token)
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
