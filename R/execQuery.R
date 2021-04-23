execQuery <- function(qDomain, qName, qInput, resource){
  allq <- get('allQueries', envir = .queryLibrary)
  myQuery <- allq[[qDomain]][[qName]]$Query

  qInput <- dsSwissKnife:::.decode.arg(qInput)

# must be set via option:
  myQuery <- gsub('@cdm', getOption('cdm_schema'), myQuery, fixed = TRUE)
  for (inp in names(qInput)){
    patt <- paste0('$', inp)
    myQuery <- gsub(patt, qInput[[inp]], myQuery, fixed = TRUE)
  }
  x <- resourcex::loadQuery(get(resource, envir = parent.frame()), myQuery)
  stop(x)
  x
}