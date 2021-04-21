loadAllQueries <- function(){
  if(exists('.allQueries', envir = parent.frame())){
    return(.allQueries)
  }
  ret <- sapply( dir('inst/QueryLibrary/', no..=TRUE), function(domain){
    unlist(lapply(list.files(paste0('inst/QueryLibrary/', domain), recursive = TRUE, no..=TRUE), function(x){
        fl <- paste0('inst/QueryLibrary/', domain,'/', x)
        ret <-parseMd(fl)
        n <- ret$Name
        ret$Name <- NULL
        out <- list()
        out[[make.names(n)]] <- ret
        out
    }), recursive = FALSE)
  })
  assign('.allQueries', ret, envir = parent.frame())
  ret
}
