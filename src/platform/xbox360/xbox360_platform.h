#pragma once

namespace Xbox360 {

/// Initializes the Xbox 360 platform backend.
bool Initialize();

/// Shuts down the Xbox 360 platform backend.
void Shutdown();

/// Returns the platform name.
const char* GetPlatformName();

/// Returns the current platform time in seconds.
double GetTimeSeconds();

} // namespace Xbox360
