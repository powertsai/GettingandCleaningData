
#check library installed then load required library 
loadLibrary <- function(instpkg) {
        if(!instpkg %in% installed.packages() ){
                install.packages(instpkg)
        }
        # load require library
        (require(instpkg, character.only = TRUE))
}

#load data.table develop version 1.9.5 for fread
loadDevDataTable <- function(instpkg) {
        if(!instpkg %in% installed.packages()  ){
                #install dev version of data.table
                loadLibrary("devtools")
                install_github("Rdatatable/data.table", build_vignettes = FALSE)
        } else {
                if(packageVersion(instpkg) != "1.9.5") {
                        #remove package and install development version
                        remove.packages(instpkg)         # First remove the current version
                        #install dev version of data.table
                        loadLibrary("devtools")                        
                        install_github("Rdatatable/data.table", build_vignettes = FALSE)                        
                }
        }
        #require libryay data.table
        return (require(instpkg, character.only = TRUE))
}