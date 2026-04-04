# Create a Quiz

Create a quiz with a number of customizable parameters.

## Usage

``` r
create_quiz(
  title,
  description = NULL,
  quiz_type = c("practice_quiz", "assignment", "graded_survey", "survey"),
  one_question_at_a_time = c("no", "yes", "yes_but_cant_go_back"),
  attempts = attempt_options(),
  publish = FALSE,
  visible = c("everyone", "none"),
  assignment_group_id = NULL,
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN")
)
```

## Arguments

- title:

  The quiz title (required).

- description:

  A description of the quiz.

- quiz_type:

  The type of quiz. Allowed values: "`practice_quiz`", "`assignment`",
  "`graded_survey`", "`survey`".

- one_question_at_a_time:

  Whether to show one question at a time. Allowed values: "`no`"
  (default), "`yes`", "`yes_but_cant_go_back`".

- attempts:

  A list of options controlling quiz attempts, as created by the
  [`attempt_options()`](http://emitanaka.org/canvasquiz/reference/attempt_options.md)
  function.

- publish:

  Whether to publish the quiz immediately. Defaults to `FALSE`.

- visible:

  Who this quiz is visible to. Allowed values: "`everyone`" (default) or
  "`none`".

- assignment_group_id:

  integer. The assignment group ID to put the assignment in. Defaults to
  the top assignment group in the course. Only valid if `quiz_type` is
  "`assignment`" or "`graded_survey`".

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

The quiz id.
