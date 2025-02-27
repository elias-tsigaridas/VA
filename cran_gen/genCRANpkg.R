# create cran package folder
dir.create("cran_package")
# set /root as main path
path = getwd()
path = substr(path, start=1, stop=nchar(path)-9)

# download lpSolveAPI and crate src/Rproj_externals/lp_solve
library(downloader)
download("https://cran.r-project.org/src/contrib/Archive/lpSolveAPI/lpSolveAPI_5.5.2.0-17.6.tar.gz", dest="lpSolve.tar.gz", mode="wb")
untar("lpSolve.tar.gz", exdir = path)
unlink("lpSolve.tar.gz")
dir.create(paste0(path,"/R-proj/src/Rproj_externals"))
dir_lp = paste0(path,"/lpSolveAPI/src/lp_solve")
lp_dist = paste0(path,"/R-proj/src/Rproj_externals")
file.copy(dir_lp, lp_dist, recursive=TRUE)

# fix ftime deprecation, taken from: https://github.com/GeomScale/volesti/pull/89/files
library(xfun)
gsub_file(
    paste0(path,"/R-proj/src/Rproj_externals/lp_solve/commonlib.c"), 
    "struct timeb buf;", "", 
    fixed=TRUE)
gsub_file(
    paste0(path,"/R-proj/src/Rproj_externals/lp_solve/commonlib.c"), 
    "ftime(&buf);", "", 
    fixed=TRUE)
gsub_file(
    paste0(path,"/R-proj/src/Rproj_externals/lp_solve/commonlib.c"), 
    "return((double)buf.time+((double) buf.millitm)/1000.0);", 
    "return((double)0);", 
    fixed=TRUE)

# add lpsolve header files in external
library(downloader)
download("https://cran.r-project.org/src/contrib/lpSolve_5.6.15.tar.gz", dest="lpSolve.tar.gz", mode="wb")
untar("lpSolve.tar.gz", exdir = path)
unlink("lpSolve.tar.gz")
dir.create(paste0(path,"/external/LPsolve_src"))
dir.create(paste0(path,"/external/LPsolve_src/include"))
dir.create(paste0(path,"/external/LPsolve_src/run_headers"))
dir_lp = paste0(path,"/lpSolveAPI/inst/include")
h_files = dir(dir_lp, "*.h", ignore.case = TRUE, all.files = TRUE)
lp_dist = paste0(path,"/external/LPsolve_src/include")
file.copy(file.path(dir_lp, h_files), lp_dist, recursive=TRUE, overwrite=TRUE)
dir_lp = paste0(path,"/lpSolve/src")
h_files = dir(dir_lp, "*.h", ignore.case = TRUE, all.files = TRUE)
lp_dist = paste0(path,"/external/LPsolve_src/run_headers")
file.copy(file.path(dir_lp, h_files), lp_dist, recursive=TRUE)
unlink(paste0(path,"/lpSolveAPI"), recursive=TRUE)
unlink(paste0(path,"/lpSolve"), recursive=TRUE)

# copy paste the src folder
src_dir = paste0(path,'/R-proj/src')
src_dist = paste0(path,'/cran_gen/cran_package')
file.copy(src_dir, src_dist, recursive=TRUE)

# copy paste the inst folder
inst_dir = paste0(path,'/R-proj/inst')
inst_dist = paste0(path,'/cran_gen/cran_package')
file.copy(inst_dir, inst_dist, recursive=TRUE)

# copy paste the man folder
man_dir = paste0(path,'/R-proj/man')
man_dist = paste0(path,'/cran_gen/cran_package')
file.copy(man_dir, man_dist, recursive=TRUE)

# copy paste the R folder
R_dir = paste0(path,'/R-proj/R')
R_dist = paste0(path,'/cran_gen/cran_package')
file.copy(R_dir, R_dist, recursive=TRUE)

# copy paste the tests folder
tests_dir = paste0(path,'/R-proj/tests')
tests_dist = paste0(path,'/cran_gen/cran_package')
file.copy(tests_dir, tests_dist, recursive=TRUE)

# copy paste the DESCRIPTION file
descr_dir = paste0(path,'/R-proj/DESCRIPTION')
descr_dist = paste0(path,'/cran_gen/cran_package')
file.copy(descr_dir, descr_dist, recursive=TRUE)

# copy paste the NAMESPACE file
namesp_dir = paste0(path,'/R-proj/NAMESPACE')
namesp_dist = paste0(path,'/cran_gen/cran_package')
file.copy(namesp_dir, namesp_dist, recursive=TRUE)

# copy paste the volesti.Rproj
volpro_dir = paste0(path,'/R-proj/volesti.Rproj')
volpro_dist = paste0(path,'/cran_gen/cran_package')
file.copy(volpro_dir, volpro_dist, recursive=TRUE)

# copy paste the external folder
external_dir = paste0(path,'/external')
external_dist = paste0(path,'/cran_gen/cran_package/src')
file.copy(external_dir, external_dist, recursive=TRUE)

# copy paste the include folder
include_dir = paste0(path,'/include')
include_dist = paste0(path,'/cran_gen/cran_package/src')
file.copy(include_dir, include_dist, recursive=TRUE)

# copy paste the README.md file
readme_dir = paste0(path,'/cran_gen/README.md')
readme_dist = paste0(path,'/cran_gen/cran_package')
file.copy(readme_dir, readme_dist, recursive=TRUE)

# copy paste the NEWS.md file
news_dir = paste0(path,'/cran_gen/NEWS.md')
news_dist = paste0(path,'/cran_gen/cran_package')
file.copy(news_dir, news_dist, recursive=TRUE)

# copy paste the cran-comments.md file
#cran_com_dir = paste0(path,'/cran_gen/cran-comments.md')
#cran_com_dist = paste0(path,'/cran_gen/cran_package')
#file.copy(cran_com_dir, cran_com_dist, recursive=TRUE)

# copy paste the Rbuildignore.md file
Rbuild_dir = paste0(path,'/cran_gen/.Rbuildignore')
Rbuild_dist = paste0(path,'/cran_gen/cran_package')
file.copy(Rbuild_dir, Rbuild_dist, recursive=TRUE)

# replace the Makevars
makevars_dir = paste0(path,'/cran_gen/Makevars')
makevars_dist = paste0(path, '/cran_gen/cran_package/src')
file.copy(makevars_dir, makevars_dist, recursive=TRUE)

# replace the Makevars.win
makevarswin_dir = paste0(path,'/cran_gen/Makevars.win')
makevarswin_dist = paste0(path, '/cran_gen/cran_package/src')
file.copy(makevarswin_dir, makevarswin_dist, recursive=TRUE)

# copy paste the LICENCE
dir_lic = paste0(path,'/LICENSE')
lic_dist = paste0(path,'/cran_package/inst/doc')

# delete misc.h from include
dir_misc = paste0(path,'/cran_gen/cran_package/src/include/misc.h')
unlink(dir_misc, recursive = TRUE)

# delete linear_extensions.h from include
dir_lin_ext = paste0(path,'/cran_gen/cran_package/src/include/linear_extensions.h')
unlink(dir_lin_ext, recursive = TRUE)

# create lpsolve folder
dir.create(paste0(path,"/cran_gen/cran_package/src/external/lpsolve"))
dir.create(paste0(path,"/cran_gen/cran_package/src/external/lpsolve/build"))
dir.create(paste0(path,"/cran_gen/cran_package/src/external/lpsolve/headers"))
dir_lp = paste0(path,"/cran_gen/cran_package/src/Rproj_externals/lp_solve")
lp_dist = (paste0(path,"/cran_gen/cran_package/src/external/lpsolve/build"))
file.copy(dir_lp, lp_dist, recursive=TRUE)
dir_lp = paste0(path,"/cran_gen/cran_package/src/external/LPsolve_src/include")
lp_dist = (paste0(path,"/cran_gen/cran_package/src/external/lpsolve/headers"))
file.copy(dir_lp, lp_dist, recursive=TRUE)
dir_lp = paste0(path,"/cran_gen/cran_package/src/external/LPsolve_src/run_headers")
lp_dist = (paste0(path,"/cran_gen/cran_package/src/external/lpsolve/headers"))
file.copy(dir_lp, lp_dist, recursive=TRUE)
dir_lpsolve_heds = paste0(path,"/cran_gen/cran_package/src/external/LPsolve_src")
unlink(dir_lpsolve_heds, recursive = TRUE)
dir_lpsolve_heds = paste0(path,"/cran_gen/cran_package/src/Rproj_externals")
unlink(dir_lpsolve_heds, recursive = TRUE)

# replace the Makefile
makefile_dir = paste0(path,'/cran_gen/Makefile')
makefile_dist = paste0(path, '/cran_gen/cran_package/src/external/lpsolve/build/lp_solve')
file.copy(makefile_dir, makefile_dist, recursive=TRUE)

# set new cran package folder as wrking directory
setwd(paste0(path,'/cran_gen/cran_package'))
# enable devtools and Rcpp libraries
library(devtools)
library(Rcpp)

# build package tar.gz
Rcpp::compileAttributes()
devtools::build()

# set /root/R-proj as the working directory
setwd(paste0(path,'/R-proj'))

# delete folder cran_package
#dir_cr_pkg = paste0(path,'/cran_gen/cran_package')
#unlink(dir_cr_pkg, recursive = TRUE)
