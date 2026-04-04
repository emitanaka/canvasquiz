test_that("quiz functions work", {
  set_canvas_course_id(5174)
  id <- create_quiz("Default")
  create_quiz("One question at a time", one_question_at_a_time = "yes")
  create_quiz("All questions at once", one_question_at_a_time = "no")
  create_quiz(
    "All questions at once, but can't go back",
    one_question_at_a_time = "yes_but_cant_go_back"
  )
  create_quiz("Quiz with attempts", attempts = attempt_options(n = 3))
  create_quiz("Quiz with time limit", attempts = attempt_options(time = 30))
  create_quiz(
    "Quiz with due date",
    attempts = attempt_options(due = as.POSIXct("2024-12-31 23:59:00"))
  )
  create_quiz(
    "Quiz with due date, but no answers",
    attempts = attempt_options(
      due = as.POSIXct("2024-12-31 23:59:00"),
      answer = opt_hide()
    )
  )
  create_quiz(
    "Quiz that show answer, no results",
    attempts = attempt_options(results = opt_hide(), answer = opt_show())
  )
  create_quiz(
    "Quiz that hide answer, shuffle answers",
    attempts = attempt_options(answer = c(opt_hide(), opt_shuffle()))
  )
  create_quiz("Published quiz", publish = TRUE)
  create_quiz(
    "Visible to overrides quiz",
    visible = "none",
    quiz_type = "assignment"
  )
  create_quiz("Assignment", quiz_type = "assignment")
  create_quiz("Described quiz", "Long description of quiz")
  list_quizzes()
  delete_quiz(id)
  delete_all_quizzes()
})
