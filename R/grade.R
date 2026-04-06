
#' Get quiz submission details
#' 
#' @param submission_id The ID of the quiz submission to retrieve details for.
#' @inheritParams quiz_questions
#' @export
submission_info <- function(submission_id, 
                            course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"), 
                            url = Sys.getenv("CANVASQUIZ_URL"), 
                            token = Sys.getenv("CANVASQUIZ_TOKEN")) {
  canvas_url(url, token) |>
    httr2::req_url_path_append(paste0("quiz_submissions/", submission_id, "/questions")) |>
    httr2::req_perform() |> 
    httr2::resp_body_json() |> 
    pluck(1)
}


## This works but not sure if we want this 
# submission <- function(submission_id, 
#                        quiz_id = NULL,
#                        course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"), 
#                        url = Sys.getenv("CANVASQUIZ_URL"), 
#                        token = Sys.getenv("CANVASQUIZ_TOKEN")) {
#   if(is.null(quiz_id)) {
#     out <- lapply(submission_id, function(id) {
#       res <- canvas_url(url, token) |>
#         httr2::req_url_path_append(paste0("quiz_submissions/", id, "/questions")) |>
#         httr2::req_perform() |> 
#         httr2::resp_body_json() 
#       quiz_id <- res[[1]][[1]]$quiz_id
#       submission(id, quiz_id, course_id, url, token)
#     })
#     dplyr::bind_rows(out)
#   } else {
#     res <- quizzes_url(course_id) |> 
#       httr2::req_url_path_append(paste0(quiz_id, "/submissions/", submission_id)) |>
#       httr2::req_body_json(list(include = c("user", "quiz", "submission"))) |> 
#       httr2::req_method("GET") |> 
#       httr2::req_perform() |> 
#       httr2::resp_body_json() 
#     res$submissions[[1]]$score

#     data.frame(id = submission_id,
#                name = vapply(res$users, function(x) x$name, character(1)),
#                quiz = vapply(res$quizzes, function(x) x$title, character(1)),
#                score = vapply(res$submissions, function(x) x$score, numeric(1)),
#                attempt = vapply(res$submissions, function(x) x$attempt, numeric(1)))
#   }
# }


#' List quiz submissions
#' 
#' @inheritParams quiz_results
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
  while (nrow(resp1) == 100 & nrow(resp) < n) {
    resp1 <- get_submissions_page(ipage <- ipage + 1)
    resp <- dplyr::bind_rows(resp, resp1)
  }
  out <- resp |> 
    dplyr::mutate(across(c(started_at, finished_at, end_at), \(x) as.POSIXct(x, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")))
  attr(out$started_at, "tzone") <- tz
  attr(out$finished_at, "tzone") <- tz
  attr(out$end_at, "tzone") <- tz
  out
}

list_attempted_questions <- function(quiz_id, 
                                     course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"), 
                                     url = Sys.getenv("CANVASQUIZ_URL"), 
                                     token = Sys.getenv("CANVASQUIZ_TOKEN")) {
  submissions <- list_submissions(quiz_id, course_id, url, token)
  lapply(submissions$id, function(id) {
    submission_questions(submission_id = id, course_id, url, token)
  }) |>
    dplyr::bind_rows() |> 
    dplyr::count(question_id, quiz_id, position, question_name, question_type, question_text) |> 
    dplyr::arrange(position)
  
}

submission_questions <- function(submission_id, 
                                 url = Sys.getenv("CANVASQUIZ_URL"), 
                                 token = Sys.getenv("CANVASQUIZ_TOKEN")) {
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
    dplyr::arrange(position)
}

# question_info(question_id, quiz_id, course_id, url, token)


submission_info2 <- function(submission_id, 
                             course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"), 
                             url = Sys.getenv("CANVASQUIZ_URL"), 
                             token = Sys.getenv("CANVASQUIZ_TOKEN")) {
  quiz_id <- submission_info(submission_id, course_id, url, token) |>
    pluck(1) |> 
    pluck("quiz_id")
  res <- quizzes_url(course_id, url, token) |> 
        httr2::req_url_path_append(paste0(quiz_id, "/submissions/", submission_id)) |>
        httr2::req_body_json(list(include = c("user", "quiz", "submission"))) |> 
        httr2::req_method("GET") |> 
        httr2::req_perform() |> 
        httr2::resp_body_json() 
  name <- res$users[[1]]$name
  quiz <- res$quizzes[[1]]$title
  score <- res$submissions[[1]]$score
  attempt <- res$submissions[[1]]$attempt
  list(
    name = name,
    quiz = quiz,
    score = score,
    attempt = attempt,
    quiz_id = quiz_id
  )
}


submission_update <- function(submission_id, 
                              fudge_points = NULL,
                              question_id = NULL,
                              score = NULL,
                              comment = NULL,
                              course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"), 
                              url = Sys.getenv("CANVASQUIZ_URL"), 
                              token = Sys.getenv("CANVASQUIZ_TOKEN")) {
  
  details <- submission_info2(submission_id, course_id, url, token)
  stopifnot(length(details) > 0)
  quiz_id <- details$quiz_id
  update_list <- setNames(list(list(score = score, comment = comment)), question_id)
  cli::cli_inform("Updating submission {.val {submission_id}} for {.val {details$name}} on quiz {.val {details$quiz}} (attempt {.val {details$attempt}}, current score: {.val {details$score}}).")
  
  quizzes_url(course_id, url, token) |>
    httr2::req_url_path_append(paste0(quiz_id, "/submissions/", submission_id)) |>
    httr2::req_body_json(list(quiz_submissions = list(list(attempt = details$attempt, 
                                                           fudge_points = fudge_points, 
                                                           questions = update_list)))) |> 
    httr2::req_method("PUT") |> 
    #httr2::req_dry_run()
    httr2::req_perform() |> 
    httr2::resp_body_json() 
}
