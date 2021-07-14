execQuery <- function(qDomain, qName, qInput, symbol = NULL, resource = NULL){
  allq <- tryCatch(get('allQueries', envir = .queryLibrary), error = function(e){
                     loadAllQueries()
                  })
  for (typ in c('Assign', 'Aggregate')){
    qList <- allq[[typ]][[qDomain]]
    if(!is.null(qList)){
      break
    }
  }
  realQname <- grep(qName, names(qList), value = TRUE)[1]
  message(paste0('here', realQname))
  if(is.na(realQname)){
    stop(paste0('No such query name: ', qName, ' or domain: ', qDomain, '.'), call. = FALSE)
  }
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
  ret <- resourcex::loadQuery(get(resource, envir = parent.frame()), myQuery, params = qInput)
  if(typ == 'Aggregate'){
    return(ret)
  } # else it's Assign:
  if(is.null(symbol)){
    symbol <- realQname
  }
  assign(symbol, ret, envir = parent.frame())
}


