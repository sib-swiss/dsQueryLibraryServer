execQuery <- function(qDomain, qName, qInput, resource){
  myQuery <- .allQueries[[qDomain]][[qName]]
  qInput <- dsSwissKnife::.decode.arg(qInput)
  for (inp in names(qInput)){
    patt <- paste0('$', inp)
    myQuery <- gsub(patt, qInput[[inp]], myQuery, fixed = TRUE)
  }
  resourcex::loadQuery(resource, myQuery)
}