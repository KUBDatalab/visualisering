generate_md_extras <- function() {
  
  library("methods")
  
  if (!require("remotes", quietly = TRUE)) {
    install.packages("remotes", repos = c(CRAN = "https://cloud.r-project.org/"))
  }
  
  if (!require("requirements", quietly = TRUE)) {
    remotes::install_github("hadley/requirements")
  }
  
  required_pkgs <- unique(c(
    ## Packages for episodes
    requirements:::req_dir("_extras_rmd"),
    ## Pacakges for tools
    requirements:::req_dir("bin")
  ))
  
  missing_pkgs <- setdiff(required_pkgs, rownames(installed.packages()))
  
  if (length(missing_pkgs)) {
    message("Installing missing required packages: ",
            paste(missing_pkgs, collapse=", "))
    install.packages(missing_pkgs)
  }
  
  if (require("knitr") && packageVersion("knitr") < '1.9.19')
    stop("knitr must be version 1.9.20 or higher")
  
  ## get the Rmd file to process from the command line, and generate the path for their respective outputs
  args  <- commandArgs(trailingOnly = TRUE)
  if (!identical(length(args), 2L)) {
    stop("input and output file must be passed to the script")
  }
  
  src_rmd <- args[1]
  dest_md <- args[2]
  
  ## knit the Rmd into markdown
  knitr::knit(src_rmd, output = dest_md)
  
  # Read the generated md files and add comments advising not to edit them
  vapply(dest_md, function(y) {
    con <- file(y)
    mdfile <- readLines(con)
    if (mdfile[1] != "---")
      stop("Input file does not have a valid header")
    mdfile <- append(mdfile, "# Please do not edit this file directly; it is auto generated.", after = 1)
    mdfile <- append(mdfile, paste("# Instead, please edit",
                                   basename(y), "in _extras_rmd/"), after = 2)
    writeLines(mdfile, con)
    close(con)
    return(paste("Warning added to YAML header of", y))
  },
  character(1))
}

generate_md_extras()