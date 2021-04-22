.init <- function(){
  .queryLibrary <<- new.env(parent=.GlobalEnv)
  assign(allQueries, loadAllQueries(), envir = .queryLibrary)
}