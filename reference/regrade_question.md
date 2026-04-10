# Regrade quiz submissions based on answer

If you leave the answer as NULL, it will not filter the submissions.

## Usage

``` r
regrade_question(
  question_id,
  quiz_id,
  answer = NULL,
  fudge_points = NULL,
  score = NULL,
  comment = NULL,
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN")
)
```

## Arguments

- question_id:

  The ID of the question to regrade.

- answer:

  The answer to regrade. Can be numeric or character or one of the
  answer functions.

- course_id:

  The course id. Defaults to the value of the `CANVASQUIZ_COURSE_ID`
  environment variable.

- url:

  The canvas url. Defaults to the value of the `CANVASQUIZ_URL`
  environment variable.

- token:

  The canvas token. Defaults to the value of the `CANVASQUIZ_TOKEN`
  environment variable.
