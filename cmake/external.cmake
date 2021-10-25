# ZLib
set(CRASHPAD_ZLIB_INCLUDE_PATH "" CACHE STRING "Include path for zlib.")
set(CRASHPAD_ZLIB_LIB_PATH "" CACHE STRING "Library path for zlib.")
function(link_zlib target_name)
    if (CRASHPAD_PACKAGED_BUILD)
        find_package(ZLIB REQUIRED)
        target_link_libraries(${target_name} PRIVATE ZLIB::ZLIB)
    else()
        if (CRASHPAD_ZLIB_INCLUDE_PATH STREQUAL "")
            message(FATAL_ERROR "You should specify 'CRASHPAD_ZLIB_INCLUDE_PATH'.")
        endif()
        if (CRASHPAD_ZLIB_LIB_PATH STREQUAL "")
            message(FATAL_ERROR "You should specify 'CRASHPAD_ZLIB_LIB_PATH'.")
        endif()
        target_include_directories(${target_name}
        PRIVATE
            ${CRASHPAD_ZLIB_INCLUDE_PATH}
        )
        target_link_libraries(${target_name}
        PRIVATE
            ${CRASHPAD_ZLIB_LIB_PATH}
        )
    endif()
endfunction()
