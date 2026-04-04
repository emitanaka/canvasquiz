# Add questions from a question bank to a quiz

Add questions from a question bank to a quiz

## Usage

``` r
add_question_from_bank(
  quiz_id,
  bank_id,
  title = NULL,
  n = 1L,
  points = 1L,
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN")
)
```

## Arguments

- quiz_id:

  The id of the quiz to add questions to.

- bank_id:

  The id of the question bank to pull questions from.

- title:

  (Optional) The title of the quiz group to create for these questions.
  If `NULL` (default), no quiz group will be created and questions will
  be added to the quiz without a group.

- n:

  The number of questions to randomly select from the question bank.
  Defaults to `1`.

- points:

  The number of points each question added from the bank should be
  worth. Defaults to `1`.

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

The API response from adding the questions.
