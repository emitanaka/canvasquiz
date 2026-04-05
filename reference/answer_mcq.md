# Answer for a multiple choice question

Answer for a multiple choice question

## Usage

``` r
answer_mcq(correct, choices, multiple = length(correct) > 1)
```

## Arguments

- correct:

  Character vector of correct answer(s). Should be one element for
  single-answer multiple choice questions and can be multiple elements
  for multiple-answer multiple choice questions.

- choices:

  Character vector of answer choices.

- multiple:

  Logical. Whether the question allows multiple correct answers.
  Defaults to `TRUE` if `correct` has more than one element.

## See also

Other answer-functions:
[`answer_essay()`](http://emitanaka.org/canvasquiz/reference/answer_essay.md),
[`answer_matching()`](http://emitanaka.org/canvasquiz/reference/answer_matching.md),
[`answer_multiple()`](http://emitanaka.org/canvasquiz/reference/answer_multiple.md),
[`answer_none()`](http://emitanaka.org/canvasquiz/reference/answer_none.md),
[`answer_num()`](http://emitanaka.org/canvasquiz/reference/answer_num.md),
[`answer_single()`](http://emitanaka.org/canvasquiz/reference/answer_single.md),
[`answer_text()`](http://emitanaka.org/canvasquiz/reference/answer_text.md),
[`answer_true_false()`](http://emitanaka.org/canvasquiz/reference/answer_true_false.md),
[`answer_upload_file()`](http://emitanaka.org/canvasquiz/reference/answer_upload_file.md)
