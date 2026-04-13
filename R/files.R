#' List files in a folder or course
#' @param folder_id The ID of the folder to list files from. If NULL, lists files in the course.
#' @inheritParams quiz_questions
#' @export
list_files <- function(
  folder_id = NULL,
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN")
) {
  if (!is.null(folder_id)) {
    req_head <- canvas_url(url, token) |>
      httr2::req_url_path_append("folders", folder_id, "files")
  } else {
    req_head <- course_url(course_id, url, token) |>
      httr2::req_url_path_append("files")
  }
  req_head |>
    httr2::req_perform() |>
    httr2::resp_body_json() |>
    dplyr::bind_rows() |>
    dplyr::distinct()
}



#' List the folder in a course
#' @inheritParams quiz_questions
#' @export
list_folder <- function(
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN"),
  tz = Sys.timezone()
) {
  df <- course_url(course_id) |>
    httr2::req_url_path_append("folders/") |>
    httr2::req_perform() |>
    httr2::resp_body_json() |>
    dplyr::bind_rows() |> 
    convert_time("created_at", tz) |> 
    convert_time("updated_at", tz)
  df
}

#' Upload a file to a folder
#' @param file The path to the file to upload.
#' @param folder_id The ID of the folder to upload the file to.
#' @inheritParams quiz_questions
#' @export
upload_file <- function(
  file,
  folder_id = NULL,
  #overwrite = TRUE,
  course_id = Sys.getenv("CANVASQUIZ_COURSE_ID"),
  url = Sys.getenv("CANVASQUIZ_URL"),
  token = Sys.getenv("CANVASQUIZ_TOKEN")
) {
  if(is.null(folder_id)) {
    folder_id <- list_folder(course_id, url, token) |> 
      dplyr::filter(created_at == max(created_at)) |> 
      dplyr::pull(id)
    cli::cli_alert("The folder ID is not provided. Uploading to the most recently created folder with ID {.val {folder_id}}.")
  }
  resp <- canvas_url(url, token) |>
    httr2::req_url_path_append("folders", folder_id, "files/") |>
    httr2::req_body_json(list(
      name = basename(file),
      size = file.size(file),
      parent_folder_id = folder_id,
      on_duplicate = "overwrite"
    )) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  upload_url <- resp |>
    pluck("upload_url")

  upload_param <- resp |>
    pluck("upload_params")

  resp <- httr2::request(upload_url) |>
    httr2::req_body_multipart(!!!upload_param, file = curl::form_file(file)) |>
    httr2::req_perform() |>
    httr2::resp_body_json()

  cli::cli_inform("File {.val {basename(file)}} uploaded to folder ID {.val {folder_id}}.")

  resp$id
}
