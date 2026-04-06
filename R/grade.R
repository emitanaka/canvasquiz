

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