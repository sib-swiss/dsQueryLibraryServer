execQuery <- function(qDomain, qName, qInput, resource = NULL){
  allq <- get('allQueries', envir = .queryLibrary)
  qList <- allq[[qDomain]]
  realQname <- grep(qName, names(qList), value = TRUE)
  myQuery <- qList[[realQname]]$Query

  qInput <- dsSwissKnife:::.decode.arg(qInput)
  if(is.null(resource)){
    for (i in ls(envir = parent.frame())){
      x <- get(i, envir = parent.frame())
      if("SQLFlexClient" %in% class(x)){
        resource <- x
        break
      }
    }
  }
  if(is.null(resource)){
    stop('Could not find a suitable database connection.')
  }

# must be set via option:
  myQuery <- gsub('@cdm', getOption('cdm_schema'), myQuery, fixed = TRUE)
#  for (inp in names(qInput)){
#    patt <- paste0('$', inp)
#    myQuery <- gsub(patt, qInput[[inp]], myQuery, fixed = TRUE)
#  }
  resourcex::loadQuery(get(resource, envir = parent.frame()), myQuery, qInput)
}