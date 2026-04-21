
#' List attempted questions for a quiz
#' 
#' @inheritParams submission_info
#' @family submissions
#' @export
list_attempted_questions <- function(quiz_id, 
                                     course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"), 
                                     url = Sys.getenv("CANVASQUIZ_URL"), 
                                     token = Sys.getenv("CANVASQUIZ_TOKEN")) {
  submissions <- list_submissions(quiz_id, course_id, url, token)
  lapply(submissions$id, function(id) {
    submission_questions(submission_id = id, url, token)
  }) |>
    dplyr::bind_rows() |> 
    dplyr::summarise(submission_id = list(submission_id),
                     n = dplyr::n(),
                     .by = c(question_id, quiz_id, position, question_name, question_type, question_text)) |> 
    dplyr::arrange(position)
  
}

#' Regrade quiz submissions based on answer
#' 
#' If you leave the answer as NULL, it will not filter the submissions.
#' 
#' @inheritParams submission_update
#' @param question_id The ID of the question to regrade.
#' @param answer The answer to regrade. Can be numeric or character or one of the answer functions. 
#' @export
regrade_question <- function(question_id, 
                             quiz_id, 
                             answer = NULL,
                             fudge_points = NULL,
                             score = NULL,
                             comment = NULL,
                             course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"), 
                             url = Sys.getenv("CANVASQUIZ_URL"), 
                             token = Sys.getenv("CANVASQUIZ_TOKEN")) {
  
  n <- count_submissions(quiz_id, course_id, url, token)
  subs <- quiz_submissions(quiz_id, n = max(c(1, n))) |> 
    dplyr::filter(.data$question_id == .env$question_id)
  if(is.numeric(answer)) {
    subs <- subs |> 
      dplyr::mutate(answer_text = as.numeric(text))
  } else {
    subs <- subs |> 
      dplyr::mutate(answer_text = text)
  }
  if(inherits(answer, "canvas_answer")) {
    if(inherits(answer, "numerical_question")) {
      type <- answer[[1]]$numerical_answer_type
      subs <- subs |> 
        dplyr::mutate(answer_text = as.numeric(text))
      if(type == "exact_answer") {
        ans <- answer[[1]]$answer_exact
        tol <- answer[[1]]$answer_error_margin
        subs <- subs |> 
          dplyr::filter(abs(answer_text - ans) <= tol)
      } else if(type == "precision_answer") {
        ans <- answer[[1]]$answer_approximate
        precision <- answer[[1]]$answer_precision
        subs <- subs |> 
          dplyr::filter(round(answer_text, precision) == round(ans, precision))
      } else if(type == "range_answer") {
        lower <- answer[[1]]$answer_range_start
        upper <- answer[[1]]$answer_range_end
        subs <- subs |> 
          dplyr::filter(answer_text >= lower, answer_text <= upper)
      } else {
        cli::cli_abort("Unknown numerical question type.")
      }
    } else if(inherits(answer, "short_answer_question")) {
      ans <- answer[[1]]$answer_text
      subs <- subs |> 
        dplyr::filter(answer_text == ans)
    } else {
      cli::cli_abort("Regrading based on answer is only supported for numerical and short answer questions.")
    }
  } else if(!is.null(answer)) {
    subs <- subs |> 
      dplyr::filter(answer_text == answer)
  }
  sub_ids <- subs |> 
    dplyr::pull(submission_id)  

  for(sub_id in sub_ids) {
    submission_update(submission_id = sub_id, 
                      fudge_points = fudge_points,
                      question_id = question_id,
                      score = score,
                      comment = comment,
                      course_id = course_id, 
                      url = url, 
                      token = token)
  }
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



list_scores <- function(course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"), 
                        url = Sys.getenv("CANVASQUIZ_URL"), 
                        token = Sys.getenv("CANVASQUIZ_TOKEN"),
                        n = 121) {
  get_page <- function(page) {
    resp <- course_url() |> 
      httr2::req_url_path_append("users") |> 
      httr2::req_method("GET") |>  
      httr2::req_url_query(per_page = 100, page = page) |>
      httr2::req_body_json(list(include = "enrollments")) |> 
      httr2::req_perform() |> 
      httr2::resp_body_json()
      data.frame(id = vapply(resp, function(x) x$id, numeric(1)),
                uid = vapply(resp, function(x) x$sis_user_id, character(1)),
                name = vapply(resp, function(x) x$name, character(1)),
                score_current = vapply(resp, function(x) {
                  enrollments <- x$enrollments
                  if(length(enrollments) == 0) return(NA)
                  enrollment <- enrollments[[1]]
                  if(is.null(enrollment$grades)) return(NA)
                  enrollment$grades$unposted_current_score
                }, numeric(1)))
  }
  res <- res1 <- get_page(ipage <- 1)
  while(nrow(res1) == 100 | nrow(res) < n) {
    res1 <- get_page(ipage <- ipage + 1)
    res <- rbind(res, res1)
  }
  res
}