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

## Value

A data frame with submission id, quiz id, question name, question type,
question text, whether the question was flagged, whether the question
was correct, assessment question id, quiz group id, and the answers
provided.

## See also

Other submissions:
[`list_submissions()`](http://emitanaka.org/canvasquiz/reference/list_submissions.md),
[`submission_overview()`](http://emitanaka.org/canvasquiz/reference/submission_overview.md),
[`submission_questions()`](http://emitanaka.org/canvasquiz/reference/submission_questions.md)
