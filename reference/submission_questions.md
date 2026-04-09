# List attempted questions for a quiz

List attempted questions for a quiz

## Usage

``` r
submission_questions(
  submission_id,
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN")
)
```

## Arguments

- submission_id:

  The ID of the quiz submission to retrieve details for.

- url:

  The canvas url. Defaults to the value of the `CANVASQUIZ_URL`
  environment variable.

- token:

  The canvas token. Defaults to the value of the `CANVASQUIZ_TOKEN`
  environment variable.

## See also

Other submissions:
[`list_attempted_questions()`](http://emitanaka.org/canvasquiz/reference/list_attempted_questions.md),
[`list_submissions()`](http://emitanaka.org/canvasquiz/reference/list_submissions.md),
[`submission_info()`](http://emitanaka.org/canvasquiz/reference/submission_info.md),
[`submission_overview()`](http://emitanaka.org/canvasquiz/reference/submission_overview.md)
