#' Create a Quiz
#'
#' Create a quiz with a number of customizable parameters.
#'
#' @param title The quiz title (required).
#' @param description A description of the quiz.
#' @param quiz_type The type of quiz. Allowed values: "`practice_quiz`", "`assignment`", "`graded_survey`", "`survey`".
#' @param one_question_at_a_time Whether to show one question at a time. Allowed values: "`no`" (default), "`yes`", "`yes_but_cant_go_back`".
#' @param attempts A list of options controlling quiz attempts, as created by the [attempt_options()] function.
#' @param publish Whether to publish the quiz immediately. Defaults to `FALSE`.
#' @param visible Who this quiz is visible to. Allowed values: "`everyone`" (default) or "`none`".
#' @param assignment_group_id integer. The assignment group ID to put the assignment in. Defaults to the top assignment group in the course. Only valid if `quiz_type` is "`assignment`" or "`graded_survey`".
#' @inheritParams quiz_questions
#'
#' @return The quiz id.
#'
#' @export
create_quiz <- function(
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
) {
  quiz_type <- match.arg(quiz_type)
  one_question_at_a_time <- match.arg(one_question_at_a_time)
  visible <- match.arg(visible)

  opts_list <- list(
    title = title,
    description = description,
    quiz_type = quiz_type,
    one_question_at_a_time = !("no" %in% one_question_at_a_time),
    cant_go_back = "yes_but_cant_go_back" %in% one_question_at_a_time,
    only_visible_to_overrides = visible == "none",
    assignment_group_id = assignment_group_id,
    published = publish
  )
  opts_list <- c(opts_list, attempts)
  resp <- quizzes_url(course_id, url, token) |>
    httr2::req_body_json(list(quiz = opts_list)) |>
    httr2::req_perform()

  quiz_id <- resp |>
    httr2::resp_body_json() |>
    pluck("id")

  set_last_quiz_id(quiz_id)

  cli::cli_alert_success(
    "Quiz '{.val {title}}' is created with ID {.val {quiz_id}}."
  )
  return(quiz_id)
}

#' A quiz attempt options
#'
#' @param n The number of allowed attempts. Set to `-1` or `Inf` for unlimited. Defaults to `1`.
#' @param time Time limit for each attempt in minutes. Set to `NULL` for no limit (default).
#' @param due POSIXct. Due date and time for the quiz.
#' @param lock POSIXct. Lock date and time for the quiz.
#' @param unlock POSIXct. Unlock date and time for the quiz.
#' @param results A list of options controlling when quiz results are visible to students. See [opt_show()] and [opt_hide()].
#' @param answer A list of options controlling when correct answers are visible to students. See [opt_show()], [opt_hide()] and [opt_shuffle()].
#' @param score Scoring policy for multiple attempts. Allowed values: "`highest`" (default), "`latest`".
#' @param access_code Password required to access the quiz. Set to `NULL` for no restriction (default).
#' @param ip_filter Restrict access to computers in a specified IP range. Filters can be a comma-separated list of addresses, or address/mask. Examples: `"192.168.1.1,192.168.1.2"` or `"192.168.1.0/24"`. Set to `NULL` for no restriction (default).
#' @return A list of options to be passed to [create_quiz()].
#' @export
attempt_options <- function(
  n = 1,
  time = NULL,
  due = NULL,
  lock = NULL,
  unlock = NULL,
  results = opt_show(at = due),
  answer = opt_show(at = due),
  score = c("highest", "latest"),
  access_code = NULL,
  ip_filter = NULL
) {
  n <- ifelse(is.infinite(n), -1, n)
  cli_abort_if_not(
    "{.arg n} should be a single numeric value" = (length(n) == 1 &&
      is.numeric(n) &&
      (n == -1 || n > 0)),
    "{.arg time} should be a single numeric value or NULL" = (length(time) ==
      1 &&
      is.numeric(time)) ||
      is.null(time)
  )
  score <- match.arg(score)

  scoring_policy <- paste0("keep_", score)
  opts <- list(
    allowed_attempts = n,
    time_limit = time,
    hide_results = NULL,
    due_at = due,
    lock_at = lock,
    unlock_at = unlock,
    scoring_policy = scoring_policy,
    access_code = access_code,
    ip_filter = ip_filter
  )
  if (is.list(results)) {
    if (results$show_last_attempt %||% FALSE) {
      opts$hide_results <- "until_after_last_attempt"
    }
    opts$one_time_results <- results$show_one_time %||% FALSE
    if (results$show_at %||% FALSE) {
      opts$show_correct_answers_at <- results$show_at
    }
    if (results$hide_at %||% FALSE) {
      opts$hide_correct_answers_at <- results$hide_at
    }
    if (results$hide %||% FALSE) opts$hide_results <- "always"
  } else {
    cli::cli_abort(
      "{.arg results} should be a list of options created by {.fn opt_show()} or {.fn opt_hide()}"
    )
  }
  if (is.list(answer)) {
    opts$show_correct_answers <- answer$show %||% !answer$hide %||% FALSE
    opts$show_correct_answers_last_attempt <- answer$show_last_attempt %||%
      FALSE
    opts$show_correct_answers_at <- answer$show_at
    opts$hide_correct_answers_at <- answer$hide_at
    opts$shuffle_answers <- answer$shuffle %||% FALSE
  } else {
    cli::cli_abort(
      "{.arg answer} should be a list of options created by opt_show() or opt_hide()"
    )
  }
  if (
    !is.null(opts$hide_results) &&
      opts$hide_results == "always" &
      (opts$show_correct_answers | opts$show_correct_answers_last_attempt)
  ) {
    cli::cli_alert_warning(
      "Cannot show correct answers if results are always hidden."
    )
  }
  return(opts)
}

#' Options for showing quiz results or answers
#'
#' @param last_attempt logical. Whether to show results/answers only after the last attempt is submitted. Only valid if the number of attempts is greater than 1. Defaults to `FALSE`.
#' @param one_time logical. Whether to show results/answers only immediately after submission.
#' @param at POSIXct. Date and time to control when results/answers become visible or hidden. If `show = TRUE`, results/answers become visible at this date and time. If `hide = TRUE`, results/answers become hidden at this date/time.
#' @return A list of options to be passed to the `results` or `answer` parameters of [attempt_options()].
#' @name attempt-options
#' @export
opt_show <- function(last_attempt = FALSE, one_time = FALSE, at = NULL) {
  list(
    show = TRUE,
    show_last_attempt = last_attempt,
    show_one_time = one_time,
    show_at = at
  )
}

#' @rdname attempt-options
#' @export
opt_hide <- function(at = NULL) {
  list(hide = TRUE, hide_at = at)
}
#' @rdname attempt-options
#' @export
opt_shuffle <- function() {
  list(shuffle_answers = TRUE)
}

#' Get quiz questions
#'
#' @param quiz_id The id of the quiz to retrieve questions from.
#' @param course_id The course id. Defaults to the value of the `CANVASQUIZ_COURSE_ID` environment variable.
#' @param url The canvas url. Defaults to the value of the `CANVASQUIZ_URL` environment variable.
#' @param token The canvas token. Defaults to the value of the `CANVASQUIZ_TOKEN` environment variable.
#' @return A list of quiz questions.
#' @export
quiz_questions <- function(
  quiz_id,
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN")
) {
  quizzes_url(course_id, url, token) |>
    httr2::req_url_path_append(paste0(quiz_id, "/questions")) |>
    httr2::req_perform() |>
    httr2::resp_body_json()
}

#' Delete a quiz question
#'
#' @inheritParams quiz_questions
#' @param question_id The id of the question to delete.
#' @export
delete_quiz_question <- function(
  quiz_id,
  question_id,
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN")
) {
  quizzes_url(course_id, url, token) |>
    httr2::req_url_path_append(paste0(quiz_id, "/questions/", question_id)) |>
    httr2::req_method("DELETE") |>
    httr2::req_perform()

  cli::cli_alert_success("Question ID {.val {question_id}} is deleted.")
}

#' Delete a quiz
#'
#' @inheritParams quiz_questions
#' @export
delete_quiz <- function(
  quiz_id,
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN")
) {
  for (qiz in quiz_id) {
    quizzes_url(course_id, url, token) |>
      httr2::req_url_path_append(qiz) |>
      httr2::req_method("DELETE") |>
      httr2::req_perform()

    cli::cli_alert_success("Quiz ID {.val {qiz}} is deleted.")
  }
}


# list_question_banks <- function(
#   context_type = c("Course", "Account"),
#   course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
#   url = Sys.getenv("CANVASQUIZ_URL"),
#   token = Sys.getenv("CANVASQUIZ_TOKEN")
# ) {
#   context_type <- match.arg(context_type)
#   course_url(course_id, url, token) |>
#     httr2::req_url_path_append("question_banks") |>
#     httr2::req_body_json(list(
#       context_type = context_type,
#       context_id = course_id,
#       include_question_count = TRUE
#     )) |>
#     httr2::req_perform() |>
#     httr2::resp_body_json() |>
#     dplyr::bind_rows()
# }

#' List quizzes in a course
#'
#' @inheritParams quiz_questions
#' @return A data frame of quizzes with their details.
#' @export
list_quizzes <- function(
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN")
) {
  quizzes <- quizzes_url(course_id, url, token) |>
    httr2::req_perform() |>
    httr2::resp_body_json()
  lapply(quizzes, function(quiz) {
    quiz$permissions <- list(quiz$permissions)
    quiz$lock_info <- list(quiz$lock_info)
    quiz
  }) |>
    dplyr::bind_rows()
}


#' Delete all quizzes
#' 
#' Use with caution! This function will delete all quizzes in the course after asking for confirmation. It will not delete quiz question banks.
#' 
#' @inheritParams quiz_questions
#'
#' @export
delete_all_quizzes <- function(
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN")
) {
  if (
    utils::askYesNo(
      "Are you sure you want to delete all quizzes in this course?",
      default = FALSE
    )
  ) {
    quizzes <- list_quizzes(course_id, url, token)
    if (nrow(quizzes) == 0) {
      cli::cli_alert_info("No quizzes found in the course.")
      return(invisible())
    }
    delete_quiz(quizzes$id, course_id, url, token)
  } else {
    cli::cli_alert_info("Operation cancelled. No quizzes were deleted.")
  }
}


quiz_info <- function(quiz_id, 
                      course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"), 
                      url = Sys.getenv("CANVASQUIZ_URL"), 
                      token = Sys.getenv("CANVASQUIZ_TOKEN")) {
  quizzes_url(course_id, url, token) |>
    httr2::req_url_path_append(quiz_id) |>
    httr2::req_perform() |>
    httr2::resp_body_json()
}