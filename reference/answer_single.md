# Create an answer object for a quiz question

This function is a wrapper that creates the appropriate answer object
based on the input. It can handle multiple choice questions, true/false
questions, short answer questions, numerical questions (with exact
answers, precision-based answers, or range-based answers), and matching
questions. The function will automatically determine the type of
question based on the format of the input and create the corresponding
answer object using the appropriate helper functions.

## Usage

``` r
answer_single(x, y = NULL, tol = 0, precision = 0)
```

## Arguments

- x:

  The correct answer(s) for the question. See details for the expected
  format based on the type of question.

- y:

  Additional parameter for certain question types. See details for the
  expected format based on the type of question.

- tol:

  The acceptable error margin for the answer. Defaults to 0 for an exact
  answer.

- precision:

  The number of decimal places the answer must be correct to.

## Details

The function uses the following logic to determine the type of question:

- If `x` is a logical value and `y` is NULL, it creates a true/false
  question using
  [`answer_true_false()`](http://emitanaka.org/canvasquiz/reference/answer_true_false.md).

- If `x` is a single numeric value and `y` is NULL, it creates a
  numerical question with an exact answer using
  [`answer_num()`](http://emitanaka.org/canvasquiz/reference/answer_num.md).
  If `tol` is greater than 0, it creates a numerical question with an
  error margin. If `precision` is greater than 0, it creates a numerical
  question with a specified precision.

- If `x` is a numeric vector of length 2, it creates a numerical
  question with a range-based answer using
  [`answer_num_range()`](http://emitanaka.org/canvasquiz/reference/answer_num.md).
  Alternatively, if `x` is a single numeric value and `y` is a single
  numeric value, it also creates a numerical question with a range-based
  answer using
  [`answer_num_range()`](http://emitanaka.org/canvasquiz/reference/answer_num.md),
  where `x` is the lower bound and `y` is the upper bound.

- If `x` is a named character vector, it creates a matching question
  using
  [`answer_matching()`](http://emitanaka.org/canvasquiz/reference/answer_matching.md).
  Any extra choices for the matching question can be provided in `y`.

- If `x` and `y` are character vectors, it creates a multiple choice
  question using
  [`answer_mcq()`](http://emitanaka.org/canvasquiz/reference/answer_mcq.md).

- If the input format does not match any of the above cases, the
  function throws an error indicating that the answer format is
  unsupported.

## See also

Other answer-functions:
[`answer_essay()`](http://emitanaka.org/canvasquiz/reference/answer_essay.md),
[`answer_matching()`](http://emitanaka.org/canvasquiz/reference/answer_matching.md),
[`answer_mcq()`](http://emitanaka.org/canvasquiz/reference/answer_mcq.md),
[`answer_multiple()`](http://emitanaka.org/canvasquiz/reference/answer_multiple.md),
[`answer_none()`](http://emitanaka.org/canvasquiz/reference/answer_none.md),
[`answer_num()`](http://emitanaka.org/canvasquiz/reference/answer_num.md),
[`answer_text()`](http://emitanaka.org/canvasquiz/reference/answer_text.md),
[`answer_true_false()`](http://emitanaka.org/canvasquiz/reference/answer_true_false.md),
[`answer_upload_file()`](http://emitanaka.org/canvasquiz/reference/answer_upload_file.md)
