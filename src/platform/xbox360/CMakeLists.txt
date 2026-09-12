# SPDX-FileCopyrightText: Copyright 2026 JoshX Project
# SPDX-License-Identifier: GPL-3.0-or-later

add_library(xbox360_platform STATIC
    xbox360_platform.cpp
    xbox360_platform.h
)

create_target_directory_groups(xbox360_platform)

target_link_libraries(xbox360_platform PRIVATE common)
