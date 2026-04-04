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
