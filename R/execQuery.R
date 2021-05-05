execQuery <- function(qDomain, qName, qInput, resource){
  allq <- get('allQueries', envir = .queryLibrary)
  qList <- allq[[qDomain]]
  realQname <- grep(qName, names(qList), value = TRUE)
  myQuery <- qList[[realQname]]$Query

  qInput <- dsSwissKnife:::.decode.arg(qInput)

# must be set via option:
  myQuery <- gsub('@cdm', getOption('cdm_schema'), myQuery, fixed = TRUE)
#  for (inp in names(qInput)){
#    patt <- paste0('$', inp)
#    myQuery <- gsub(patt, qInput[[inp]], myQuery, fixed = TRUE)
#  }
  return(myQuery)
  resourcex::loadQuery(get(resource, envir = parent.frame()), myQuery, qInput)
}