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
#' @param quiz_group_id The id of the quiz group to add the question to. 
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
  quiz_group_id = NULL,
  position = NULL,
  title = NULL,
  correct_comments = NULL,
  incorrect_comments = NULL,
  neutral_comments = NULL,
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN")
) {
  if (inherits(answers, "matching_question")) {
    matching_incorrect_options <- paste0(
      attr(answers, "answer")$extra_choices,
      collapse = "\n"
    )
  } else {
    matching_incorrect_options <- NULL
  }
  if (
    inherits(answers, c("multiple_dropdowns_question", "fill_in_multiple_blanks_question"))
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
        question_type = class(answers)[1],
        position = position,
        points_possible = points,
        correct_comments = correct_comments,
        incorrect_comments = incorrect_comments,
        neutral_comments = neutral_comments,
        answers = unclass(answers),
        matching_answer_incorrect_matches = matching_incorrect_options
      )
    )) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  set_last_question_id(q$id)

  structure(list(
    question_id = q$id,
    quiz_id = quiz_id,
    text = text,
    answers = answers,
    points = points,
    position = position,
    title = title,
    correct_comments = correct_comments,
    incorrect_comments = incorrect_comments,
    neutral_comments = neutral_comments
  ), class = "canvas_question")
}

#' @export
print.canvas_question <- function(x, ...) {
  if (is.null(x$title)) {
    cli::cli_alert_info("Question added to quiz ID {.val {x$quiz_id}}.")
  } else {
    cli::cli_alert_info(
      "Question {.val {x$title}} added to quiz ID {.val {x$quiz_id}}."
    )
  }

  cli::cat_boxx(
    x$text,
    header = "Question",
    padding = 0#,
    #background_col = "red",
    #col = "white"
  )
  #cli::cli_text(cli::col_white(cli::bg_br_blue("Answer ({x$points} point{?s}):")))
  question_type <- switch(class(x$answers)[1],
    "multiple_choice_question" = "Multiple Choice",
    "multiple_answers_question" = "Multiple Answers",
    "short_answer_question" = "Short Answer",
    "numerical_question" = "Numerical Answer",
    "matching_question" = "Matching",
    "essay_question" = "Essay",
    "file_upload_question" = "File Upload",
    "text_only_question" = "Text Only",
    "true_false_question" = "True/False",
    "multiple_dropdowns_question" = "Multiple Dropdowns",
    "fill_in_multiple_blanks_question" = "Fill in Multiple Blanks",
    "Unknown Question Type"
  )
  cli::cli_text(cli::style_bold(question_type), " ", cli::style_reset("({x$points} point{?s}):"))
  print(x$answers)
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


question_info <- function(question_id, 
                          quiz_id, 
                          course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"), 
                          url = Sys.getenv("CANVASQUIZ_URL"), 
                          token = Sys.getenv("CANVASQUIZ_TOKEN")) {
  quizzes_url(course_id, url, token) |>
    httr2::req_url_path_append(paste0(quiz_id, "/questions/", question_id)) |>
    httr2::req_perform() |>
    httr2::resp_body_json()
}


#' List quiz questions in a course
#'
#' @inheritParams quiz_questions
#' @return A data frame of quiz questions with their details.
#' @export
list_questions <- function(
  quiz_id = NULL,
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN")
) {
  if(is.null(quiz_id)) {
    cli::cli_alert_warning("No quiz ID provided. Returning questions from all quizzes in the course.")
    qids <- list_quizzes(course_id)$id
  } else {
    qids <- quiz_id
  }
  lapply(qids, function(id) {
    quizzes_url(course_id, url, token) |>
      httr2::req_url_path_append(paste0(id, "/questions")) |>
      httr2::req_url_query(per_page = 100, page = 1) |>
      httr2::req_perform() |>
      httr2::resp_body_json() |>
      dplyr::bind_rows()
  }) |>
    dplyr::bind_rows()
}

#' @rdname list_questions
#' @export
list_question_groups <- function(
  quiz_id,
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN")
) {
  quizzes_url(course_id, url, token) |>
    httr2::req_url_path_append(paste0(quiz_id, "/groups")) |>
    httr2::req_perform() |>
    httr2::resp_body_json() |>
    dplyr::bind_rows()
}




#' Add questions from a question bank to a quiz
#'
#' @param quiz_id The id of the quiz to add questions to.
#' @param bank_id The id of the question bank to pull questions from.
#' @param title (Optional) The title of the quiz group to create for these questions. If `NULL` (default), no quiz group will be created and questions will be added to the quiz without a group.
#' @param n The number of questions to randomly select from the question bank. Defaults to `1`.
#' @param points The number of points each question added from the bank should be worth. Defaults to `1`.
#' @param course_id The course id. Defaults to the value of the `CANVASQUIZ_COURSE_ID` environment variable.
#' @param url The canvas url. Defaults to the value of the `CANVASQUIZ_URL` environment variable.
#' @param token The canvas token. Defaults to the value of the `CANVASQUIZ_TOKEN` environment variable.
#' @return The API response from adding the questions.
add_question_from_bank <- function(
  quiz_id,
  bank_id,
  title = NULL,
  n = 1L,
  points = 1L,
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN")
) {
  quizzes_url(course_id, url, token) |>
    httr2::req_url_path_append(paste0(quiz_id, "/groups")) |>
    httr2::req_body_json(list(
      quiz_groups = list(list(
        name = title,
        pick_count = n,
        question_points = points,
        assessment_question_bank_id = bank_id
      ))
    )) |>
    httr2::req_perform()

  cli::cli_inform(
    "Added {n} question{?s} from bank ID {.val bank_id} to quiz ID {.val quiz_id}."
  )
}

