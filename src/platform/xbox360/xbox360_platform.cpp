// SPDX-FileCopyrightText: Copyright 2026 JoshX Project
// SPDX-License-Identifier: GPL-3.0-or-later

#include "platform/xbox360/xbox360_platform.h"

namespace Xbox360 {

bool Initialize() {
    return true;
}

void Shutdown() {}

const char* GetPlatformName() {
    return "Xbox 360";
}

double GetTimeSeconds() {
    return 0.0;
}

} // namespace Xbox360
