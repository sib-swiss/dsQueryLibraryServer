execQuery <- function(qDomain, qName, qInput, resource = NULL){
  allq <- tryCatch(get('allQueries', envir = .queryLibrary), error = function(e){
                     loadAllQueries()
                  })
  qList <- allq[[qDomain]]
  realQname <- grep(qName, names(qList), value = TRUE)
  message(qDomain)
  message(names(qList))
  message(qName)
  message(realQname)
  myQuery <- paste(qList[[realQname]]$Query, collapse = ' ')

  qInput <- dsSwissKnife:::.decode.arg(qInput)
  if(is.null(resource)){
    for (i in ls(envir = parent.frame())){
      x <- get(i, envir = parent.frame())
      if("SQLFlexClient" %in% class(x)){
        resource <- i
        break
      }
    }
  }
  if(is.null(resource)){
    stop('Could not find a suitable database connection.')
  }

# must be set via option:
  myQuery <- gsub('@cdm', getOption('cdm_schema'), myQuery, fixed = TRUE)
  myQuery <- gsub('@vocab', getOption('vocabulary_schema'), myQuery, fixed = TRUE)
#  for (inp in names(qInput)){
#    patt <- paste0('$', inp)
#    myQuery <- gsub(patt, qInput[[inp]], myQuery, fixed = TRUE)
#  }
  resourcex::loadQuery(get(resource, envir = parent.frame()), myQuery, params = qInput)
}
