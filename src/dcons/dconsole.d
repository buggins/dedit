module dcons.dconsole;

import std.stdio;

version(Windows) {
    import core.sys.windows.winbase;
    import core.sys.windows.wincon;
    import core.sys.windows.winuser;
    private import core.sys.windows.basetyps, core.sys.windows.w32api, core.sys.windows.winnt;
}

enum TextColor : ubyte {
    BLACK,          // 0
    BLUE,
    GREEN,
    CYAN,
    RED,
    MAGENTA,
    YELLOW,
    GREY,
    DARK_GREY,      // 8
    LIGHT_BLUE,
    LIGHT_GREEN,
    LIGHT_CYAN,
    LIGHT_RED,
    LIGHT_MAGENTA,
    LIGHT_YELLOW,
    WHITE,          // 15
}

/// console I/O support
class Console {
    private int _cursorX;
    private int _cursorY;
    private int _width;
    private int _height;

    @property int width() { return _width; }
    @property int height() { return _height; }
    @property int cursorX() { return _cursorX; }
    @property int cursorY() { return _cursorY; }

    version(Windows) {
        HANDLE _hstdin;
        HANDLE _hstdout;
        WORD _attr;
        immutable ushort COMMON_LVB_UNDERSCORE = 0x8000;
    }

    bool init() {
        version(Windows) {
            _hstdin = GetStdHandle(STD_INPUT_HANDLE);
            if (_hstdin == INVALID_HANDLE_VALUE)
                return false;
            _hstdout = GetStdHandle(STD_OUTPUT_HANDLE);
            if (_hstdout == INVALID_HANDLE_VALUE)
                return false;
            CONSOLE_SCREEN_BUFFER_INFO csbi;
            if (!GetConsoleScreenBufferInfo(_hstdout, &csbi))
            {
                //printf( "GetConsoleScreenBufferInfo failed: %lu\n", GetLastError());
                return false;
            }
            _cursorX = csbi.dwCursorPosition.X;
            _cursorY = csbi.dwCursorPosition.Y;
            _width = csbi.srWindow.Right - csbi.srWindow.Left + 1; // csbi.dwSize.X;
            _height = csbi.srWindow.Bottom - csbi.srWindow.Top + 1; // csbi.dwSize.Y;
            _attr = csbi.wAttributes;
            _textColor = _attr & 0x0F;
            _backgroundColor = (_attr & 0xF0) >> 4;
            _underline = (_attr & COMMON_LVB_UNDERSCORE) != 0;
            //writeln("csbi=", csbi);
            return true;
        } else {
        }
    }

    /// clear screen and set cursor position to 0,0
    void clearScreen() {
        version(Windows) {
        } else {
        }
    }

    /// set cursor position
    void setCursor(int x, int y) {
        version(Windows) {
            SetConsoleCursorPosition(_hstdout, COORD(cast(short)x, cast(short)y));
            _cursorX = x;
            _cursorY = y;
        } else {
        }
    }

    /// write text string
    void writeText(dstring str) {
        if (!str.length)
            return;
        updateAttributes();
        version(Windows) {
            import std.utf;
            wstring s16 = toUTF16(str);
            DWORD charsWritten;
            WriteConsole(_hstdout, s16.ptr, s16.length, &charsWritten, null);
            _cursorX += s16.length;
            while(_cursorX >= _width) {
                _cursorX -= _width;
                _cursorY++;
                if (_cursorY >= _height)
                    _cursorY = _height - 1;
            }
        } else {
        }
    }

    protected void updateAttributes() {
        if (_dirtyAttributes) {
            version(Windows) {
                _attr = cast(WORD) (
                    _textColor
                    | (_backgroundColor << 4)
                    | (_underline ? COMMON_LVB_UNDERSCORE : 0)
                );
                SetConsoleTextAttribute(_hstdout, _attr);
            } else {
            }
            _dirtyAttributes = false;
        }
    }

    protected bool _dirtyAttributes;
    protected ubyte _textColor;
    protected ubyte _backgroundColor;
    protected bool _underline;
    /// get underline text attribute flag
    @property bool underline() { return _underline; }
    /// set underline text attrubute flag
    @property void underline(bool flg) {
        if (flg != _underline) {
            _underline = flg;
            _dirtyAttributes = true;
        }
    }
    /// get text color
    @property ubyte textColor() { return _textColor; }
    /// set text color
    @property void textColor(ubyte color) { 
        if (_textColor != color) {
            _textColor = color; 
            _dirtyAttributes = true;
        }
    }
    /// get background color
    @property ubyte backgroundColor() { return _backgroundColor; }
    /// set background color
    @property void backgroundColor(ubyte color) {
        if (_backgroundColor != color) {
            _backgroundColor = color;
            _dirtyAttributes = true;
        }
    }
}
