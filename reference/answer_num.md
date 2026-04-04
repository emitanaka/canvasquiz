# A numerical answer question with an exact answer

A numerical answer question with an exact answer

## Usage

``` r
answer_num(value, tol = 0)

answer_num_precision(value, precision = 0L)

answer_num_range(lower, upper)
```

## Arguments

- value:

  The correct numerical answer.

- tol:

  The acceptable error margin for the answer. Defaults to 0 for an exact
  answer.

- precision:

  The number of decimal places the answer must be correct to.

- lower:

  The lower bound of the acceptable answer range.

- upper:

  The upper bound of the acceptable answer range.

## See also

Other answer-functions:
[`answer_essay()`](http://emitanaka.org/canvasquiz/reference/answer_essay.md),
[`answer_matching()`](http://emitanaka.org/canvasquiz/reference/answer_matching.md),
[`answer_mcq()`](http://emitanaka.org/canvasquiz/reference/answer_mcq.md),
[`answer_multiple()`](http://emitanaka.org/canvasquiz/reference/answer_multiple.md),
[`answer_none()`](http://emitanaka.org/canvasquiz/reference/answer_none.md),
[`answer_text()`](http://emitanaka.org/canvasquiz/reference/answer_text.md),
[`answer_true_false()`](http://emitanaka.org/canvasquiz/reference/answer_true_false.md),
[`answer_upload_file()`](http://emitanaka.org/canvasquiz/reference/answer_upload_file.md)
