canvas_url <- function(
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN")
) {
  httr2::request(paste0(url, "/api/v1/")) |>
    httr2::req_auth_bearer_token(token)
}

course_url <- function(
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN")
) {
  canvas_url(url, token) |>
    httr2::req_url_path_append(paste0("courses/", course_id, "/"))
}

quizzes_url <- function(
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN")
) {
  course_url(course_id, url, token) |>
    httr2::req_url_path_append("quizzes/")
}
