pluck <- function(x, name) {
  x[[name]]
}


cli_abort_if_not <- function(
  ...,
  .call = .envir,
  .envir = parent.frame(),
  .frame = .envir
) {
  dots <- list(...)
  dots_names <- names(dots)
  for (i in seq_len(length(dots))) {
    if (!all(dots[[i]])) {
      cli::cli_abort(
        dots_names[i],
        .call = .call,
        .envir = .envir,
        .frame = .frame
      )
    }
  }
  invisible(NULL)
}

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

#' Convert Markdown to HTML
#'
#' @param text A character string containing Markdown text.
#' @export
md <- function(text) {
  commonmark::markdown_html(text)
}

#' Get the ID of the most recently created quiz in a course
#'
#' @return The ID of the most recently created quiz in the specified course.
#' @name last-ids
#' @export
last_quiz_id <- function() {
  if (!is.na(.CANVASQUIZ_ENV$LAST_QUIZ_ID)) {
    return(.CANVASQUIZ_ENV$LAST_QUIZ_ID)
  }
  quiz_df <- list_quizzes()
  if (nrow(quiz_df) == 0) {
    cli::cli_inform("No quizzes found in the course.")
    return(NA)
  }
  qid <- sort(quiz_df$id, decreasing = TRUE)[1]
  set_last_quiz_id(qid)
  return(qid)
}

#' @rdname last-ids
#' @export
last_question_id <- function() {
  .CANVASQUIZ_ENV$LAST_QUESTION_ID
}

.CANVASQUIZ_ENV <- new.env(parent = emptyenv())
.CANVASQUIZ_ENV$LAST_QUIZ_ID <- NA
.CANVASQUIZ_ENV$LAST_QUESTION_ID <- NA

set_last_quiz_id <- function(quiz_id) {
  .CANVASQUIZ_ENV$LAST_QUIZ_ID <- quiz_id
}
set_last_question_id <- function(question_id) {
  .CANVASQUIZ_ENV$LAST_QUESTION_ID <- question_id
}
get_last_question_id <- function() {
  .CANVASQUIZ_ENV$LAST_QUESTION_ID
}

#' Generate an HTML image tag for a file in a Canvas course
#' 
#' This function creates an HTML `<img>` tag that can be used to display an image file stored in a Canvas course. The image will be displayed at 50% width.
#' @param file_id The file ID of the image in Canvas.
#' @param width The width of the image (default is "100%").
#' @param class Optional CSS class to apply to the `<img>` tag.
#' @param course_id The ID of the Canvas course where the file is stored (default is taken from the environment variable `CANVAS_COURSE_ID`).
#' @return A character string containing the HTML `<img>` tag for the specified image file.
#' @export
tag_img <- function(file_id, width = "100%", class = "", course_id = Sys.getenv("CANVAS_COURSE_ID")) {
  sprintf("<img width='%s' class='%s' src='/courses/%s/files/%s/preview'>", as.character(width), class, course_id, file_id)
}

#' Generate an HTML link to download a file in a Canvas course
#' This function creates an HTML link that allows users to download a file stored in a Canvas course. The link will point to the download URL for the specified file.
#' @param file_id The file ID of the file in Canvas.
#' @param text The text to display for the download link (default is "Download").
#' @return A character string containing the HTML link to download the specified file.
#' @export
tag_file <- function(file_id, text = "Download") {
  sprintf("<a href='/files/%s/download'>%s</a>", file_id, text)
}

#' @rdname tag_file
#' @export
upload_tag_file <- function(file_path, text = "Download", folder_id = NULL, course_id = Sys.getenv("CANVAS_COURSE_ID"), url = Sys.getenv("CANVAS_URL"), token = Sys.getenv("CANVAS_TOKEN")) {
  fid <- upload_file(file_path, folder_id, course_id, url, token)
  tag_file(fid, text = text)
}

#' @rdname tag_img
#' @export
upload_tag_img <- function(file_path, width = "100%", class = "", folder_id = NULL, course_id = Sys.getenv("CANVAS_COURSE_ID"), url = Sys.getenv("CANVAS_URL"), token = Sys.getenv("CANVAS_TOKEN")) {
  fid <- upload_file(file_path, folder_id, course_id, url, token)
  tag_img(fid, width, class, course_id)
}

convert_time <- function(.data, col, tz = Sys.timezone()) {
  if(col %in% names(.data)) {
    .data[[col]] <- as.POSIXct(.data[[col]], tz = "UTC", format = "%Y-%m-%dT%H:%M:%OSZ")
    attr(.data[[col]], "tzone") <- tz
  }
  .data
}

