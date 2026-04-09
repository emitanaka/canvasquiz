
#' Get quiz submission details
#' 
#' @param submission_id The ID of the quiz submission to retrieve details for.
#' @inheritParams quiz_questions
#' @family submissions
#' @return A data frame with submission id, quiz id, question name, question type, question text, whether the question was flagged, whether the question was correct, assessment question id, quiz group id, and the answers provided.
#' @export
submission_info <- function(submission_id, 
                            course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"), 
                            url = Sys.getenv("CANVASQUIZ_URL"), 
                            token = Sys.getenv("CANVASQUIZ_TOKEN")) {
  canvas_url(url, token) |>
    httr2::req_url_path_append(paste0("quiz_submissions/", submission_id, "/questions")) |>
    httr2::req_perform() |> 
    httr2::resp_body_json() |> 
    pluck(1) |> 
    lapply(function(x) {
      x$correct <- as.character(x$correct)
      if("answers" %in% names(x)) {
        x$answers <- list(x$answers)
      }
      if(!"quiz_group_id" %in% names(x)) {
        x$quiz_group_id <- NA
      }
      x
    }) |> 
    dplyr::bind_rows() |> 
    dplyr::arrange(position) |> 
    dplyr::summarise(
      answers = list(answers),
      # quiz_group_id omitted -- seems like it doesn't exist when no quiz group
      .by = c(id, quiz_id, position, question_name, question_type, question_text, flagged, correct, assessment_question_id)
    )
}

#' Get quiz submission overview
#' 
#' @inheritParams submission_info
#' @family submissions
#' @return A data frame with the name of the user, quiz title, score, attempt number, quiz id, and submission id.
#' @export
submission_overview <- function(submission_id, 
                                course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"), 
                                url = Sys.getenv("CANVASQUIZ_URL"), 
                                 token = Sys.getenv("CANVASQUIZ_TOKEN")) {
  quiz_id <- submission_info(submission_id, course_id, url, token) |>
    pluck("quiz_id") |> 
    pluck(1)
  res <- quizzes_url(course_id, url, token) |> 
        httr2::req_url_path_append(paste0(quiz_id, "/submissions/", submission_id)) |>
        httr2::req_body_json(list(include = c("user", "quiz", "submission"))) |> 
        httr2::req_method("GET") |> 
        httr2::req_perform() |> 
        httr2::resp_body_json() 
  tibble::tibble(
    name = res$users[[1]]$name,
    quiz = res$quizzes[[1]]$title,
    score = res$submissions[[1]]$score,
    attempt = res$submissions[[1]]$attempt,
    quiz_id = quiz_id,
    submission_id = submission_id
  )
}


#' List quiz submissions
#' 
#' @inheritParams quiz_results
#' @family submissions
#' @export
list_submissions <- function(quiz_id, 
                             course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"), 
                             url = Sys.getenv("CANVASQUIZ_URL"), 
                             token = Sys.getenv("CANVASQUIZ_TOKEN"),
                             n = count_submissions(quiz_id, course_id, url, token),
                             tz = Sys.timezone()) {
  get_submissions_page <- function(page) {
    quizzes_url(course_id) |>
      httr2::req_url_path_append(paste0(quiz_id, "/submissions")) |>
      httr2::req_url_query(per_page = 100, page = page) |>
      httr2::req_perform() |>
      httr2::resp_body_json() |> 
      dplyr::bind_rows()
  }
  resp <- resp1 <- get_submissions_page(ipage <- 1)
  if(nrow(resp) == 0) {
    cli::cli_abort("No submissions found for quiz {.val {quiz_id}}.")
  }
  while (nrow(resp1) == 100 & nrow(resp) < n) {
    resp1 <- get_submissions_page(ipage <- ipage + 1)
    resp <- dplyr::bind_rows(resp, resp1)
  }
  if(!"end_at" %in% colnames(resp)) resp$end_at <- NA
  if(!"finished_at" %in% colnames(resp)) resp$finished_at <- NA
  if(!"started_at" %in% colnames(resp)) resp$started_at <- NA
  out <- resp |> 
    dplyr::mutate(across(c(started_at, finished_at, end_at), \(x) as.POSIXct(x, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")))
  attr(out$started_at, "tzone") <- tz
  attr(out$finished_at, "tzone") <- tz
  attr(out$end_at, "tzone") <- tz
  out
}

#' List attempted questions for a quiz
#' 
#' @inheritParams submission_info
#' @family submissions
#' @export
submission_questions <- function(submission_id, 
                                 url = Sys.getenv("CANVASQUIZ_URL"), 
                                 token = Sys.getenv("CANVASQUIZ_TOKEN")) {
  stopifnot(length(submission_id) == 1)
  res <- canvas_url(url, token) |>
    httr2::req_url_path_append(paste0("quiz_submissions/", submission_id, "/questions")) |>
    httr2::req_perform() |> 
    httr2::resp_body_json() |> 
    pluck(1)
  tibble::tibble(
    question_id = vapply(res, function(x) x$id, numeric(1)),
    quiz_id = vapply(res, function(x) x$quiz_id, numeric(1)),
    position = vapply(res, function(x) x$position, numeric(1)),
    question_name = vapply(res, function(x) x$question_name, character(1)),
    question_type = vapply(res, function(x) x$question_type, character(1)),
    question_text = vapply(res, function(x) x$question_text, character(1))
  ) |> 
    dplyr::arrange(position) |> 
    dplyr::mutate(submission_id = submission_id)
}



#' Update a quiz submission
#' 
#' @inheritParams submission_info
#' 
#' @export
submission_update <- function(submission_id, 
                              fudge_points = NULL,
                              question_id = NULL,
                              score = NULL,
                              comment = NULL,
                              course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"), 
                              url = Sys.getenv("CANVASQUIZ_URL"), 
                              token = Sys.getenv("CANVASQUIZ_TOKEN")) {
  stopifnot(length(submission_id) == 1,
            is.null(fudge_points) || length(fudge_points) == 1,
            is.null(question_id) || length(question_id) == 1,
            is.null(score) || length(score) == 1,
            is.null(comment) || length(comment) == 1)
  
  details <- submission_overview(submission_id, course_id, url, token)
  stopifnot(length(details) > 0)
  quiz_id <- details$quiz_id
  if(is.null(question_id)) {
    update_list <- list()
  } else {
    update_list <- setNames(list(list(score = score, comment = comment)), question_id)
  }
  
  quizzes_url(course_id, url, token) |>
    httr2::req_url_path_append(paste0(quiz_id, "/submissions/", submission_id)) |>
    httr2::req_body_json(list(quiz_submissions = list(list(attempt = details$attempt, 
                                                           fudge_points = fudge_points, 
                                                           questions = update_list)))) |> 
    httr2::req_method("PUT") |> 
    httr2::req_perform() |>  
    httr2::resp_body_json() 

  cli::cli_inform("Updated submission {.val {submission_id}} for {.val {details$name}} on quiz {.val {details$quiz}} (attempt {.val {details$attempt}}, score before regrade: {.val {details$score}}).")
}
