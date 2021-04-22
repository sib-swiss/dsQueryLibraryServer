execQuery <- function(qDomain, qName, qInput, resource){
  allq <- get('allQueries', envir = parent.frame())
  myQuery <- allq[[qDomain]][[qName]]
  stop(myQuery)
  qInput <- dsSwissKnife:::.decode.arg(qInput)
  for (inp in names(qInput)){
    patt <- paste0('$', inp)
    myQuery <- gsub(patt, qInput[[inp]], myQuery, fixed = TRUE)
  }
  resourcex::loadQuery(get(resource, envir = parent.frame()), myQuery)
}