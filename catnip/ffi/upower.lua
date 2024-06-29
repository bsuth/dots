local ffi = require("ffi")

-- https://upower.freedesktop.org/docs/UPower-up-types.html#UpDeviceState
-- /usr/include/libupower-glib/up-types.h

ffi.cdef([[
typedef enum {
	UP_DEVICE_STATE_UNKNOWN,
	UP_DEVICE_STATE_CHARGING,
	UP_DEVICE_STATE_DISCHARGING,
	UP_DEVICE_STATE_EMPTY,
	UP_DEVICE_STATE_FULLY_CHARGED,
	UP_DEVICE_STATE_PENDING_CHARGE,
	UP_DEVICE_STATE_PENDING_DISCHARGE,
	UP_DEVICE_STATE_LAST
} UpDeviceState;
]])

return ffi.load("libupower-glib.so");
