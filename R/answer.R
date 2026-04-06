
#' Create an answer object for a quiz question
#' 
#' This function is a wrapper that creates the appropriate answer object based on the input. It can handle multiple choice questions, true/false questions, short answer questions, numerical questions (with exact answers, precision-based answers, or range-based answers), and matching questions. The function will automatically determine the type of question based on the format of the input and create the corresponding answer object using the appropriate helper functions.
#' 
#' @details The function uses the following logic to determine the type of question:
#' - If `x` is a logical value and `y` is NULL, it creates a true/false question using `answer_true_false()`.
#' - If `x` is a single numeric value and `y` is NULL, it creates a numerical question with an exact answer using `answer_num()`. If `tol` is greater than 0, it creates a numerical question with an error margin. If `precision` is greater than 0, it creates a numerical question with a specified precision.
#' - If `x` is a numeric vector of length 2, it creates a numerical question with a range-based answer using `answer_num_range()`. Alternatively, if `x` is a single numeric value and `y` is a single numeric value, it also creates a numerical question with a range-based answer using `answer_num_range()`, where `x` is the lower bound and `y` is the upper bound.
#' - If `x` is a named character vector, it creates a matching question using `answer_matching()`. Any extra choices for the matching question can be provided in `y`.
#' - If `x` and `y` are character vectors, it creates a multiple choice question using `answer_mcq()`.
#' - If the input format does not match any of the above cases, the function throws an error indicating that the answer format is unsupported.
#' 
#' @param x The correct answer(s) for the question. See details for the expected format based on the type of question.
#' @param y Additional parameter for certain question types. See details for the expected format based on the type of question.
#' @inheritParams answer_num_precision
#' @inheritParams answer_num_range
#' @family answer-functions
#' @export
answer_single <- function(x, y = NULL, tol = 0, precision = 0) {
  if(is.logical(x) & is.null(y)) {
    return(answer_true_false(x))
  }
  if(is.numeric(x) & length(x) == 1 & is.null(y)) {
    if(tol > 0) {
      return(answer_num(x, tol))
    } else if(precision > 0) {
      return(answer_num_precision(x, precision))
    } 
    return(answer_num(x))
  }
  if(is.numeric(x) & is.numeric(y)) {
    return(answer_num_range(x, y))
  }
  if(is.numeric(x) & length(x) == 2) {
    return(answer_num_range(x[1], x[2]))
  }
  if(is.character(x) & !is.null(names(x))) {
    return(answer_matching(left = names(x), right = x, extra_choices = y))
  }
  if(is.character(x) & is.character(y)) {
    return(answer_mcq(correct = x, choices = y))
  }
  cli::cli_abort("Unsupported answer format.")
}

#' Answer for a multiple choice question
#'
#' @param correct Character vector of correct answer(s). Should be one element for single-answer multiple choice questions and can be multiple elements for multiple-answer multiple choice questions.
#' @param choices Character vector of answer choices.
#' @param multiple Logical. Whether the question allows multiple correct answers. Defaults to `TRUE` if `correct` has more than one element.
#'
#' @family answer-functions
#' @export
answer_mcq <- function(correct, choices, multiple = length(correct) > 1) {
  if(!all(correct %in% choices)) {
    cli::cli_abort(
      "All correct answers must be included in the choices. The following correct answers are not in the choices: {.val {setdiff(correct, choices)}}."
    )
  }
  if (length(correct) == 1 & !multiple) {
    structure(
      lapply(choices, function(text) {
        weight <- ifelse(text == correct, 100, 0)
        list(answer_text = text, answer_weight = weight)
      }),
      class = "multiple_choice_question"
    )
  } else {
    structure(
      lapply(choices, function(text) {
        weight <- ifelse(text %in% correct, 100, 0)
        list(answer_text = text, answer_weight = weight)
      }),
      class = "multiple_answers_question"
    )
  }
}

#' True or False Question
#'
#' @param correct Logical. Whether the correct answer is `TRUE` or `FALSE`.
#' @family answer-functions
#' @export
answer_true_false <- function(correct = TRUE) {
  choices <- c("True", "False")
  correct <- ifelse(correct, "True", "False")
  res <- answer_mcq(correct, choices)
  attr(res, "class") <- "true_false_question"
  res
}

#' Multiple answer question
#'
#' This function allows you to create a question with multiple parts, such as multiple dropdowns or fill-in-the-blank questions with multiple blanks. Each part is created with a separate answer object (e.g. created by `dropdown()` or `fill_in_the_blank()`) and then combined into a single question with this function.
#'
#' The question text should include square-bracketed text corresponding to the `id` of each answer part to indicate where in the question text each part should be displayed. For example, if you have two dropdown answer parts with ids "blank1" and "blank2", your question text might look like "The capital of France is \code{[blank1]} and the capital of Spain is \code{[blank2]}."
#'
#' All answer parts must be of the same type (e.g. all dropdowns or all fill-in-the-blank). The function will throw an error if you try to combine different types of answer parts or if the question text includes blank ids that do not correspond to any answer part ids.
#'
#' For fill-in-the-blank questions, the answer may be marked incorrect even if it is technically correct. This seems to be the result of encoding. If you manually edit and resave the questions, this seems to fix the issue.
#'
#' @param ... Multiple dropdown answer objects created by [dropdown()] or [fill_in_the_blank()]..
#' @family answer-functions
#' @export
answer_multiple <- function(...) {
  dots <- c(...)
  cls <- unique(vapply(dots, function(dot) dot$class, character(1)))
  if (length(cls) != 1) {
    cli::cli_abort("All answers must be of the same type.")
  }
  if (cls == "dropdown") {
    structure(dots, class = "multiple_dropdowns_question")
  } else if (cls == "fitb") {
    structure(dots, class = "fill_in_multiple_blanks_question")
  } else {
    cli::cli_abort(
      "Multiple answers questions must be created with dropdown() or fill_in_the_blank() answer objects."
    )
  }
}

#' Create a dropdown answer for a fill-in-multiple-blanks question
#' @inheritParams answer_mcq
#' @param blank_id The ID of the blank this dropdown corresponds to.
#' @export
dropdown <- function(correct, choices, id = NULL) {
  lapply(choices, function(text) {
    weight <- ifelse(text == correct, 100, 0)
    list(
      answer_text = text,
      answer_weight = weight,
      blank_id = id,
      class = "dropdown"
    )
  })
}

#' Create a fill-in-the-blank answer for a fill-in-multiple-blanks question
#' @param correct The correct answer text for this blank.
#' @param id The ID of the blank this answer corresponds to.
#' @export
fill_in_the_blank <- function(correct, id = NULL) {
  list(list(answer_text = correct, blank_id = id, class = "fitb"))
}

#' A short answer question
#' @param correct The correct answer text.
#' @family answer-functions
#' @export
answer_text <- function(correct) {
  structure(list(list(answer_text = correct)), class = "short_answer_question")
}

#' A numerical answer question with an exact answer
#' @param value The correct numerical answer.
#' @param tol The acceptable error margin for the answer. Defaults to 0 for an exact answer.
#' @param precision The number of decimal places the answer must be correct to.
#' @param lower The lower bound of the acceptable answer range.
#' @param upper The upper bound of the acceptable answer range.
#' @family answer-functions
#' @export
answer_num <- function(value, tol = 0) {
  if(abs(value) < 0.0001 | (tol > 0 & tol < 0.0001)) {
    cli::cli_alert_warning(
      "The answers are rounded to 4 decimal places. This means {.arg value} that are less than 0.0001 are rounded to 0 and {.arg tol} should be greater or equal to 0.0001. Consider using {.fn answer_num_precision()} with an appropriate precision instead."
    )
  }
  structure(
    list(list(
      numerical_answer_type = "exact_answer",
      answer_exact = value,
      answer_error_margin = tol
    )),
    class = c("numerical_question", "list")
  )
}


#' @rdname answer_num
#' @export
answer_num_precision <- function(value, precision = 0L) {
  structure(
    list(list(
      numerical_answer_type = "precision_answer",
      answer_approximate = value,
      answer_precision = precision
    )),
    class = c("numerical_question", "list")
  )
}

#' @rdname answer_num
#' @export
answer_num_range <- function(lower, upper = lower) {
  structure(
    list(list(
      numerical_answer_type = "range_answer",
      answer_range_start = lower,
      answer_range_end = upper
    )),
    class = c("numerical_question", "list")
  )
}

#' Answer for a matching question
#' @param left Character vector of the left-hand side items to be matched.
#' @param right Character vector of the right-hand side items to be matched. Must be the same length as `left`.
#' @param extra_choices Character vector of extra choices that can be used as incorrect matches. Optional.
#' @family answer-functions
#' @export
answer_matching <- function(left, right, extra_choices = "") {
  ll <- lapply(1:length(left), function(i) {
    list(
      answer_match_left = left[i],
      answer_match_right = right[i]
    )
  })
  structure(
    ll,
    answer = list(left = left, right = right, extra_choices = extra_choices),
    class = c("matching_question", "list")
  )
}

#' Answer for an essay question
#'
#' @family answer-functions
#' @export
answer_essay <- function() {
  structure(list(), class = c("essay_question", "list"))
}

#' A file upload question
#'
#' @family answer-functions
#' @export
answer_upload_file <- function() {
  structure(list(), class = c("file_upload_question", "list"))
}

#' A text-only question with no answers
#'
#' @family answer-functions
#' @export
answer_none <- function() {
  structure(list(), class = c("text_only_question", "list"))
}

#' Answer for a fill-in-multiple-blanks question
#'
#' @export
answer_fill_in_multiple_blanks <- function(answers, blank_ids) {
  if (length(answers) != length(blank_ids)) {
    cli::cli_abort("Length of answers and blank_ids must be the same.")
  }
  structure(
    lapply(1:length(answers), function(i) {
      list(answer_text = answers[i], blank_id = blank_ids[i])
    }),
    answer = list(answers = answers, blank_ids = blank_ids),
    class = c("fill_in_multiple_blanks_question", "list")
  )
}

#' @export
print.text_only_question <- function(x, ...) {
  cli::cat_bullet("No specific answer", bullet_col = "green", bullet = "stop")
}

#' @export
print.essay_question <- function(x, ...) {
  cli::cat_bullet("No specific answer", bullet_col = "green", bullet = "double_line")
}

#' @export
print.file_upload_question <- function(x, ...) {
  cli::cat_bullet("No specific answer", bullet_col = "green", bullet = "square")
}

#' @export
print.matching_question <- function(x, ...) {
      left <- attr(x, "answer")$left
      right <- attr(x, "answer")$right
      extra_choices <- attr(x, "answer")$extra_choices
      for (i in seq_along(left)) {
        cli::cat_bullet(paste0(left[i], " → ", right[i]), bullet_col = "green", bullet = "tick")
      }
      if (length(extra_choices) > 0) {
        cli::cli_alert_info(
          "Extra choices: {paste(extra_choices, collapse = ', ')}"
        )
      }
}

#' @export
print.numerical_question <- function(x, ...) {
      type <- x[[1]]$numerical_answer_type
      if (type == "exact_answer") {
        cli::cat_bullet(paste0(
          x[[1]]$answer_exact,
          " ± ",
          x[[1]]$answer_error_margin
        ), bullet_col = "green", bullet = "tick")
      } else if (type == "precision_answer") {
        cli::cat_bullet(paste0(
          x[[1]]$answer_approximate,
          " with precision ",
          x[[1]]$answer_precision
        ), bullet_col = "green", bullet = "tick")
      } else if (type == "range_answer") {
        cli::cat_bullet(paste0(
          x[[1]]$answer_range_start,
          " to ",
          x[[1]]$answer_range_end
        ), bullet_col = "green", bullet = "tick")
      }
}

#' @export
print.short_answer_question <- function(x, ...) {
  cli::cat_bullet(x[[1]]$answer_text, bullet_col = "green", bullet = "tick")
}

#' @export
print.multiple_choice_question <- function(x, ...) {
  for (i in seq_along(x)) {
        ans <- x[[i]]
        if ((ans$answer_weight %||% ans$weight) == 100) {
          cli::cat_bullet(
            ans$answer_text %||% ans$text,
            bullet_col = "green",
            bullet = "tick"
          )
        } else {
          cli::cat_bullet(ans$answer_text %||% ans$text, bullet_col = "red", bullet = "cross")
        }
  }
}

#' @export
print.multiple_answers_question <- function(x, ...) {
  for (i in seq_along(x)) {
        ans <- x[[i]]
        if (ans$answer_weight == 100) {
          cli::cat_bullet(
            ans$answer_text,
            bullet_col = "green",
            bullet = "tick"
          )
        } else {
          cli::cat_bullet(ans$answer_text, bullet_col = "red", bullet = "cross")
        }
  }
}

#' @export
print.true_false_question <- function(x, ...) {
  print.multiple_choice_question(x, ...)
}

#' @export
print.multiple_dropdowns_question <- function(x, ...) {
  blank_id_prev <- ""
  for (i in seq_along(x)) {
    ans <- x[[i]]
    blank_id <- ans$blank_id
    if(blank_id_prev != blank_id) {
      cli::cat_bullet(cli::bg_br_white(cli::col_black(paste0("[", blank_id, "]"))), bullet_col = "blue", bullet = "arrow_right")
      blank_id_prev <- blank_id
    }
    if (ans$answer_weight == 100) {
      cli::cat_bullet(
        ans$answer_text,
        bullet_col = "green",
        bullet = "tick"
      )
    } else {
      cli::cat_bullet(
        ans$answer_text,
        bullet_col = "red",
        bullet = "cross"
      )
    }
  }
}

#' @export
print.fill_in_multiple_blanks_question <- function(x, ...) {
  blank_id_prev <- ""
  for (i in seq_along(x)) {
    ans <- x[[i]]
    blank_id <- ans$blank_id
    if(blank_id_prev != blank_id) {
      blank_id_prev <- blank_id
    }
    cli::cat_bullet(
      cli::bg_br_white(cli::col_black(paste0("[", blank_id, "]"))), ": ",
      ans$answer_text,
      bullet_col = "green",
      bullet = "tick"
    )
  }
}