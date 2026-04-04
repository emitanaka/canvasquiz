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
      cli::cli_abort(
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

#' Answer for a multiple choice question
#'
#' @param choices Character vector of answer choices.
#' @param correct Character vector of correct answer(s). Should be one element for single-answer multiple choice questions and can be multiple elements for multiple-answer multiple choice questions.
#' @param multiple Logical. Whether the question allows multiple correct answers. Defaults to `TRUE` if `correct` has more than one element.
#'
#' @family answer-functions
#' @export
answer_mcq <- function(choices, correct, multiple = length(correct) > 1) {
  if (length(correct) == 1 & !multiple) {
    structure(
      lapply(choices, function(text) {
        weight <- ifelse(text == correct, 100, 0)
        list(answer_text = text, answer_weight = weight)
      }),
      type = "multiple_choice_question"
    )
  } else {
    structure(
      lapply(choices, function(text) {
        weight <- ifelse(text %in% correct, 100, 0)
        list(answer_text = text, answer_weight = weight)
      }),
      type = "multiple_answers_question"
    )
  }
}

#' True or False Question
#'
#' @param correct Logical. Whether the correct answer is `TRUE` or `FALSE`.
#' @family answer-functions
#' @export
answer_true_false <- function(correct = TRUE) {
  choices <- c("True", "False")
  correct <- ifelse(correct, "True", "False")
  res <- answer_mcq(choices, correct)
  attr(res, "type") <- "true_false_question"
  res
}

#' Multiple answer question
#'
#' This function allows you to create a question with multiple parts, such as multiple dropdowns or fill-in-the-blank questions with multiple blanks. Each part is created with a separate answer object (e.g. created by `dropdown()` or `fill_in_the_blank()`) and then combined into a single question with this function.
#'
#' The question text should include square-bracketed text corresponding to the `id` of each answer part to indicate where in the question text each part should be displayed. For example, if you have two dropdown answer parts with ids "blank1" and "blank2", your question text might look like "The capital of France is \code{[blank1]} and the capital of Spain is \code{[blank2]}."
#'
#' All answer parts must be of the same type (e.g. all dropdowns or all fill-in-the-blank). The function will throw an error if you try to combine different types of answer parts or if the question text includes blank ids that do not correspond to any answer part ids.
#'
#' For fill-in-the-blank questions, the answer may be marked incorrect even if it is technically correct. This seems to be the result of encoding. If you manually edit and resave the questions, this seems to fix the issue.
#'
#' @param ... Multiple dropdown answer objects created by [dropdown()] or [fill_in_the_blank()]..
#' @family answer-functions
#' @export
answer_multiple <- function(...) {
  dots <- c(...)
  cls <- unique(vapply(dots, function(dot) dot$class, character(1)))
  if (length(cls) != 1) {
    cli::cli_abort("All answers must be of the same type.")
  }
  if (cls == "dropdown") {
    structure(dots, type = "multiple_dropdowns_question")
  } else if (cls == "fitb") {
    structure(dots, type = "fill_in_multiple_blanks_question")
  } else {
    cli::cli_abort(
      "Multiple answers questions must be created with dropdown() or fill_in_the_blank() answer objects."
    )
  }
}

#' Create a dropdown answer for a fill-in-multiple-blanks question
#' @inheritParams answer_mcq
#' @param blank_id The ID of the blank this dropdown corresponds to.
#' @export
dropdown <- function(choices, correct, id = NULL) {
  lapply(choices, function(text) {
    weight <- ifelse(text == correct, 100, 0)
    list(
      answer_text = text,
      answer_weight = weight,
      blank_id = id,
      class = "dropdown"
    )
  })
}

#' Create a fill-in-the-blank answer for a fill-in-multiple-blanks question
#' @param text The correct answer text for this blank.
#' @param id The ID of the blank this answer corresponds to.
#' @export
fill_in_the_blank <- function(text, id = NULL) {
  list(list(answer_text = text, blank_id = id, class = "fitb"))
}

#' A short answer question
#' @param text The correct answer text.
#' @family answer-functions
#' @export
answer_text <- function(text) {
  structure(list(list(answer_text = text)), type = "short_answer_question")
}

#' A numerical answer question with an exact answer
#' @param value The correct numerical answer.
#' @param tol The acceptable error margin for the answer. Defaults to 0 for an exact answer.
#' @param precision The number of decimal places the answer must be correct to.
#' @param lower The lower bound of the acceptable answer range.
#' @param upper The upper bound of the acceptable answer range.
#' @family answer-functions
#' @export
answer_num <- function(value, tol = 0) {
  structure(
    list(list(
      numerical_answer_type = "exact_answer",
      answer_exact = value,
      answer_error_margin = tol
    )),
    type = "numerical_question"
  )
}


#' @rdname answer_num
#' @export
answer_num_precision <- function(value, precision = 0L) {
  structure(
    list(list(
      numerical_answer_type = "precision_answer",
      answer_approximate = value,
      answer_precision = precision
    )),
    type = "numerical_question"
  )
}

#' @rdname answer_num
#' @export
answer_num_range <- function(lower, upper) {
  structure(
    list(list(
      numerical_answer_type = "range_answer",
      answer_range_start = lower,
      answer_range_end = upper
    )),
    type = "numerical_question"
  )
}

#' Answer for a matching question
#' @param left Character vector of the left-hand side items to be matched.
#' @param right Character vector of the right-hand side items to be matched. Must be the same length as `left`.
#' @param extra_choices Character vector of extra choices that can be used as incorrect matches. Optional.
#' @family answer-functions
#' @export
answer_matching <- function(left, right, extra_choices = "") {
  ll <- lapply(1:length(left), function(i) {
    list(
      answer_match_left = left[i],
      answer_match_right = right[i]
    )
  })
  structure(
    ll,
    answer = list(left = left, right = right, extra_choices = extra_choices),
    type = "matching_question"
  )
}

#' Answer for an essay question
#'
#' @family answer-functions
#' @export
answer_essay <- function() {
  structure(list(), type = "essay_question")
}

#' A file upload question
#'
#' @family answer-functions
#' @export
answer_upload_file <- function() {
  structure(list(), type = "file_upload_question")
}

#' A text-only question with no answers
#'
#' @family answer-functions
#' @export
answer_none <- function() {
  structure(list(), type = "text_only_question")
}

#' Answer for a fill-in-multiple-blanks question
#'
#' @export
answer_fill_in_multiple_blanks <- function(answers, blank_ids) {
  if (length(answers) != length(blank_ids)) {
    cli::cli_abort("Length of answers and blank_ids must be the same.")
  }
  structure(
    lapply(1:length(answers), function(i) {
      list(answer_text = answers[i], blank_id = blank_ids[i])
    }),
    answer = list(answers = answers, blank_ids = blank_ids),
    type = "fill_in_multiple_blanks_question"
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
