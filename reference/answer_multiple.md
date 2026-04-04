# Multiple answer question

This function allows you to create a question with multiple parts, such
as multiple dropdowns or fill-in-the-blank questions with multiple
blanks. Each part is created with a separate answer object (e.g. created
by [`dropdown()`](http://emitanaka.org/canvasquiz/reference/dropdown.md)
or
[`fill_in_the_blank()`](http://emitanaka.org/canvasquiz/reference/fill_in_the_blank.md))
and then combined into a single question with this function.

## Usage

``` r
answer_multiple(...)
```

## Arguments

- ...:

  Multiple dropdown answer objects created by
  [`dropdown()`](http://emitanaka.org/canvasquiz/reference/dropdown.md)
  or
  [`fill_in_the_blank()`](http://emitanaka.org/canvasquiz/reference/fill_in_the_blank.md)..

## Details

The question text should include square-bracketed text corresponding to
the `id` of each answer part to indicate where in the question text each
part should be displayed. For example, if you have two dropdown answer
parts with ids "blank1" and "blank2", your question text might look like
"The capital of France is `[blank1]` and the capital of Spain is
`[blank2]`."

All answer parts must be of the same type (e.g. all dropdowns or all
fill-in-the-blank). The function will throw an error if you try to
combine different types of answer parts or if the question text includes
blank ids that do not correspond to any answer part ids.

For fill-in-the-blank questions, the answer may be marked incorrect even
if it is technically correct. This seems to be the result of encoding.
If you manually edit and resave the questions, this seems to fix the
issue.

## See also

Other answer-functions:
[`answer_essay()`](http://emitanaka.org/canvasquiz/reference/answer_essay.md),
[`answer_matching()`](http://emitanaka.org/canvasquiz/reference/answer_matching.md),
[`answer_mcq()`](http://emitanaka.org/canvasquiz/reference/answer_mcq.md),
[`answer_none()`](http://emitanaka.org/canvasquiz/reference/answer_none.md),
[`answer_num()`](http://emitanaka.org/canvasquiz/reference/answer_num.md),
[`answer_text()`](http://emitanaka.org/canvasquiz/reference/answer_text.md),
[`answer_true_false()`](http://emitanaka.org/canvasquiz/reference/answer_true_false.md),
[`answer_upload_file()`](http://emitanaka.org/canvasquiz/reference/answer_upload_file.md)
