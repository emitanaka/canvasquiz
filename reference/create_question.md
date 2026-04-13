# Create a Quiz Question

This function creates a quiz question directly into Canvas. You can
create a variety of question types, including multiple choice, short
answer, numerical answer, matching, essay, file upload, and text-only
questions.

## Usage

``` r
create_question(
  text = NULL,
  answers = NULL,
  points = 1,
  quiz_id = last_quiz_id(),
  quiz_group_id = NULL,
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

- text:

  Character. The text of the question.

- answers:

  A list of answer objects.

- points:

  The maximum amount of points received for answering this question
  correctly.

- quiz_id:

  The id of the quiz to add the question to.

- quiz_group_id:

  The id of the quiz group to add the question to.

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

## Value

A list representing the quiz question.

## Details

The question comments is correctly entered, however, Canvas doesn't seem
to display them initially. Manually editing the quiz and saving it again
seems to fix the issue and then the comments are displayed as expected.
