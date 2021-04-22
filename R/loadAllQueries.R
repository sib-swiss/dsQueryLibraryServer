loadAllQueries <- function(){
  if(exists('allQueries', envir = .queryLibrary)){
    return(allQueries)
  }
  ql <- system.file('QueryLibrary', package = 'dsQueryLibraryServer')
 ql <- paste0(ql, '/')
  ret <- sapply( dir(ql, no..=TRUE), function(domain){
    unlist(lapply(list.files(paste0(ql, domain), recursive = TRUE, no..=TRUE), function(x){
        fl <- paste0(ql, domain,'/', x)
        ret <-parseMd(fl)
        n <- ret$Name
        ret$Name <- NULL
        out <- list()
        out[[make.names(n)]] <- ret
        out
    }), recursive = FALSE)
  })
  assign('allQueries', ret, envir = .queryLibrary)
  ret
}
