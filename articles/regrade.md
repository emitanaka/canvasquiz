# Regrading quiz submissions

Canvas quizzes have limited support in regrading quiz submissions for
numerical answers. Where the original answer was wrong, there is no way
to regrade the existing submissions upon changing the answer to the
question. In this case, the grader will have to manually update the
score for each submission. Since the submission will continue to be
marked wrong, it is also recommended to leave a comment for the student.

But let’s face it. That’s a lot of painful manual work. The
[`regrade()`](http://emitanaka.org/canvasquiz/reference/regrade.md)
function in the `canvasquiz` package allows you to regrade quiz
submissions for a specific question based on the answer that was
submitted. You can specify the new score, comment, and fudge points for
all submissions that match the specified answer. This can save you a lot
of time and effort in regrading quiz submissions.

``` r
library(canvasquiz)
```

## Step 0: Set up the environment

Before you can use the functions in this vignette, you need to set up
your environment variables for the Canvas API. See the [setup
vignette](http://emitanaka.org/canvasquiz/articles/setup.Rmd) for
instructions on how to do this.

## Step 1: Get the quiz ID

You can find the quiz ID from the URL of the quiz. For example, if the
quiz URL is `https://canvas.instructure.com/courses/123/quizzes/456`,
then the quiz ID is `456`. You can also use the
[`list_quizzes()`](http://emitanaka.org/canvasquiz/reference/list_quizzes.md)
function to get a list of quizzes and their IDs.

``` r
list_quizzes()
#> # A tibble: 3 × 45
#>      id title              html_url  mobile_url description quiz_type time_limit
#>   <int> <chr>              <chr>     <chr>      <chr>       <chr>          <int>
#> 1 23542 Quiz 1             https://… https://c… "<p>This a… assignme…         30
#> 2 23541 Quiz for questions https://… https://c… ""          practice…         NA
#> 3 23543 Quiz for questions https://… https://c…  NA         practice…         NA
#> # ℹ 38 more variables: timer_autosubmit_disabled <lgl>, shuffle_answers <lgl>,
#> #   show_correct_answers <lgl>, scoring_policy <chr>, allowed_attempts <int>,
#> #   one_question_at_a_time <lgl>, question_count <int>, points_possible <dbl>,
#> #   cant_go_back <lgl>, published <lgl>, unpublishable <lgl>,
#> #   locked_for_user <lgl>, lock_info <list>, lock_explanation <chr>,
#> #   all_dates <list>, can_unpublish <lgl>, can_update <lgl>,
#> #   require_lockdown_browser <lgl>, …
```

## Step 2: Get the question ID for the question you want to regrade

After identifying the quiz ID, you can use the
[`list_attempted_questions()`](http://emitanaka.org/canvasquiz/reference/list_attempted_questions.md)
function to get a list of attempted questions for that quiz, along with
their question IDs and submission IDs. You will need to identify the
question ID for the question you want to regrade.

``` r
list_attempted_questions(quiz_id = 23542)
#> # A tibble: 15 × 8
#>    question_id quiz_id position question_name question_type        question_text
#>          <dbl>   <dbl>    <dbl> <chr>         <chr>                <chr>        
#>  1      238186   23542        1 Question 1    numerical_question   "What is 2 +…
#>  2      238187   23542        2 Question 2    numerical_question   "What is the…
#>  3      238188   23542        3 Question 3    numerical_question   "What is the…
#>  4      238189   23542        4 Question 4    numerical_question   "What is the…
#>  5      238190   23542        5 Question 5    numerical_question   "What is the…
#>  6      238191   23542        6 Question 6    multiple_choice_que… "Which of th…
#>  7      238192   23542        7 Question 7    multiple_answers_qu… "Which of th…
#>  8      238193   23542        8 Question 8    true_false_question  "The Earth i…
#>  9      238194   23542        9 Question 9    short_answer_questi… "What is the…
#> 10      238195   23542       10 Question 10   essay_question       "Describe th…
#> 11      238196   23542       11 Question 11   matching_question    "Match the f…
#> 12      238197   23542       12 Question 12   multiple_dropdowns_… "Roses are <…
#> 13      238198   23542       13 Question 13   fill_in_multiple_bl… "Roses are <…
#> 14      238199   23542       14 Question 14   fill_in_multiple_bl… "Roses are <…
#> 15      238200   23542       15 Question 15   file_upload_question "Upload a fi…
#> # ℹ 2 more variables: submission_id <list>, n <int>
```

## Step 3: Regrade the submissions

Let’s say you want to regrade question ID `238187` for quiz ID `23542`
for all those that entered the value `7`. The
[`regrade()`](http://emitanaka.org/canvasquiz/reference/regrade.md)
function will modify the score, comment, or fudge points for all
submissions that match the specified answer.

``` r
regrade(question_id = 238187, 
        quiz_id = 23542, 
        answer = answer_num(7, tol = 0.01),
        fudge_points = 2, 
        score = 2, 
        comment = "Regraded to 2 points since the answer is correct.")
#> Updated submission 70081 for "Test Student" on quiz "Quiz 1" (attempt 1, score
#> before regrade: 6).
```
