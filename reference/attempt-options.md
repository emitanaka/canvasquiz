# Options for showing quiz results or answers

Options for showing quiz results or answers

## Usage

``` r
opt_show(last_attempt = FALSE, one_time = FALSE, at = NULL)

opt_hide(at = NULL)

opt_shuffle()
```

## Arguments

- last_attempt:

  logical. Whether to show results/answers only after the last attempt
  is submitted. Only valid if the number of attempts is greater than 1.
  Defaults to `FALSE`.

- one_time:

  logical. Whether to show results/answers only immediately after
  submission.

- at:

  POSIXct. Date and time to control when results/answers become visible
  or hidden. If `show = TRUE`, results/answers become visible at this
  date and time. If `hide = TRUE`, results/answers become hidden at this
  date/time.

## Value

A list of options to be passed to the `results` or `answer` parameters
of
[`attempt_options()`](http://emitanaka.org/canvasquiz/reference/attempt_options.md).
