.init <- function(){
  options(cdm_schema = 'public')
  options(vocabulary_schema = 'public')
  .queryLibrary <<- new.env(parent=.GlobalEnv)
  loadAllQueries()
}