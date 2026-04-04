#' List files in a folder or course
#' @param folder_id The ID of the folder to list files from. If NULL, lists files in the course.
#' @inheritParams quiz_questions
#' @export
list_files <- function(
  folder_id = NULL,
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN")
) {
  if (!is.null(folder_id)) {
    req_head <- canvas_url(url, token) |>
      httr2::req_url_path_append("folders", folder_id, "files")
  } else {
    req_head <- course_url(course_id, url, token) |>
      httr2::req_url_path_append("files")
  }
  req_head |>
    httr2::req_perform() |>
    httr2::resp_body_json() |>
    dplyr::bind_rows() |>
    dplyr::distinct()
}
