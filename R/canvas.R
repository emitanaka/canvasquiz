#' Set and get Canvas course, URL, and token
#'
#' These functions set and retrieve the Canvas course ID, URL, and token from
#' environment variables. This allows for easy configuration of API calls to the
#' Canvas API without hardcoding sensitive information in the code.
#'
#' @param course_id The Canvas course ID to use for API calls.
#' @param url The base URL for the Canvas instance (e.g., "https://
#' canvas.instructure.com").
#' @param token The API token for authenticating with the Canvas API.
#'
#' @name canvas
#' @export
set_canvas_course_id <- function(
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID")
) {
  Sys.setenv(CANVASQUIZ_COURSE_ID = course_id)
}

#' @rdname canvas
#' @export
get_canvas_course_id <- function() {
  Sys.getenv("CANVASQUIZ_COURSE_ID")
}

#' @rdname canvas
#' @export
set_canvas_url <- function(url = Sys.getenv("CANVASQUIZ_URL")) {
  Sys.setenv(CANVASQUIZ_URL = url)
}

#' @rdname canvas
#' @export
get_canvas_url <- function() {
  Sys.getenv("CANVASQUIZ_URL")
}

#' @rdname canvas
#' @export
set_canvas_token <- function(token = Sys.getenv("CANVASQUIZ_TOKEN")) {
  Sys.setenv(CANVASQUIZ_TOKEN = token)
}

#' @rdname canvas
#' @export
get_canvas_token <- function() {
  Sys.getenv("CANVASQUIZ_TOKEN")
}
