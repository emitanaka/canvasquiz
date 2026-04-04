# A quiz attempt options

A quiz attempt options

## Usage

``` r
attempt_options(
  n = 1,
  time = NULL,
  due = NULL,
  lock = NULL,
  unlock = NULL,
  results = opt_show(at = due),
  answer = opt_show(at = due),
  score = c("highest", "latest"),
  access_code = NULL,
  ip_filter = NULL
)
```

## Arguments

- n:

  The number of allowed attempts. Set to `-1` or `Inf` for unlimited.
  Defaults to `1`.

- time:

  Time limit for each attempt in minutes. Set to `NULL` for no limit
  (default).

- due:

  POSIXct. Due date and time for the quiz.

- lock:

  POSIXct. Lock date and time for the quiz.

- unlock:

  POSIXct. Unlock date and time for the quiz.

- results:

  A list of options controlling when quiz results are visible to
  students. See
  [`opt_show()`](http://emitanaka.org/canvasquiz/reference/attempt-options.md)
  and
  [`opt_hide()`](http://emitanaka.org/canvasquiz/reference/attempt-options.md).

- answer:

  A list of options controlling when correct answers are visible to
  students. See
  [`opt_show()`](http://emitanaka.org/canvasquiz/reference/attempt-options.md),
  [`opt_hide()`](http://emitanaka.org/canvasquiz/reference/attempt-options.md)
  and
  [`opt_shuffle()`](http://emitanaka.org/canvasquiz/reference/attempt-options.md).

- score:

  Scoring policy for multiple attempts. Allowed values: "`highest`"
  (default), "`latest`".

- access_code:

  Password required to access the quiz. Set to `NULL` for no restriction
  (default).

- ip_filter:

  Restrict access to computers in a specified IP range. Filters can be a
  comma-separated list of addresses, or address/mask. Examples:
  `"192.168.1.1,192.168.1.2"` or `"192.168.1.0/24"`. Set to `NULL` for
  no restriction (default).

## Value

A list of options to be passed to
[`create_quiz()`](http://emitanaka.org/canvasquiz/reference/create_quiz.md).
