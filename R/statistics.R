#' Get quiz statistics
#' @param quiz_id The ID of the quiz to retrieve statistics for.
#' @inheritParams quiz_questions
#' @export
quiz_statistics <- function(
  quiz_id,
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN")
) {
  res <- quizzes_url(course_id, url, token) |>
    httr2::req_url_path_append(paste0(quiz_id, "/statistics")) |>
    httr2::req_perform() |>
    httr2::resp_body_json() |>
    pluck("quiz_statistics") |>
    pluck(1) |>
    pluck("submission_statistics")

  scores <- data.frame(
    score = as.numeric(names(res$scores)),
    n = vapply(res$scores, as.numeric, numeric(1))
  )
  scores <- scores[order(scores$score), ]
  scores_summary <- data.frame(
    score_mean = res$score_average %||% NA_real_,
    score_sd = res$score_stdev %||% NA_real_,
    score_min = res$score_low %||% NA_real_,
    score_max = res$score_high %||% NA_real_,
    correct_count_mean = res$correct_count_average,
    incorrect_count_mean = res$incorrect_count_average,
    duration_mean = res$duration_average,
    n = res$unique_count
  )
  list(scores = scores, summary = scores_summary)
}

#' Count the number of quiz submissions
#' @param quiz_id The ID of the quiz to count submissions for.
#' @inheritParams quiz_questions
#' @export
count_submissions <- function(
  quiz_id,
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN")
) {
  quiz_statistics(quiz_id, course_id, url, token)$summary$n
}

#' Get quiz submissions with question-level answers
#' @param n The maximum number of quiz submissions to retrieve.
#' @inheritParams quiz_statistics
#' @export
quiz_submissions <- function(
  quiz_id,
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN"),
  n = count_submissions(quiz_id, course_id, url, token)
) {
  if(n == 0) {
    cli::cli_alert_warning("No submissions found for quiz {quiz_id}. Returning empty data frame.")
    return(data.frame())
  }
  ## Get the answer for each question
  ass_id <- quizzes_url(course_id) |>
    httr2::req_url_path_append(quiz_id) |>
    httr2::req_perform() |>
    httr2::resp_body_json() |>
    pluck("assignment_id")

  get_page_answers <- function(page) {
    submissions <- course_url(course_id) |>
      httr2::req_url_path_append(paste0(
        "assignments/",
        ass_id,
        "/submissions"
      )) |>
      httr2::req_body_json(list(include = "submission_history")) |>
      httr2::req_url_query(per_page = 100, page = page) |>
      httr2::req_method("GET") |>
      httr2::req_perform() |>
      httr2::resp_body_json()
  }
  ans <- ans1 <- get_page_answers(ipage <- 1)
  while (length(ans1) == 100 & length(ans) < n) {
    ans1 <- get_page_answers(ipage <- ipage + 1)
    ans <- c(ans, ans1)
  }
  dplyr::bind_rows(ans) |>
    dplyr::filter(!is.na(attempt)) |>
    #dplyr::filter(workflow_state == "graded") |>
    dplyr::mutate(
      answers = lapply(
        submission_history,
        function(.x) {
          # this removes questions with no correct answer defined
          # may want to fix, so that correct = "defined" for handmarked ones are picked up
          # correct = "undefined" is when no answer
          .x$submission_data[vapply(.x$submission_data, \(a) {
            is.logical(a$correct)
          }, logical(1))] |>
            dplyr::bind_rows() |>
            dplyr::mutate(qnum = 1:dplyr::n())
        }
      )
    ) |>
    dplyr::select(user_id, answers) |>
    tidyr::unnest_longer(answers) |>
    tidyr::unnest_wider(answers)
}

#' Quiz results with user information
#' @inheritParams quiz_submissions
#' @param tz The timezone to use for the started_at and finished_at columns. Defaults to the system timezone.
#' @export
quiz_results <- function(
  quiz_id,
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN"),
  n = count_submissions(quiz_id, course_id, url, token),
  tz = Sys.timezone()
) {
  if(n == 0) {
    cli::cli_alert_warning("No submissions found for quiz {quiz_id}. Returning empty data frame.")
    return(data.frame())
  }
  ## Get user submissions
  get_page <- function(page) {
    quiz_data <- quizzes_url(course_id) |>
      httr2::req_url_path_append(paste0(quiz_id, "/submissions")) |>
      httr2::req_url_query(per_page = 100, page = page) |>
      httr2::req_body_json(list(include = "user")) |>
      httr2::req_method("GET") |>
      httr2::req_perform() |>
      httr2::resp_body_json()

    sub_info <- quiz_data |>
      pluck("quiz_submissions") |>
      dplyr::bind_rows() |>
      dplyr::select(user_id, started_at, finished_at, score, html_url) |>
      dplyr::mutate(
        started_at = as.POSIXct(started_at, tz = "UTC", format = "%Y-%m-%dT%H:%M:%OSZ"),# + hours(11),
        finished_at = as.POSIXct(finished_at, tz = "UTC", format = "%Y-%m-%dT%H:%M:%OSZ"), # + hours(11),
        time_taken = finished_at - started_at
      )
    attr(sub_info$started_at, "tzone") <- tz
    attr(sub_info$finished_at, "tzone") <- tz

    user_info <- quiz_data |>
      pluck("users") |>
      dplyr::bind_rows() |>
      dplyr::select(user_id = id, name, sis_user_id)

    user_info |>
      dplyr::left_join(sub_info, by = "user_id")
  }
  res <- res1 <- get_page(ipage <- 1)
  while (nrow(res1) == 100 & nrow(res) < n) {
    res1 <- get_page(ipage <- ipage + 1)
    res <- dplyr::bind_rows(res, res1)
  }
  res
}

#' Quiz results summary
#' @inheritParams quiz_results
#' @export
quiz_results_summary <- function(
  quiz_id,
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN"),
  n = count_submissions(quiz_id, course_id, url, token),
  tz = Sys.timezone()
) {
  get_page <- function(page) {
    quizzes_url(course_id) |>
      httr2::req_url_path_append(paste0(quiz_id, "/submissions")) |>
      httr2::req_url_query(per_page = 100, page = page) |>
      httr2::req_perform() |>
      httr2::resp_body_json()
  }
  resp <- resp1 <- get_page(ipage <- 1)
  while (
    length(resp1$quiz_submissions) == 100 & length(resp$quiz_submissions) < n
  ) {
    resp1 <- get_page(ipage <- ipage + 1)
    resp$quiz_submissions <- c(resp$quiz_submissions, resp1$quiz_submissions)
  }
  res <- dplyr::bind_rows(resp$quiz_submissions) |>
    dplyr::count(score) |>
    dplyr::mutate(p = n / sum(n))
  cli::cat_boxx(glue::glue("{sum(res$n)} students"))
  res
}
