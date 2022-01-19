execQuery <- function(qDomain, qName, qInput, symbol = NULL, rowFilter = NULL, rowLimit = NULL, resource = NULL, union = TRUE){
 
myEnv <- parent.frame()  
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
  
  if(is.na(realQname)){
    stop(paste0('No such query name: ', qName, ' or domain: ', qDomain, '.'), call. = FALSE)
  }
  myQuery <- paste(qList[[realQname]]$Query, collapse = ' ')

  qInput <- dsSwissKnife:::.decode.arg(qInput)
  if(is.null(resource)){
    resource <- c()
    for (i in ls(envir = myEnv)){
      x <- get(i, envir = myEnv)
      if("SQLFlexClient" %in% class(x)){
        resource <- c(resource, i)
      }
    }
  }
  if(is.null(resource)){ # still
    stop('Could not find a suitable database connection.')
  } else {
    resource <- dsSwissKnife:::.decode.arg(resource)
  }

# must be set via option:
  myQuery <- gsub('@cdm', getOption('cdm_schema', default = 'public'), myQuery, fixed = TRUE)
  myQuery <- gsub('@vocab', getOption('vocabulary_schema', default = 'public'), myQuery, fixed = TRUE)
  
  # add the filter and limit
  rowFilter <- dsSwissKnife:::.decode.arg(rowFilter)
  if(!is.null(rowFilter) && typ == 'Assign'){
    # some basic sql injection defense:
    if(grepl('delete|drop|insert|truncate|update|;', rowFilter, ignore.case = TRUE)){
      stop('The filtering clause looks dangerous, not executing', call. = FALSE)
    }
    
    myQuery <- paste0('select * from (', myQuery,  ') xyx where ', rowFilter)
  }
  if(!is.null(rowLimit) && typ == 'Assign'){
    myQuery <- paste0('select * from (', myQuery,  ') zyz limit ', rowLimit)
  }
  
  
  ret <- sapply(resource, function(x){
    out <- resourcex::qLoad(get(x, envir = myEnv), myQuery, params = qInput)
   }, simplify = FALSE)
  
  
  
  if(typ == 'Aggregate'){
  ret <- sapply(ret, function(x) .strip_sensitive_cols(qList[[realQname]][['Sensitive fields']], x), simplify = FALSE)
    return(ret)
  } # else it's Assign:
  if(is.null(symbol)){
    symbol <- realQname
  }
#  sapply(names(ret), function(x){

    # if there's more than one, add a column with the resource name:
  #   if(length(names(ret)) > 1){
  #     if(NROW(ret[[x]]) > 0 ){
  #       ret[[x]]$database <- x
  #     }
  #     symbol <- paste0(symbol, '_', x)
  #   }
  #   # export it in the environment:
  #   assign(symbol, ret[[x]], envir = myEnv)
  # })
  
  # if there's more than one, add a column with the resource name:
  
  if(length(names(ret)) > 1){
    ret <- sapply(names(ret), function(x){
      if(NROW(ret[[x]]) > 0 ){
        ret[[x]]$database <- x
        ret[[x]]
      }
    }, simplify = FALSE)
    # rbind them all if so asked:
    if(union){
      assign(symbol, Reduce(function(x,y) rbind(x,y, stringsAsFactors = TRUE), ret), envir = .GlobalEnv)
    } else { # or not:
      sapply(names(ret), function(x){
        assign(paste0(symbol, '_', x), ret[[x]], envir = .GlobalEnv)
      })
    }

  
  } else { # only one db
    assign(symbol, ret[[1]], envir = .GlobalEnv)
  }
  return(TRUE)
}


.strip_sensitive_cols <- function(cols, df){
  you_must <- getOption('dsQueryLibrary.enforce_strict_privacy', default = TRUE)
  if(you_must && !is.null(cols)){
    lim <- getOption("datashield.privacyLevel", default = 5)
    for (mycol in cols){
      mycol <- gsub('\\s+', '', mycol)
      df[df[,mycol] < lim, mycol] <- NA
    }
    
  }
  return(df)
}


