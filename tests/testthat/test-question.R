test_that("question works", {
  id <- create_quiz("Quiz for questions")
  create_question(
    title = "Title",
    text = "What is 2 + 2?",
    points = 5,
    position = 1,
    answers = answer_mcq(c("3", "4", "5"), correct = "4")
  )
  create_question(
    text = "Test",
    points = 1,
    position = 3,
    answers = answer_mcq(c("3", "4", "5"), correct = "4")
  )

  create_question(
    text = "What is 3 + 3?",
    quiz_id = id,
    points = 5,
    position = 1,
    answers = answer_num(6)
  )
  create_question(
    text = "What is 3 + 3?",
    quiz_id = id,
    points = 1,
    position = 1,
    answers = answer_num_range(5.5, 6.5),
    # below works but doesn't seem to show when completed the quiz as a test student
    correct_comments = "Correct!",
    incorrect_comments = "Incorrect. The correct answer is 6.",
    neutral_comments = "The correct answer is 6."
  )
  create_question(
    text = "What is 3 + 3?",
    answers = answer_text("6")
  )
  create_question(
    text = "Match the following:",
    answers = answer_matching(
      left = c("A", "B", "C"),
      right = c("1", "2", "3"),
      extra_choices = c("4", "5")
    )
  )
  create_question(
    text = "Match the following:",
    answers = answer_matching(
      left = c("A", "B", "C"),
      right = c("1", "2", "3")
    )
  )
  create_question(md("Describe **your _answer_**."), answers = answer_essay())
  create_question(
    "Upload a file with your answer.",
    answers = answer_upload_file()
  )
  create_question("Text only question", answers = answer_none())
  create_question(
    "Is this true or false?",
    answers = answer_true_false(correct = TRUE)
  )
  create_question(
    "Multiple answers",
    answers = answer_mcq(c("A", "B", "C"), correct = c("A", "B"))
  )
  create_question(
    "Dropdown question [blank1] and [id]",
    answers = answer_multiple(
      dropdown(
        choices = c("Option 1", "Option 2", "Option 3"),
        correct = "Option 2",
        id = "blank1"
      ),
      dropdown(
        choices = c("A", "B", "C"),
        correct = "B",
        id = "id"
      )
    )
  )
  create_question(
    "Dropdown question [blank1] and [id]",
    answers = answer_multiple(
      dropdown(
        choices = c("Option 1", "Option 2", "Option 3"),
        correct = "Option 2",
        id = "blank1"
      )
    )
  )
  create_question(
    "Dropdown question [blank1] and [id]",
    answers = answer_multiple(
      fill_in_the_blank("A", id = "blank1"),
      fill_in_the_blank("B", id = "id")
    )
  )
  delete_quiz(id)
})
