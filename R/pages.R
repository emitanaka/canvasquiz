#' List pages in a course
#' @inheritParams list_files
#' @export
list_pages <- function(
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN")
) {
  course_url(course_id, url, token) |>
    httr2::req_url_path_append("pages") |>
    httr2::req_perform() |>
    httr2::resp_body_json() |>
    dplyr::bind_rows() |>
    dplyr::distinct()
}
