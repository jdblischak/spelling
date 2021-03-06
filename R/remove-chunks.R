# Adapted from lintr:::extract_r_source
remove_chunks <- function(path) {
  path <- normalizePath(path, mustWork = TRUE)
  filename <- basename(path)
  lines <- readLines(path, encoding = 'UTF-8')

  pattern <- get_knitr_pattern(filename, lines)
  if (is.null(pattern$chunk.begin) || is.null(pattern$chunk.end)) {
    return(lines)
  }

  starts <- grep(pattern$chunk.begin, lines, perl = TRUE)
  ends <- grep(pattern$chunk.end, lines, perl = TRUE)

  # no chunks found, so just return the lines
  if (length(starts) == 0 || length(ends) == 0) {
    return(lines)
  }

  # Find first ending after a start
  seqs <- lapply(starts, function(start){
    end <- sort(ends[ends > start])[1]
    if(!is.na(end))
      seq(start, end)
  })
  lines[unlist(seqs)] = ""
  return(lines)
}

detect_pattern <- function(...){
  utils::getFromNamespace('detect_pattern', 'knitr')(...)
}

get_knitr_pattern <- function(filename, lines) {
  pattern <- detect_pattern(lines, tolower(tools::file_ext(filename)))
  if (!is.null(pattern)) {
    knitr::all_patterns[[pattern]]
  } else {
    NULL
  }
}
