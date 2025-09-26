import ctypes
import sys

def get_power_status():
    class SYSTEM_POWER_STATUS(ctypes.Structure):
        _fields_ = [
            ('ACLineStatus', ctypes.c_byte),
            ('BatteryFlag', ctypes.c_byte),
            ('BatteryLifePercent', ctypes.c_byte),
            ('Reserved1', ctypes.c_byte),
            ('BatteryLifeTime', ctypes.c_ulong),
            ('BatteryFullLifeTime', ctypes.c_ulong),
        ]
    status = SYSTEM_POWER_STATUS()
    if not ctypes.windll.kernel32.GetSystemPowerStatus(ctypes.byref(status)):
        raise Exception("Failed to get power status")
    return status.ACLineStatus  # 0 = offline (battery), 1 = online (AC), 255 = unknown

def get_supported_refresh_rates():
    user32 = ctypes.windll.user32
    ENUM_CURRENT_SETTINGS = -1
    i = 0
    rates = set()
    class DEVMODE(ctypes.Structure):
        _fields_ = [
            ("dmDeviceName", ctypes.c_wchar * 32),
            ("dmSpecVersion", ctypes.c_ushort),
            ("dmDriverVersion", ctypes.c_ushort),
            ("dmSize", ctypes.c_ushort),
            ("dmDriverExtra", ctypes.c_ushort),
            ("dmFields", ctypes.c_ulong),
            ("dmOrientation", ctypes.c_short),
            ("dmPaperSize", ctypes.c_short),
            ("dmPaperLength", ctypes.c_short),
            ("dmPaperWidth", ctypes.c_short),
            ("dmScale", ctypes.c_short),
            ("dmCopies", ctypes.c_short),
            ("dmDefaultSource", ctypes.c_short),
            ("dmPrintQuality", ctypes.c_short),
            ("dmColor", ctypes.c_short),
            ("dmDuplex", ctypes.c_short),
            ("dmYResolution", ctypes.c_short),
            ("dmTTOption", ctypes.c_short),
            ("dmCollate", ctypes.c_short),
            ("dmFormName", ctypes.c_wchar * 32),
            ("dmLogPixels", ctypes.c_ushort),
            ("dmBitsPerPel", ctypes.c_ulong),
            ("dmPelsWidth", ctypes.c_ulong),
            ("dmPelsHeight", ctypes.c_ulong),
            ("dmDisplayFlags", ctypes.c_ulong),
            ("dmDisplayFrequency", ctypes.c_ulong),
            ("dmICMMethod", ctypes.c_ulong),
            ("dmICMIntent", ctypes.c_ulong),
            ("dmMediaType", ctypes.c_ulong),
            ("dmDitherType", ctypes.c_ulong),
            ("dmReserved1", ctypes.c_ulong),
            ("dmReserved2", ctypes.c_ulong),
            ("dmPanningWidth", ctypes.c_ulong),
            ("dmPanningHeight", ctypes.c_ulong)
        ]
    while True:
        devmode = DEVMODE()
        devmode.dmSize = ctypes.sizeof(DEVMODE)
        if user32.EnumDisplaySettingsW(None, i, ctypes.byref(devmode)):
            freq = int(devmode.dmDisplayFrequency)
            if freq > 1:  # Exclude invalid or duplicate 0/1 Hz
                rates.add(freq)
            i += 1
        else:
            break
    return sorted(rates)

def set_refresh_rate(target_rate):
    user32 = ctypes.windll.user32
    ENUM_CURRENT_SETTINGS = -1

    class DEVMODE(ctypes.Structure):
        _fields_ = [
            ("dmDeviceName", ctypes.c_wchar * 32),
            ("dmSpecVersion", ctypes.c_ushort),
            ("dmDriverVersion", ctypes.c_ushort),
            ("dmSize", ctypes.c_ushort),
            ("dmDriverExtra", ctypes.c_ushort),
            ("dmFields", ctypes.c_ulong),
            ("dmOrientation", ctypes.c_short),
            ("dmPaperSize", ctypes.c_short),
            ("dmPaperLength", ctypes.c_short),
            ("dmPaperWidth", ctypes.c_short),
            ("dmScale", ctypes.c_short),
            ("dmCopies", ctypes.c_short),
            ("dmDefaultSource", ctypes.c_short),
            ("dmPrintQuality", ctypes.c_short),
            ("dmColor", ctypes.c_short),
            ("dmDuplex", ctypes.c_short),
            ("dmYResolution", ctypes.c_short),
            ("dmTTOption", ctypes.c_short),
            ("dmCollate", ctypes.c_short),
            ("dmFormName", ctypes.c_wchar * 32),
            ("dmLogPixels", ctypes.c_ushort),
            ("dmBitsPerPel", ctypes.c_ulong),
            ("dmPelsWidth", ctypes.c_ulong),
            ("dmPelsHeight", ctypes.c_ulong),
            ("dmDisplayFlags", ctypes.c_ulong),
            ("dmDisplayFrequency", ctypes.c_ulong),
            ("dmICMMethod", ctypes.c_ulong),
            ("dmICMIntent", ctypes.c_ulong),
            ("dmMediaType", ctypes.c_ulong),
            ("dmDitherType", ctypes.c_ulong),
            ("dmReserved1", ctypes.c_ulong),
            ("dmReserved2", ctypes.c_ulong),
            ("dmPanningWidth", ctypes.c_ulong),
            ("dmPanningHeight", ctypes.c_ulong)
        ]
    devmode = DEVMODE()
    devmode.dmSize = ctypes.sizeof(DEVMODE)
    if not user32.EnumDisplaySettingsW(None, ENUM_CURRENT_SETTINGS, ctypes.byref(devmode)):
        print("Failed to get current display settings")
        return False
    devmode.dmFields = 0x400000  # DM_DISPLAYFREQUENCY
    devmode.dmDisplayFrequency = target_rate
    result = user32.ChangeDisplaySettingsW(ctypes.byref(devmode), 0)
    if result == 0:
        print(f"Switched to {target_rate} Hz")
        return True
    else:
        print(f"Failed to switch refresh rate, error code: {result}")
        return False

if __name__ == "__main__":
    rates = get_supported_refresh_rates()
    if not rates:
        print("No refresh rates detected.")
        sys.exit(1)
    ac_status = get_power_status()
    if ac_status == 0:
        # Battery
        print("Running on battery, switching to lowest refresh rate.")
        set_refresh_rate(min(rates))
    elif ac_status == 1:
        # AC
        print("Running on AC, switching to highest refresh rate.")
        set_refresh_rate(max(rates))
    else:
        print("Unknown power status. No action taken.")