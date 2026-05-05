if(NOT CONFIG STREQUAL "MinSizeRel")
  return()
endif()

if(NOT STRIP_TOOL OR NOT EXISTS "${TARGET_FILE}")
  return()
endif()

set(strip_args)
if(STRIP_MODE STREQUAL "debug")
  if(STRIP_STYLE STREQUAL "apple")
    list(APPEND strip_args "-S")
  else()
    list(APPEND strip_args "--strip-debug")
  endif()
elseif(STRIP_MODE STREQUAL "all")
  if(STRIP_STYLE STREQUAL "apple")
    list(APPEND strip_args "-S" "-x")
  else()
    list(APPEND strip_args "--strip-all")
  endif()
else()
  message(FATAL_ERROR "Unknown strip mode: ${STRIP_MODE}")
endif()

execute_process(
  COMMAND "${STRIP_TOOL}" ${strip_args} "${TARGET_FILE}"
  RESULT_VARIABLE strip_result
  ERROR_VARIABLE strip_error
)
if(NOT strip_result EQUAL 0)
  message(WARNING "Unable to strip ${TARGET_FILE}: ${strip_error}")
endif()

if(STRIP_MODE STREQUAL "debug" AND RANLIB_TOOL)
  execute_process(
    COMMAND "${RANLIB_TOOL}" "${TARGET_FILE}"
    RESULT_VARIABLE ranlib_result
    ERROR_VARIABLE ranlib_error
  )
  if(NOT ranlib_result EQUAL 0)
    message(WARNING "Unable to ranlib ${TARGET_FILE}: ${ranlib_error}")
  endif()
endif()
