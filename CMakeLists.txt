cmake_minimum_required(VERSION 3.16)
cmake_policy(SET CMP0076 NEW)
cmake_policy(SET CMP0091 NEW)

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

set(CRASHPAD_SPECIAL_TARGET "" CACHE STRING "Use special platform target, like 'macstore' for Mac App Store.")

set(CMAKE_OSX_DEPLOYMENT_TARGET 10.13 CACHE STRING "Minimum OS X deployment version" FORCE)

if (NOT CRASHPAD_SPECIAL_TARGET STREQUAL "")
    set(CRASHPAD_PACKAGED_BUILD 0)
else()
    set(CRASHPAD_PACKAGED_BUILD 1)
endif()

set(not_packaged_build 0)
if (NOT CRASHPAD_PACKAGED_BUILD)
    set(not_packaged_build 1)
endif()

option(BUILD_SHARED_LIBS "Builds shared libraries instead of static." ${CRASHPAD_PACKAGED_BUILD})

if (BUILD_SHARED_LIBS)
    set(CMAKE_POSITION_INDEPENDENT_CODE ON)
endif()

project(crashpad
    LANGUAGES C CXX
    DESCRIPTION "Crashpad build for Desktop App Toolkit"
    HOMEPAGE_URL "https://github.com/desktop-app/crashpad.git"
)
set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT crashpad_handler)

get_filename_component(crashpad_loc "." REALPATH)

if (CMAKE_OSX_ARCHITECTURES STREQUAL "arm64")
    set(is_aarch64 1)
    set(arm_use_neon 1)
else()
    if (CMAKE_OSX_ARCHITECTURES STREQUAL "x86_64")
        set(is_x64 1)
    else()
        include(cmake/arch.cmake)
    endif()
endif()

include(cmake/target_link_frameworks.cmake)
include(cmake/target_link_options_if_exists.cmake)
include(cmake/nice_target_sources.cmake)
include(cmake/init_target.cmake)
include(cmake/external.cmake)

add_library(mini_chromium_base OBJECT)
init_target(mini_chromium_base)

set(mini_chromium_loc ${crashpad_loc}/third_party/mini_chromium)

nice_target_sources(mini_chromium_base ${mini_chromium_loc}
PRIVATE
    base/atomicops.h
    base/atomicops_internals_atomicword_compat.h
    base/atomicops_internals_portable.h
    base/auto_reset.h
    base/bit_cast.h
    base/check.h
    base/check_op.h
    base/compiler_specific.h
    base/cxx17_backports.h
    base/debug/alias.cc
    base/debug/alias.h
    base/files/file_path.cc
    base/files/file_path.h
    base/files/file_util.h
    base/files/scoped_file.cc
    base/files/scoped_file.h
    base/format_macros.h
    base/logging.cc
    base/logging.h
    base/macros.h
    base/memory/free_deleter.h
    base/memory/page_size.h
    base/memory/scoped_policy.h
    base/metrics/histogram_functions.h
    base/metrics/histogram_macros.h
    base/metrics/persistent_histogram_allocator.h
    base/notreached.h
    base/numerics/checked_math.h
    base/numerics/checked_math_impl.h
    base/numerics/clamped_math.h
    base/numerics/clamped_math_impl.h
    base/numerics/safe_conversions.h
    base/numerics/safe_conversions_arm_impl.h
    base/numerics/safe_conversions_impl.h
    base/numerics/safe_math.h
    base/numerics/safe_math_arm_impl.h
    base/numerics/safe_math_clang_gcc_impl.h
    base/numerics/safe_math_shared_impl.h
    base/process/memory.cc
    base/process/memory.h
    base/rand_util.cc
    base/rand_util.h
    base/scoped_clear_last_error.h
    base/scoped_generic.h
    base/strings/string_number_conversions.cc
    base/strings/string_number_conversions.h
    base/strings/string_piece.h
    base/strings/string_util.h
    base/strings/stringprintf.cc
    base/strings/stringprintf.h
    base/strings/sys_string_conversions.h
    base/strings/utf_string_conversion_utils.cc
    base/strings/utf_string_conversion_utils.h
    base/strings/utf_string_conversions.cc
    base/strings/utf_string_conversions.h
    base/synchronization/condition_variable.h
    base/synchronization/lock.cc
    base/synchronization/lock.h
    base/synchronization/lock_impl.h
    base/sys_byteorder.h
    base/template_util.h
    base/third_party/icu/icu_utf.cc
    base/third_party/icu/icu_utf.h
    base/threading/thread_local_storage.cc
    base/threading/thread_local_storage.h

    # posix
    base/files/file_util_posix.cc
    base/memory/page_size_posix.cc
    base/posix/eintr_wrapper.h
    base/posix/safe_strerror.cc
    base/posix/safe_strerror.h
    base/strings/string_util_posix.h
    base/synchronization/condition_variable_posix.cc
    base/synchronization/lock_impl_posix.cc
    base/threading/thread_local_storage_posix.cc

    # mac
    base/mac/close_nocancel.cc
    base/mac/foundation_util.h
    base/mac/foundation_util.mm
    base/mac/mach_logging.cc
    base/mac/mach_logging.h
    base/mac/scoped_cftyperef.h
    base/mac/scoped_ioobject.h
    base/mac/scoped_launch_data.h
    base/mac/scoped_mach_port.cc
    base/mac/scoped_mach_port.h
    base/mac/scoped_mach_vm.cc
    base/mac/scoped_mach_vm.h
    base/mac/scoped_nsautorelease_pool.h
    base/mac/scoped_nsautorelease_pool.mm
    base/mac/scoped_nsobject.h
    base/mac/scoped_typeref.h
    base/strings/sys_string_conversions_mac.mm
)

target_include_directories(mini_chromium_base
PUBLIC
    ${mini_chromium_loc}
)

add_library(crashpad_util OBJECT)
init_target(crashpad_util)

nice_target_sources(crashpad_util ${crashpad_loc}
PRIVATE
    util/file/delimited_file_reader.cc
    util/file/delimited_file_reader.h
    util/file/directory_reader.h
    util/file/file_helper.cc
    util/file/file_helper.h
    util/file/file_io.cc
    util/file/file_io.h
    util/file/file_reader.cc
    util/file/file_reader.h
    util/file/file_seeker.cc
    util/file/file_seeker.h
    util/file/file_writer.cc
    util/file/file_writer.h
    util/file/filesystem.h
    util/file/output_stream_file_writer.cc
    util/file/output_stream_file_writer.h
    util/file/scoped_remove_file.cc
    util/file/scoped_remove_file.h
    util/file/string_file.cc
    util/file/string_file.h
    util/misc/address_sanitizer.h
    util/misc/address_types.h
    util/misc/arraysize.h
    util/misc/as_underlying_type.h
    util/misc/capture_context.h
    util/misc/clock.h
    util/misc/elf_note_types.h
    util/misc/from_pointer_cast.h
    util/misc/implicit_cast.h
    util/misc/initialization_state.h
    util/misc/initialization_state_dcheck.cc
    util/misc/initialization_state_dcheck.h
    util/misc/lexing.cc
    util/misc/lexing.h
    util/misc/memory_sanitizer.h
    util/misc/metrics.cc
    util/misc/metrics.h
    util/misc/paths.h
    util/misc/pdb_structures.cc
    util/misc/pdb_structures.h
    util/misc/random_string.cc
    util/misc/random_string.h
    util/misc/range_set.cc
    util/misc/range_set.h
    util/misc/reinterpret_bytes.cc
    util/misc/reinterpret_bytes.h
    util/misc/scoped_forbid_return.cc
    util/misc/scoped_forbid_return.h
    util/misc/symbolic_constants_common.h
    util/misc/time.cc
    util/misc/time.h
    util/misc/tri_state.h
    util/misc/uuid.cc
    util/misc/uuid.h
    util/misc/zlib.cc
    util/misc/zlib.h
    util/net/http_body.cc
    util/net/http_body.h
    util/net/http_body_gzip.cc
    util/net/http_body_gzip.h
    util/net/http_headers.h
    util/net/http_multipart_builder.cc
    util/net/http_multipart_builder.h
    util/net/http_transport.cc
    util/net/http_transport.h
    util/net/url.cc
    util/net/url.h
    util/numeric/checked_address_range.cc
    util/numeric/checked_address_range.h
    util/numeric/checked_range.h
    util/numeric/checked_vm_address_range.h
    util/numeric/in_range_cast.h
    util/numeric/int128.h
    util/numeric/safe_assignment.h
    util/process/process_id.h
    util/process/process_memory.cc
    util/process/process_memory.h
    util/process/process_memory_native.h
    util/process/process_memory_range.cc
    util/process/process_memory_range.h
    util/stdlib/aligned_allocator.cc
    util/stdlib/aligned_allocator.h
    util/stdlib/map_insert.h
    util/stdlib/objc.h
    util/stdlib/string_number_conversion.cc
    util/stdlib/string_number_conversion.h
    util/stdlib/strlcpy.cc
    util/stdlib/strlcpy.h
    util/stdlib/strnlen.cc
    util/stdlib/strnlen.h
    util/stdlib/thread_safe_vector.h
    util/stream/base94_output_stream.cc
    util/stream/base94_output_stream.h
    util/stream/file_encoder.cc
    util/stream/file_encoder.h
    util/stream/file_output_stream.cc
    util/stream/file_output_stream.h
    util/stream/log_output_stream.cc
    util/stream/log_output_stream.h
    util/stream/output_stream_interface.h
    util/stream/zlib_output_stream.cc
    util/stream/zlib_output_stream.h
    util/string/split_string.cc
    util/string/split_string.h
    util/synchronization/semaphore.h
    util/thread/stoppable.h
    util/thread/thread.cc
    util/thread/thread.h
    util/thread/thread_log_messages.cc
    util/thread/thread_log_messages.h
    util/thread/worker_thread.cc
    util/thread/worker_thread.h

    # posix
    util/file/directory_reader_posix.cc
    util/file/file_io_posix.cc
    util/file/filesystem_posix.cc
    util/misc/clock_posix.cc
    util/posix/close_stdio.cc
    util/posix/close_stdio.h
    util/posix/scoped_dir.cc
    util/posix/scoped_dir.h
    util/posix/scoped_mmap.cc
    util/posix/scoped_mmap.h
    util/posix/signals.cc
    util/posix/signals.h
    util/synchronization/semaphore_posix.cc
    util/thread/thread_posix.cc
    util/posix/close_multiple.cc
    util/posix/close_multiple.h
    util/posix/double_fork_and_exec.cc
    util/posix/double_fork_and_exec.h
    util/posix/drop_privileges.cc
    util/posix/drop_privileges.h
    util/posix/process_info.h
    util/posix/symbolic_constants_posix.cc
    util/posix/symbolic_constants_posix.h

    # mac
    util/mac/xattr.cc
    util/mac/xattr.h
    util/mach/composite_mach_message_server.cc
    util/mach/composite_mach_message_server.h
    util/mach/exc_client_variants.cc
    util/mach/exc_client_variants.h
    util/mach/exc_server_variants.cc
    util/mach/exc_server_variants.h
    util/mach/exception_behaviors.cc
    util/mach/exception_behaviors.h
    util/mach/exception_ports.cc
    util/mach/exception_ports.h
    util/mach/mach_extensions.cc
    util/mach/mach_extensions.h
    util/mach/mach_message.cc
    util/mach/mach_message.h
    util/mach/mach_message_server.cc
    util/mach/mach_message_server.h
    util/mach/symbolic_constants_mach.cc
    util/mach/symbolic_constants_mach.h
    util/misc/capture_context_mac.S
    util/misc/clock_mac.cc
    util/misc/paths_mac.cc
    util/synchronization/semaphore_mac.cc
    util/mac/checked_mach_address_range.h
    util/mac/launchd.h
    util/mac/launchd.mm
    util/mac/mac_util.cc
    util/mac/mac_util.h
    util/mac/service_management.cc
    util/mac/service_management.h
    util/mac/sysctl.cc
    util/mac/sysctl.h
    util/mach/bootstrap.cc
    util/mach/bootstrap.h
    util/mach/child_port_handshake.cc
    util/mach/child_port_handshake.h
    util/mach/child_port_server.cc
    util/mach/child_port_server.h
    util/mach/child_port_types.h
    util/mach/exception_types.cc
    util/mach/exception_types.h
    util/mach/notify_server.cc
    util/mach/notify_server.h
    util/mach/scoped_task_suspend.cc
    util/mach/scoped_task_suspend.h
    util/mach/task_for_pid.cc
    util/mach/task_for_pid.h
    util/net/http_transport_mac.mm
    util/posix/process_info_mac.cc
    util/process/process_memory_mac.cc
    util/process/process_memory_mac.h

    gen/util/mach/child_port.h
    gen/util/mach/child_portServer.c
    gen/util/mach/child_portServer.h
    gen/util/mach/child_portUser.c
    gen/util/mach/exc.h
    gen/util/mach/excServer.c
    gen/util/mach/excServer.h
    gen/util/mach/excUser.c
    gen/util/mach/mach_exc.h
    gen/util/mach/mach_excServer.c
    gen/util/mach/mach_excServer.h
    gen/util/mach/mach_excUser.c
    gen/util/mach/notify.h
    gen/util/mach/notifyServer.c
    gen/util/mach/notifyServer.h
    gen/util/mach/notifyUser.c
)

target_compile_definitions(crashpad_util
PRIVATE
    CRASHPAD_ZLIB_SOURCE_EXTERNAL
)

link_zlib(crashpad_util)

target_include_directories(crashpad_util
PUBLIC
    ${crashpad_loc}
    ${crashpad_loc}/gen
)

if (NOT WIN32)
    target_include_directories(crashpad_util
    PUBLIC
        ${crashpad_loc}/compat/non_win
    )
endif()

target_link_libraries(crashpad_util
PUBLIC
    mini_chromium_base
)

add_library(crashpad_minidump OBJECT)
init_target(crashpad_minidump)

nice_target_sources(crashpad_minidump ${crashpad_loc}
PRIVATE
    minidump/minidump_annotation_writer.cc
    minidump/minidump_annotation_writer.h
    minidump/minidump_byte_array_writer.cc
    minidump/minidump_byte_array_writer.h
    minidump/minidump_context_writer.cc
    minidump/minidump_context_writer.h
    minidump/minidump_crashpad_info_writer.cc
    minidump/minidump_crashpad_info_writer.h
    minidump/minidump_exception_writer.cc
    minidump/minidump_exception_writer.h
    minidump/minidump_file_writer.cc
    minidump/minidump_file_writer.h
    minidump/minidump_handle_writer.cc
    minidump/minidump_handle_writer.h
    minidump/minidump_memory_info_writer.cc
    minidump/minidump_memory_info_writer.h
    minidump/minidump_memory_writer.cc
    minidump/minidump_memory_writer.h
    minidump/minidump_misc_info_writer.cc
    minidump/minidump_misc_info_writer.h
    minidump/minidump_module_crashpad_info_writer.cc
    minidump/minidump_module_crashpad_info_writer.h
    minidump/minidump_module_writer.cc
    minidump/minidump_module_writer.h
    minidump/minidump_rva_list_writer.cc
    minidump/minidump_rva_list_writer.h
    minidump/minidump_simple_string_dictionary_writer.cc
    minidump/minidump_simple_string_dictionary_writer.h
    minidump/minidump_stream_writer.cc
    minidump/minidump_stream_writer.h
    minidump/minidump_string_writer.cc
    minidump/minidump_string_writer.h
    minidump/minidump_system_info_writer.cc
    minidump/minidump_system_info_writer.h
    minidump/minidump_thread_id_map.cc
    minidump/minidump_thread_id_map.h
    minidump/minidump_thread_writer.cc
    minidump/minidump_thread_writer.h
    minidump/minidump_unloaded_module_writer.cc
    minidump/minidump_unloaded_module_writer.h
    minidump/minidump_user_extension_stream_data_source.cc
    minidump/minidump_user_extension_stream_data_source.h
    minidump/minidump_user_stream_writer.cc
    minidump/minidump_user_stream_writer.h
    minidump/minidump_writable.cc
    minidump/minidump_writable.h
    minidump/minidump_writer_util.cc
    minidump/minidump_writer_util.h
)

target_link_libraries(crashpad_minidump
PUBLIC
    crashpad_util
)

add_library(crashpad_tools OBJECT)
init_target(crashpad_tools)

nice_target_sources(crashpad_tools ${crashpad_loc}
PRIVATE
    tools/tool_support.cc
    tools/tool_support.h
)

target_include_directories(crashpad_tools
PUBLIC
    ${crashpad_loc}
)

target_link_libraries(crashpad_tools
PUBLIC
    mini_chromium_base
)

add_library(crashpad_common OBJECT )
init_target(crashpad_common)

nice_target_sources(crashpad_common ${crashpad_loc}
PRIVATE
    client/annotation.cc
    client/annotation.h
    client/annotation_list.cc
    client/annotation_list.h
    client/crash_report_database.cc
    client/crash_report_database.h
    client/crashpad_info.cc
    client/crashpad_info.h
    client/settings.cc
    client/settings.h
    client/simple_address_range_bag.h
    client/simple_string_dictionary.h
    client/crash_report_database_mac.mm
)

target_link_libraries(crashpad_common
PUBLIC
    crashpad_util
)

add_library(crashpad_snapshot OBJECT)
init_target(crashpad_snapshot)

nice_target_sources(crashpad_snapshot ${crashpad_loc}
PRIVATE
    snapshot/annotation_snapshot.cc
    snapshot/annotation_snapshot.h
    snapshot/capture_memory.cc
    snapshot/capture_memory.h
    snapshot/crashpad_info_client_options.cc
    snapshot/crashpad_info_client_options.h
    snapshot/exception_snapshot.h
    snapshot/handle_snapshot.cc
    snapshot/handle_snapshot.h
    snapshot/memory_snapshot.cc
    snapshot/memory_snapshot.h
    snapshot/memory_snapshot_generic.h
    snapshot/minidump/exception_snapshot_minidump.cc
    snapshot/minidump/exception_snapshot_minidump.h
    snapshot/minidump/memory_snapshot_minidump.cc
    snapshot/minidump/memory_snapshot_minidump.h
    snapshot/minidump/minidump_annotation_reader.cc
    snapshot/minidump/minidump_annotation_reader.h
    snapshot/minidump/minidump_context_converter.cc
    snapshot/minidump/minidump_context_converter.h
    snapshot/minidump/minidump_simple_string_dictionary_reader.cc
    snapshot/minidump/minidump_simple_string_dictionary_reader.h
    snapshot/minidump/minidump_stream.h
    snapshot/minidump/minidump_string_list_reader.cc
    snapshot/minidump/minidump_string_list_reader.h
    snapshot/minidump/minidump_string_reader.cc
    snapshot/minidump/minidump_string_reader.h
    snapshot/minidump/module_snapshot_minidump.cc
    snapshot/minidump/module_snapshot_minidump.h
    snapshot/minidump/process_snapshot_minidump.cc
    snapshot/minidump/process_snapshot_minidump.h
    snapshot/minidump/system_snapshot_minidump.cc
    snapshot/minidump/system_snapshot_minidump.h
    snapshot/minidump/thread_snapshot_minidump.cc
    snapshot/minidump/thread_snapshot_minidump.h
    snapshot/module_snapshot.h
    snapshot/process_snapshot.h
    snapshot/snapshot_constants.h
    snapshot/system_snapshot.h
    snapshot/thread_snapshot.h
    snapshot/unloaded_module_snapshot.cc
    snapshot/unloaded_module_snapshot.h

    # context
    snapshot/cpu_architecture.h
    snapshot/cpu_context.cc
    snapshot/cpu_context.h

    # posix
    snapshot/posix/timezone.cc
    snapshot/posix/timezone.h

    # mac
    snapshot/mac/cpu_context_mac.cc
    snapshot/mac/cpu_context_mac.h
    snapshot/mac/exception_snapshot_mac.cc
    snapshot/mac/exception_snapshot_mac.h
    snapshot/mac/mach_o_image_annotations_reader.cc
    snapshot/mac/mach_o_image_annotations_reader.h
    snapshot/mac/mach_o_image_reader.cc
    snapshot/mac/mach_o_image_reader.h
    snapshot/mac/mach_o_image_segment_reader.cc
    snapshot/mac/mach_o_image_segment_reader.h
    snapshot/mac/mach_o_image_symbol_table_reader.cc
    snapshot/mac/mach_o_image_symbol_table_reader.h
    snapshot/mac/module_snapshot_mac.cc
    snapshot/mac/module_snapshot_mac.h
    snapshot/mac/process_reader_mac.cc
    snapshot/mac/process_reader_mac.h
    snapshot/mac/process_snapshot_mac.cc
    snapshot/mac/process_snapshot_mac.h
    snapshot/mac/process_types.cc
    snapshot/mac/process_types.h
    snapshot/mac/process_types/custom.cc
    snapshot/mac/process_types/flavors.h
    snapshot/mac/process_types/internal.h
    snapshot/mac/process_types/traits.h
    snapshot/mac/system_snapshot_mac.cc
    snapshot/mac/system_snapshot_mac.h
    snapshot/mac/thread_snapshot_mac.cc
    snapshot/mac/thread_snapshot_mac.h

    # x86 or macOS universal
    snapshot/x86/cpuid_reader.cc
    snapshot/x86/cpuid_reader.h
)

target_link_libraries(crashpad_snapshot
PUBLIC
    crashpad_util
)

add_library(crashpad_client)
init_target(crashpad_client)

nice_target_sources(crashpad_client ${crashpad_loc}
PRIVATE
    client/crashpad_client.h
    client/prune_crash_reports.cc
    client/prune_crash_reports.h
    client/simulate_crash.h
    client/crashpad_client_mac.cc
    client/simulate_crash_mac.cc
    client/simulate_crash_mac.h
)

target_link_libraries(crashpad_client
PUBLIC
    crashpad_util
    mini_chromium_base
)

add_executable(crashpad_handler)
init_target(crashpad_handler)

nice_target_sources(crashpad_handler ${crashpad_loc}
PRIVATE
    handler/handler_main.cc
    handler/handler_main.h
    handler/prune_crash_reports_thread.cc
    handler/prune_crash_reports_thread.h
    handler/user_stream_data_source.cc
    handler/user_stream_data_source.h
    handler/mac/crash_report_exception_handler.cc
    handler/mac/crash_report_exception_handler.h
    handler/mac/exception_handler_server.cc
    handler/mac/exception_handler_server.h

    handler/crash_report_upload_thread.cc
    handler/crash_report_upload_thread.h
    handler/minidump_to_upload_parameters.cc
    handler/minidump_to_upload_parameters.h

    # mac
    handler/mac/file_limit_annotation.cc
    handler/mac/file_limit_annotation.h

    handler/main.cc
)

target_include_directories(crashpad_handler
PUBLIC
    ${crashpad_loc}
)

target_link_libraries(crashpad_handler
PRIVATE
    mini_chromium_base
    crashpad_util
    crashpad_tools
    crashpad_common
    crashpad_client
    crashpad_snapshot
    crashpad_minidump
    bsm
)

target_link_frameworks(crashpad_handler
PRIVATE
    ApplicationServices
    CoreFoundation
    Foundation
    IOKit
    Security
)

target_link_options_if_exists(crashpad_handler
PRIVATE
    -Wl,-ld_classic
)
