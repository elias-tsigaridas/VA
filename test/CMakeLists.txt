# VolEsti (volume computation and sampling library)
# Copyright (c) 2012-2020 Vissarion Fisikopoulos
# Copyright (c) 2018-2020 Apostolos Chalkis
# Copyright (c) 2021 Vaibhav Thakkar

# Contributed and/or modified by Vaibhav Thakkar
# Licensed under GNU LGPL.3, see LICENCE file

project( VolEsti )

enable_testing()

CMAKE_MINIMUM_REQUIRED(VERSION 3.11)

set(CMAKE_ALLOW_LOOSE_LOOP_CONSTRUCTS true)

# Locate Intel MKL root (in case it is enabled)

if (APPLE)
	set(MKLROOT /opt/intel/oneapi/mkl/latest)
elseif(UNIX)
	set(MKLROOT $ENV{HOME}/intel/mkl)
endif()


option(DISABLE_NLP_ORACLES "Disable non-linear oracles (used in collocation)" ON)
option(BUILTIN_EIGEN "Use eigen from ../external" OFF)
option(USE_MKL "Use MKL library to build eigen" OFF)

if(DISABLE_NLP_ORACLES)
  add_definitions(-DDISABLE_NLP_ORACLES)
else()
  find_library(IFOPT NAMES libifopt_core.so PATHS /usr/local/lib)
  find_library(IFOPT_IPOPT NAMES libifopt_ipopt.so PATHS /usr/local/lib)
  find_library(GMP NAMES libgmp.so PATHS /usr/lib/x86_64-linux-gnu /usr/lib/i386-linux-gnu)
  find_library(MPSOLVE NAMES libmps.so PATHS /usr/local/lib)
  find_library(PTHREAD NAMES libpthread.so PATHS /usr/lib/x86_64-linux-gnu /usr/lib/i386-linux-gnu)
  find_library(FFTW3 NAMES libfftw3.so.3 PATHS /usr/lib/x86_64-linux-gnu /usr/lib/i386-linux-gnu)

  if (NOT IFOPT)

    message(FATAL_ERROR "This program requires the ifopt library, and will not be compiled.")

  elseif (NOT GMP)

    message(FATAL_ERROR "This program requires the gmp library, and will not be compiled.")

  elseif (NOT MPSOLVE)

    message(FATAL_ERROR "This program requires the mpsolve library, and will not be compiled.")

  elseif (NOT FFTW3)

    message(FATAL_ERROR "This program requires the fftw3 library, and will not be compiled.")

  else()
    message(STATUS "Library ifopt found: ${IFOPT}")
    message(STATUS "Library gmp found: ${GMP}")
    message(STATUS "Library mpsolve found: ${MPSOLVE}")
    message(STATUS "Library fftw3 found:" ${FFTW3})

  endif(NOT IFOPT)

endif(DISABLE_NLP_ORACLES)

option(DISABLE_NLP_ORACLES "Disable non-linear oracles (used in collocation)" ON)

if(DISABLE_NLP_ORACLES)
  add_definitions(-DDISABLE_NLP_ORACLES)
else()
  find_library(IFOPT NAMES libifopt_core.so PATHS /usr/local/lib)
  find_library(IFOPT_IPOPT NAMES libifopt_ipopt.so PATHS /usr/local/lib)
  find_library(GMP NAMES libgmp.so PATHS /usr/lib/x86_64-linux-gnu /usr/lib/i386-linux-gnu)
  find_library(MPSOLVE NAMES libmps.so PATHS /usr/local/lib)
  find_library(PTHREAD NAMES libpthread.so PATHS /usr/lib/x86_64-linux-gnu /usr/lib/i386-linux-gnu)
  find_library(FFTW3 NAMES libfftw3.so.3 PATHS /usr/lib/x86_64-linux-gnu /usr/lib/i386-linux-gnu)

  if (NOT IFOPT)

    message(FATAL_ERROR "This program requires the ifopt library, and will not be compiled.")

  elseif (NOT GMP)

    message(FATAL_ERROR "This program requires the gmp library, and will not be compiled.")

  elseif (NOT MPSOLVE)

    message(FATAL_ERROR "This program requires the mpsolve library, and will not be compiled.")

  elseif (NOT FFTW3)

    message(FATAL_ERROR "This program requires the fftw3 library, and will not be compiled.")

  else()
    message(STATUS "Library ifopt found: ${IFOPT}")
    message(STATUS "Library gmp found: ${GMP}")
    message(STATUS "Library mpsolve found: ${MPSOLVE}")
    message(STATUS "Library fftw3 found:" ${FFTW3})

  endif(NOT IFOPT)

endif(DISABLE_NLP_ORACLES)

if(COMMAND cmake_policy)
       cmake_policy(SET CMP0003 NEW)
endif(COMMAND cmake_policy)

include("../external/cmake-files/Eigen.cmake")
GetEigen()

include("../external/cmake-files/Boost.cmake")
GetBoost()

include("../external/cmake-files/LPSolve.cmake")
GetLPSolve()

# Code Coverage Configuration
add_library(coverage_config INTERFACE)

option(CODE_COVERAGE "Enable coverage reporting" OFF)
if(CODE_COVERAGE AND CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
  # Add required flags (GCC & LLVM/Clang)
  target_compile_options(coverage_config INTERFACE
    -O1        # O0 (or no) optimization takes too much time and causes CircleCI test failure.
    -g         # generate debug info
    --coverage # sets all required flags
  )
  if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.13)
    target_link_options(coverage_config INTERFACE --coverage)
  else()
    target_link_libraries(coverage_config INTERFACE --coverage)
  endif()
endif(CODE_COVERAGE AND CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")

find_library(LP_SOLVE NAMES liblpsolve55.so liblpsolve55.dylib PATHS /usr/lib/lp_solve /usr/local/lib)

if (NOT LP_SOLVE)

  message(FATAL_ERROR "This program requires the lp_solve library, and will not be compiled.")

else ()

  message(STATUS "Library lp_solve found: ${LP_SOLVE}")
  set(CMAKE_EXPORT_COMPILE_COMMANDS "ON")

  if (USE_MKL)
    find_library(BLAS NAMES libblas.so libblas.dylib PATHS /usr/local/Cellar/lapack/3.9.1_1/lib /usr/lib/x86_64-linux-gnu /usr/lib/i386-linux-gnu /usr/local/Cellar/openblas/0.3.15_1/lib /usr/lib)
    find_library(GFORTRAN NAME libgfortran.dylib PATHS /usr/local/Cellar/gcc/10.2.0_4/lib/gcc/10)
    find_library(LAPACK NAME liblapack.dylib PATHS /usr/lib)
    find_library(OPENMP NAME libiomp5.dylib PATHS /opt/intel/oneapi/compiler/2021.1.1/mac/compiler/lib)

    include_directories (BEFORE ${MKLROOT}/include)
    set(PROJECT_LIBS ${BLAS_LIBRARIES} ${LAPACK_LIBRARIES} ${GFORTRAN_LIBRARIES})
    set(MKL_LINK "-L${MKLROOT}/lib -Wl,-rpath,${MKLROOT}/lib -lmkl_intel_ilp64 -lmkl_sequential -lmkl_core -lpthread -lm -ldl")
    add_definitions(-DEIGEN_USE_MKL_ALL)
  else()
    set(MKL_LINK "")
  endif(USE_MKL)

  include_directories (BEFORE ../external)
  include_directories (BEFORE ../external/minimum_ellipsoid)
  include_directories (BEFORE ../include/generators)
  include_directories (BEFORE ../include/volume)
  include_directories (BEFORE ../include)
  include_directories (BEFORE ../include/integration)
  include_directories (BEFORE ../include/convex_bodies)
  include_directories (BEFORE ../include/convex_bodies/spectrahedra)
  include_directories (BEFORE ../include/annealing)
  include_directories (BEFORE ../include/ode_solvers)
  include_directories (BEFORE ../include/root_finders)
  include_directories (BEFORE ../include/samplers)
  include_directories (BEFORE ../include/lp_oracles)
  include_directories (BEFORE ../include/nlp_oracles)
  include_directories (BEFORE ../include/misc)
  include_directories (BEFORE ../test)

  #for Eigen
  if (${CMAKE_VERSION} VERSION_LESS "3.12.0")
    add_compile_options(-D "EIGEN_NO_DEBUG")
  else ()
    add_compile_definitions("EIGEN_NO_DEBUG")
  endif ()

  add_definitions(${CMAKE_CXX_FLAGS} "-std=c++11")  # enable C++11 standard
  add_definitions(${CMAKE_CXX_FLAGS} "-g")  # enable debuger
  #add_definitions(${CMAKE_CXX_FLAGS} "-Wint-in-bool-context")
  #add_definitions(${CMAKE_CXX_FLAGS} "-Wall")

  add_definitions(${CMAKE_CXX_FLAGS} "-O3")  # optimization of the compiler
  #add_definitions(${CXX_COVERAGE_COMPILE_FLAGS} "-lgsl")
  add_definitions(${CXX_COVERAGE_COMPILE_FLAGS} "-lm")
  add_definitions(${CXX_COVERAGE_COMPILE_FLAGS} "-ldl")
  add_definitions(${CXX_COVERAGE_COMPILE_FLAGS} "-DBOOST_NO_AUTO_PTR")
  #add_definitions(${CXX_COVERAGE_COMPILE_FLAGS} "-lgslcblas")
  #add_definitions( "-O3 -lgsl -lm -ldl -lgslcblas" )

  add_executable (new_volume_example new_volume_example.cpp)
  add_executable (benchmarks_sob benchmarks_sob.cpp)
  add_executable (benchmarks_cg benchmarks_cg.cpp)
  add_executable (benchmarks_cb benchmarks_cb.cpp)

  add_library(test_main OBJECT test_main.cpp)

  add_executable (mcmc_diagnostics_test mcmc_diagnostics_test.cpp $<TARGET_OBJECTS:test_main>)
  add_test(NAME test_psrf COMMAND mcmc_diagnostics_test -tc=psrf)
  add_test(NAME test_univariate_psrf COMMAND mcmc_diagnostics_test -tc=univariate_psrf)
  add_test(NAME test_interval_psrf COMMAND mcmc_diagnostics_test -tc=interval_psrf)
  add_test(NAME test_ess COMMAND mcmc_diagnostics_test -tc=ess)
  add_test(NAME test_geweke COMMAND mcmc_diagnostics_test -tc=geweke)
  add_test(NAME test_raftery COMMAND mcmc_diagnostics_test -tc=raftery)
  
  add_executable (sampling_test sampling_test.cpp $<TARGET_OBJECTS:test_main>)
  add_test(NAME test_dikin COMMAND sampling_test -tc=dikin)
  add_test(NAME test_john COMMAND sampling_test -tc=john)
  add_test(NAME test_vaidya COMMAND sampling_test -tc=vaidya)
  add_test(NAME test_brdhr COMMAND sampling_test -tc=brdhr)
  add_test(NAME test_bcdhr COMMAND sampling_test -tc=bcdhr)
  add_test(NAME test_grdhr COMMAND sampling_test -tc=grdhr)
  add_test(NAME test_gbaw COMMAND sampling_test -tc=gbaw)
  add_test(NAME test_ghmc COMMAND sampling_test -tc=ghmc)
  
  add_executable (mmcs_test mmcs_test.cpp $<TARGET_OBJECTS:test_main>)
  add_test(NAME test_mmcs COMMAND mmcs_test -tc=mmcs)

  add_executable (ode_solvers_test ode_solvers_test.cpp $<TARGET_OBJECTS:test_main>)
  add_test(NAME ode_solvers_test_first_order
          COMMAND ode_solvers_test -tc=first_order)
  add_test(NAME ode_solvers_test_second_order
          COMMAND ode_solvers_test -tc=second_order)

  add_executable (root_finders_test root_finders_test.cpp $<TARGET_OBJECTS:test_main>)
  add_test(NAME root_finders_test_root_finders
          COMMAND root_finders_test -tc=root_finders)

  add_executable (boundary_oracles_test boundary_oracles_test.cpp $<TARGET_OBJECTS:test_main>)
  add_test(NAME boundary_oracles_test_h_poly_oracles
    COMMAND boundary_oracles_test -tc=h_poly_oracles)

  add_executable (volume_sob_hpolytope volume_sob_hpolytope.cpp $<TARGET_OBJECTS:test_main>)
  add_test(NAME volume_sob_hpolytope_cube COMMAND volume_sob_hpolytope -tc=cube)
  add_test(NAME volume_sob_hpolytope_cross COMMAND volume_sob_hpolytope -tc=cross)
  add_test(NAME volume_sob_hpolytope_birkhoff COMMAND volume_sob_hpolytope -tc=birk)
  add_test(NAME volume_sob_hpolytope_prod_simplex COMMAND volume_sob_hpolytope -tc=prod_simplex)
  add_test(NAME volume_sob_hpolytope_simplex COMMAND volume_sob_hpolytope -tc=simplex)
  add_test(NAME volume_sob_hpolytope_skinny_cube COMMAND volume_sob_hpolytope -tc=skinny_cube)
  add_test(NAME volume_sob_hpolytope_cube_overflow COMMAND volume_sob_hpolytope -tc=cube_overflow)
  set_property(TEST volume_sob_hpolytope_cube_overflow PROPERTY TIMEOUT 1)

  add_executable (volume_sob_vpolytope volume_sob_vpolytope.cpp $<TARGET_OBJECTS:test_main>)
  add_test(NAME volume_sob_vpolytope_cube COMMAND volume_sob_vpolytope -tc=cube)
  add_test(NAME volume_sob_vpolytope_cross COMMAND volume_sob_vpolytope -tc=cross)
  add_test(NAME volume_sob_vpolytope_simplex COMMAND volume_sob_vpolytope -tc=simplex)

  add_executable (volume_cg_hpolytope volume_cg_hpolytope.cpp $<TARGET_OBJECTS:test_main>)
  add_test(NAME volume_cg_hpolytope_cube COMMAND volume_cg_hpolytope -tc=cube)
  add_test(NAME volume_cg_hpolytope_cross COMMAND volume_cg_hpolytope -tc=cross)
  add_test(NAME volume_cg_hpolytope_birkhoff COMMAND volume_cg_hpolytope -tc=birk)
  add_test(NAME volume_cg_hpolytope_prod_simplex COMMAND volume_cg_hpolytope -tc=prod_simplex)
  add_test(NAME volume_cg_hpolytope_simplex COMMAND volume_cg_hpolytope -tc=simplex)
  add_test(NAME volume_cg_hpolytope_skinny_cube COMMAND volume_cg_hpolytope -tc=skinny_cube)

  add_executable (volume_cg_vpolytope volume_cg_vpolytope.cpp $<TARGET_OBJECTS:test_main>)
  add_test(NAME volume_cg_vpolytope_cube COMMAND volume_cg_vpolytope -tc=cube)
  add_test(NAME volume_cg_vpolytope_cross COMMAND volume_cg_vpolytope -tc=cross)
  add_test(NAME volume_cg_vpolytope_simplex COMMAND volume_cg_vpolytope -tc=simplex)

  add_executable (volume_cb_hpolytope volume_cb_hpolytope.cpp $<TARGET_OBJECTS:test_main>)
  add_test(NAME volume_cb_hpolytope_cube COMMAND volume_cb_hpolytope -tc=cube)
  add_test(NAME volume_cb_hpolytope_cross COMMAND volume_cb_hpolytope -tc=cross)
  add_test(NAME volume_cb_hpolytope_birkhoff COMMAND volume_cb_hpolytope -tc=birk)
  add_test(NAME volume_cb_hpolytope_prod_simplex COMMAND volume_cb_hpolytope -tc=prod_simplex)
  add_test(NAME volume_cb_hpolytope_simplex COMMAND volume_cb_hpolytope -tc=simplex)
  add_test(NAME volume_cb_hpolytope_skinny_cube COMMAND volume_cb_hpolytope -tc=skinny_cube)

  add_executable (volume_cb_vpolytope volume_cb_vpolytope.cpp $<TARGET_OBJECTS:test_main>)
  add_test(NAME volume_cb_vpolytope_cube COMMAND volume_cb_vpolytope -tc=cube)
  add_test(NAME volume_cb_vpolytope_cross COMMAND volume_cb_vpolytope -tc=cross)
  add_test(NAME volume_cb_vpolytope_simplex COMMAND volume_cb_vpolytope -tc=simplex)

  add_executable (volume_cb_zonotopes volume_cb_zonotopes.cpp $<TARGET_OBJECTS:test_main>)
  add_test(NAME volume_cb_zonotopes_uniform_zonotopes
           COMMAND volume_cb_zonotopes -tc=uniform_zonotopes)

  add_executable (volume_cb_vpoly_intersection_vpoly volume_cb_vpoly_intersection_vpoly.cpp $<TARGET_OBJECTS:test_main>)
  add_test(NAME volume_cb_vpoly_intersection_vpoly_random_vpoly_sphere
           COMMAND volume_cb_vpoly_intersection_vpoly -tc=random_vpoly_sphere)

  add_executable (new_rounding_test new_rounding_test.cpp $<TARGET_OBJECTS:test_main>)
  add_test(NAME test_round_min_ellipsoid
           COMMAND new_rounding_test -tc=round_min_ellipsoid)
  add_test(NAME test_round_max_ellipsoid
           COMMAND new_rounding_test -tc=round_max_ellipsoid)
  add_test(NAME test_round_svd
           COMMAND new_rounding_test -tc=round_svd)

  add_executable (logconcave_sampling_test logconcave_sampling_test.cpp $<TARGET_OBJECTS:test_main>)
  add_test(NAME logconcave_sampling_test_hmc
          COMMAND logconcave_sampling_test -tc=hmc)
  add_test(NAME logconcave_sampling_test_uld
          COMMAND logconcave_sampling_test -tc=uld)
  add_test(NAME logconcave_sampling_test_exponential_biomass_sampling
          COMMAND logconcave_sampling_test -tc=exponential_biomass_sampling)

  add_executable (simple_mc_integration simple_mc_integration.cpp $<TARGET_OBJECTS:test_main>)
  add_test(NAME simple_mc_integration_over_limits
          COMMAND simple_mc_integration -tc=rectangle)
  add_test(NAME simple_mc_integration_over_cubes
          COMMAND simple_mc_integration -tc=cube)
  add_test(NAME simple_mc_integration_over_simplices
          COMMAND simple_mc_integration -tc=simplex)
  add_test(NAME simple_mc_integration_over_product_simplices
		  COMMAND simple_mc_integration -tc=prod_simplex)
  add_test(NAME simple_mc_integration_over_cross_polytopes
		  COMMAND simple_mc_integration -tc=cross)
  add_test(NAME simple_mc_integration_over_birkhoff_polytopes
		  COMMAND simple_mc_integration -tc=birkhoff)

  add_executable (order_polytope order_polytope.cpp $<TARGET_OBJECTS:test_main>)
  add_test(NAME order_polytope_basics COMMAND order_polytope -tc=basics)
  add_test(NAME order_polytope_line_intersect COMMAND order_polytope -tc=line_intersect)
  add_test(NAME order_polytope_reflection COMMAND order_polytope -tc=reflection)
  add_test(NAME order_polytope_vec_mult COMMAND order_polytope -tc=vec_mult)

  TARGET_LINK_LIBRARIES(new_volume_example ${LP_SOLVE} ${MKL_LINK} coverage_config)
  TARGET_LINK_LIBRARIES(new_volume_example ${LP_SOLVE} coverage_config)
  TARGET_LINK_LIBRARIES(volume_sob_hpolytope ${LP_SOLVE} coverage_config)
  TARGET_LINK_LIBRARIES(volume_sob_vpolytope ${LP_SOLVE} coverage_config)
  TARGET_LINK_LIBRARIES(volume_cg_hpolytope ${LP_SOLVE} coverage_config)
  TARGET_LINK_LIBRARIES(volume_cg_vpolytope ${LP_SOLVE} coverage_config)
  TARGET_LINK_LIBRARIES(volume_cb_hpolytope ${LP_SOLVE} coverage_config)
  TARGET_LINK_LIBRARIES(volume_cb_vpolytope ${LP_SOLVE} coverage_config)
  TARGET_LINK_LIBRARIES(volume_cb_zonotopes ${LP_SOLVE} coverage_config)
  TARGET_LINK_LIBRARIES(volume_cb_vpoly_intersection_vpoly ${LP_SOLVE} coverage_config)
  TARGET_LINK_LIBRARIES(volume_cb_vpoly_intersection_vpoly ${LP_SOLVE} ${MKL_LINK} coverage_config)
  TARGET_LINK_LIBRARIES(new_rounding_test ${LP_SOLVE} ${MKL_LINK} coverage_config)
  TARGET_LINK_LIBRARIES(mcmc_diagnostics_test ${LP_SOLVE} ${MKL_LINK} coverage_config)
  TARGET_LINK_LIBRARIES(sampling_test ${LP_SOLVE} ${MKL_LINK} coverage_config)
  TARGET_LINK_LIBRARIES(mmcs_test ${LP_SOLVE} ${MKL_LINK} coverage_config)
  TARGET_LINK_LIBRARIES(benchmarks_sob ${LP_SOLVE} ${MKL_LINK} coverage_config)
  TARGET_LINK_LIBRARIES(benchmarks_cg ${LP_SOLVE} ${MKL_LINK} coverage_config)
  TARGET_LINK_LIBRARIES(benchmarks_cb ${LP_SOLVE} ${MKL_LINK} coverage_config)
  TARGET_LINK_LIBRARIES(simple_mc_integration ${LP_SOLVE} ${MKL_LINK} coverage_config)
  TARGET_LINK_LIBRARIES(ode_solvers_test ${LP_SOLVE} ${IFOPT} ${IFOPT_IPOPT} ${PTHREAD} ${GMP} ${MPSOLVE} ${FFTW3} ${MKL_LINK} coverage_config)
  TARGET_LINK_LIBRARIES(boundary_oracles_test ${LP_SOLVE} ${IFOPT} ${IFOPT_IPOPT} ${PTHREAD} ${GMP} ${MPSOLVE} ${FFTW3} ${MKL_LINK} coverage_config)
  TARGET_LINK_LIBRARIES(root_finders_test ${PTHREAD} ${GMP} ${MPSOLVE} ${FFTW3} ${MKL_LINK} coverage_config)
  TARGET_LINK_LIBRARIES(logconcave_sampling_test ${LP_SOLVE} ${IFOPT} ${IFOPT_IPOPT} ${PTHREAD} ${GMP} ${MPSOLVE} ${FFTW3} ${MKL_LINK} coverage_config)
  TARGET_LINK_LIBRARIES(order_polytope ${LP_SOLVE} coverage_config)


endif()
