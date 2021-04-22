execQuery <- function(qDomain, qName, qInput, resource){
  allq <- get('allQueries', envir = .queryLibrary)
  myQuery <- allq[[qDomain]][[qName]]
  warning('HERE')
  warning(str(allq))
  warning('STOP')
  qInput <- dsSwissKnife:::.decode.arg(qInput)
  for (inp in names(qInput)){
    patt <- paste0('$', inp)
    myQuery <- gsub(patt, qInput[[inp]], myQuery, fixed = TRUE)
  }
  resourcex::loadQuery(get(resource, envir = parent.frame()), myQuery)
}