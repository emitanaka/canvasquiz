

assignment_id <- function(quiz_id, 
                          course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"), 
                          url = Sys.getenv("CANVASQUIZ_URL"), 
                          token = Sys.getenv("CANVASQUIZ_TOKEN")) {
  quizzes_url(course_id, url, token) |>
    httr2::req_url_path_append(quiz_id) |>
    httr2::req_perform() |>
    httr2::resp_body_json() |>
    pluck("assignment_id")
}