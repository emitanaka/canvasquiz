#' Create a Quiz Question
#'
#' This function creates a quiz question directly into Canvas. You can create a variety of question types, including multiple choice, short answer, numerical answer, matching, essay, file upload, and text-only questions.
#'
#' The question comments is correctly entered, however, Canvas doesn't seem to display them initially. Manually editing the quiz and saving it again seems to fix the issue and then the comments are displayed as expected.
#'
#' @param text Character. The text of the question.
#' @param answers A list of answer objects.
#' @param points The maximum amount of points received for answering this question correctly.
#' @param position An integer specifying the order in which the question will be displayed in the quiz. Doesn't seem to work.
#' @param quiz_id The id of the quiz to add the question to.
#' @param title The name of the question.
#' @param correct_comments Comment to display if the student answers the question correctly.
#' @param incorrect_comments Comment to display if the student answers incorrectly.
#' @param neutral_comments Comment to display regardless of how the student answered.
#' @inheritParams quiz_questions
#'
#' @return A list representing the quiz question.
#' @export
create_question <- function(
  text = NULL,
  answers = NULL,
  points = 1,
  quiz_id = last_quiz_id(),
  #quiz_group_id = NULL,
  position = NULL,
  title = NULL,
  correct_comments = NULL,
  incorrect_comments = NULL,
  neutral_comments = NULL,
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN")
) {
  if (attr(answers, "type") == "matching_question") {
    matching_incorrect_options <- paste0(
      attr(answers, "answer")$extra_choices,
      collapse = "\n"
    )
  } else {
    matching_incorrect_options <- NULL
  }
  if (
    attr(answers, "type") %in%
      c("multiple_dropdowns_question", "fill_in_multiple_blanks_question")
  ) {
    answer_blank_ids <- unique(vapply(
      answers,
      function(.x) .x$blank_id,
      character(1)
    ))
    text_blank_ids <- regmatches(text, m = gregexpr("\\[.*?\\]", text))[[1]]
    text_blank_ids <- gsub("\\[|\\]", "", text_blank_ids)
    if (!all(text_blank_ids %in% answer_blank_ids)) {
      cli::cli_alert_danger(
        "All blank ids in answers must be present in the question text as square bracketed text, e.g. `[blank1]` for blank id `blank1`. The following blank ids in the quesiton text do not have corresponding blank ids in the answers: {.val {setdiff(text_blank_ids, answer_blank_ids)}}."
      )
    }
  }
  q <- quizzes_url(course_id, url, token) |>
    httr2::req_url_path_append(paste0(quiz_id, "/questions")) |>
    httr2::req_body_json(list(
      question = list(
        question_name = title,
        question_text = text,
        #quiz_group_id = quiz_group_id,
        question_type = attr(answers, "type"),
        position = position,
        points_possible = points,
        correct_comments = correct_comments,
        incorrect_comments = incorrect_comments,
        neutral_comments = neutral_comments,
        answers = answers,
        matching_answer_incorrect_matches = matching_incorrect_options
      )
    )) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  set_last_question_id(q$id)

  if (is.null(title)) {
    cli::cli_alert_info("Question added to quiz ID {.val {quiz_id}}.")
  } else {
    cli::cli_alert_info(
      "Question {.val {title}} added to quiz ID {.val {quiz_id}}."
    )
  }
  cli::cat_boxx(
    text,
    header = "Question",
    padding = 0,
    background_col = "red",
    col = "white"
  )
  cli::cli_text(cli::col_white(cli::bg_br_blue("Answer ({points} point{?s}):")))
  switch(
    attr(answers, "type"),
    multiple_choice_question = {
      for (i in seq_along(answers)) {
        ans <- answers[[i]]
        if (ans$answer_weight == 100) {
          cli::cat_bullet(
            ans$answer_text,
            bullet_col = "green",
            bullet = "tick"
          )
        } else {
          cli::cat_bullet(ans$answer_text, bullet_col = "red", bullet = "cross")
        }
      }
    },
    short_answer_question = {
      cli::cat_bullet(answers[[1]]$answer_text)
    },
    numerical_question = {
      type <- answers[[1]]$numerical_answer_type
      if (type == "exact_answer") {
        cli::cat_bullet(paste0(
          answers[[1]]$answer_exact,
          " ± ",
          answers[[1]]$answer_error_margin
        ))
      } else if (type == "precision_answer") {
        cli::cat_bullet(paste0(
          answers[[1]]$answer_approximate,
          " with precision ",
          answers[[1]]$answer_precision
        ))
      } else if (type == "range_answer") {
        cli::cat_bullet(paste0(
          answers[[1]]$answer_range_start,
          " to ",
          answers[[1]]$answer_range_end
        ))
      }
    },
    matching_question = {
      left <- attr(answers, "answer")$left
      right <- attr(answers, "answer")$right
      extra_choices <- attr(answers, "answer")$extra_choices
      for (i in seq_along(left)) {
        cli::cat_bullet(paste0(left[i], " → ", right[i]))
      }
      if (length(extra_choices) > 0) {
        cli::cli_alert_info(
          "Extra choices: {paste(extra_choices, collapse = ', ')}"
        )
      }
    }
  )
}


#' Update a quiz question
#'
#' @inheritParams create_question
#' @export
update_question <- function(
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
) {
  q <- quizzes_url(course_id, url, token) |>
    httr2::req_url_path_append(paste0(quiz_id, "/questions/", question_id)) |>
    httr2::req_body_json(list(
      quiz_id = quiz_id,
      id = question_id,
      question = list(
        question_name = title,
        question_text = text,
        question_type = attr(answers, "type"),
        position = position,
        points_possible = points,
        correct_comments = correct_comments,
        incorrect_comments = incorrect_comments,
        neutral_comments = neutral_comments,
        answers = answers
      )
    )) |>
    httr2::req_method("PUT") |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  if (is.null(title)) {
    cli::cli_alert_info("Question ID {.val {question_id}} is updated.")
  } else {
    cli::cli_alert_info(
      "Question {.val {title}} (ID {.val {question_id}}) is updated."
    )
  }
}
