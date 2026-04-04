# Update a quiz question

Update a quiz question

## Usage

``` r
update_question(
  question_id,
  quiz_id,
  text = NULL,
  answers = NULL,
  points = NULL,
  position = NULL,
  title = NULL,
  correct_comments = NULL,
  incorrect_comments = NULL,
  neutral_comments = NULL,
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN")
)
```

## Arguments

- quiz_id:

  The id of the quiz to add the question to.

- text:

  Character. The text of the question.

- answers:

  A list of answer objects.

- points:

  The maximum amount of points received for answering this question
  correctly.

- position:

  An integer specifying the order in which the question will be
  displayed in the quiz. Doesn't seem to work.

- title:

  The name of the question.

- correct_comments:

  Comment to display if the student answers the question correctly.

- incorrect_comments:

  Comment to display if the student answers incorrectly.

- neutral_comments:

  Comment to display regardless of how the student answered.

- course_id:

  The course id. Defaults to the value of the `CANVASQUIZ_COURSE_ID`
  environment variable.

- url:

  The canvas url. Defaults to the value of the `CANVASQUIZ_URL`
  environment variable.

- token:

  The canvas token. Defaults to the value of the `CANVASQUIZ_TOKEN`
  environment variable.
