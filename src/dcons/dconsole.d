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

struct ConsoleChar {
    dchar ch;
    uint  attr = 0xFFFFFFFF;
}

immutable ConsoleChar UNKNOWN_CHAR = ConsoleChar.init;

struct ConsoleBuf {
    protected int _width;
    protected int _height;
    protected int _cursorX;
    protected int _cursorY;
    protected ConsoleChar[] _chars;


    @property int width() { return _width; }
    @property int height() { return _height; }
    @property int cursorX() { return _cursorX; }
    @property int cursorY() { return _cursorY; }

    void clear(ConsoleChar ch) {
        _chars[0 .. $] = ch;
    }
    void copyFrom(ref ConsoleBuf buf) {
        _width = buf._width;
        _height = buf._height;
        _cursorX = buf._cursorX;
        _cursorY = buf._cursorY;
        _chars.length = buf._chars.length;
        for(int i = 0; i < _chars.length; i++)
            _chars[i] = buf._chars[i];
    }
    void set(int x, int y, ConsoleChar ch) {
        _chars[y * _width + x] = ch;
    }
    ConsoleChar get(int x, int y) {
        return _chars[y * _width + x];
    }
    ConsoleChar[] line(int y) {
        return _chars[y * _width .. (y + 1) * _width];
    }
    void resize(int w, int h) {
        if (_width != w || _height != h) {
            _chars.length = w * h;
            _width = w;
            _height = h;
        }
        _cursorX = 0;
        _cursorY = 0;
        _chars[0 .. $] = UNKNOWN_CHAR;
    }
    void scrollUp(uint attr) {
        for (int i = 0; i + 1 < _height; i++) {
            _chars[i * _width .. (i + 1) * _width] = _chars[(i + 1) * _width .. (i + 2) * _width];
        }
        _chars[(_height - 1) * _width .. _height * _width] = ConsoleChar(' ', attr);
    }
    void setCursor(int x, int y) {
        _cursorX = x;
        _cursorY = y;
    }
    void writeChar(dchar ch, uint attr) {
        if (_cursorX >= _width) {
            _cursorY++;
            _cursorX = 0;
            if (_cursorY >= _height) {
                _cursorY = _height - 1;
                scrollUp(attr);
            }
        }
        if (ch == '\n') {
            _cursorX = 0;
            _cursorY++;
            if (_cursorY >= _height) {
                scrollUp(attr);
                _cursorY = _height - 1;
            }
            return;
        }
        if (ch == '\r') {
            _cursorX = 0;
            return;
        }
        set(_cursorX, _cursorY, ConsoleChar(ch, attr));
        _cursorX++;
        if (_cursorX >= _width) {
            if (_cursorY < _height - 1) {
                _cursorY++;
                _cursorX = 0;
            }
        }
    }
    void write(dstring str, uint attr) {
        for (int i = 0; i < str.length; i++) {
            writeChar(str[i], attr);
        }
    }
}

/// console I/O support
class Console {
    private int _cursorX;
    private int _cursorY;
    private int _width;
    private int _height;

    private ConsoleBuf _buf;
    private ConsoleBuf _batchBuf;
    private uint _consoleAttr;

    @property int width() { return _width; }
    @property int height() { return _height; }
    @property int cursorX() { return _cursorX; }
    @property int cursorY() { return _cursorY; }
    @property void cursorX(int x) { _cursorX = x; }
    @property void cursorY(int y) { _cursorY = y; }

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
        } else {
        }
        _buf.resize(_width, _height);
        _batchBuf.resize(_width, _height);
        return true;
    }

    /// clear screen and set cursor position to 0,0
    void clearScreen() {
        calcAttributes();
        if (!_batchMode) {
            _buf.clear(ConsoleChar(' ', _consoleAttr));
            version(Windows) {
                DWORD charsWritten;
                FillConsoleOutputCharacter(_hstdout, ' ', _width * _height, COORD(0, 0), &charsWritten);
                FillConsoleOutputAttribute(_hstdout, _attr, _width * _height, COORD(0, 0), &charsWritten);
            } else {
            }
        } else {
            _batchBuf.clear(ConsoleChar(' ', _consoleAttr));
        }
        setCursor(0, 0);
    }


    /// set cursor position
    void setCursor(int x, int y) {
        if (!_batchMode) {
            _buf.setCursor(x, y);
            rawSetCursor(x, y);
        } else {
            _batchBuf.setCursor(x, y);
        }
        _cursorX = x;
        _cursorY = y;
    }

    /// flush batched updates
    void flush() {
        if (_batchMode) {
            for (int i = 0; i < _batchBuf.height; i++) {
                ConsoleChar[] batchLine = _batchBuf.line(i);
                ConsoleChar[] bufLine = _buf.line(i);
                for (int x = 0; x < _batchBuf.width; x++) {
                    if (batchLine[x] != ConsoleChar.init && batchLine[x] != bufLine[x]) {
                        // found non-empty sequence
                        int xx = 1;
                        dchar[] str;
                        str ~= batchLine[x].ch;
                        bufLine[x] = batchLine[x];
                        uint firstAttr = batchLine[x].attr;
                        for ( ; x + xx < _batchBuf.width; xx++) {
                            if (batchLine[x + xx] == ConsoleChar.init || batchLine[x + xx].attr != firstAttr)
                                break;
                            str ~= batchLine[x + xx].ch;
                            bufLine[x + xx] = batchLine[x + xx];
                        }
                        rawSetCursor(x, i);
                        rawSetAttributes(firstAttr);
                        rawWriteText(cast(dstring)str);
                        x += xx - 1;
                    }
                }
            }
            _batchBuf.clear(ConsoleChar.init);
            rawSetCursor(_cursorX, _cursorY);
        }
    }

    /// write text string
    void writeText(dstring str) {
        if (!str.length)
            return;
        updateAttributes();
        if (!_batchMode) {
            // no batch mode, write directly to screen
            _buf.write(str, _consoleAttr);
            rawWriteText(str);
            _cursorX = _buf.cursorX;
            _cursorY = _buf.cursorY;
        } else {
            // batch mode
            _batchBuf.write(str, _consoleAttr);
            _cursorX = _batchBuf.cursorX;
            _cursorY = _batchBuf.cursorY;
        }
    }

    protected void rawSetCursor(int x, int y) {
        version(Windows) {
            SetConsoleCursorPosition(_hstdout, COORD(cast(short)x, cast(short)y));
        } else {
        }
    }

    protected void rawWriteText(dstring str) {
        version(Windows) {
            import std.utf;
            wstring s16 = toUTF16(str);
            DWORD charsWritten;
            WriteConsole(_hstdout, s16.ptr, s16.length, &charsWritten, null);
        } else {
        }
    }

    protected void rawSetAttributes(uint attr) {
        version(Windows) {
            WORD newattr = cast(WORD) (
                (attr & 0x0F)
                | (((attr >> 8) & 0x0F) << 4)
                | (((attr >> 16) & 1) ? COMMON_LVB_UNDERSCORE : 0)
            );
            if (newattr != _attr) {
                _attr = newattr;
                SetConsoleTextAttribute(_hstdout, _attr);
            }
        } else {
        }
    }

    protected void calcAttributes() {
        _consoleAttr = cast(uint)_textColor | (cast(uint)_backgroundColor << 8) | (_underline ? 0x10000 : 0);
        version(Windows) {
            _attr = cast(WORD) (
                _textColor
                | (_backgroundColor << 4)
                | (_underline ? COMMON_LVB_UNDERSCORE : 0)
            );
        } else {
        }
    }

    protected void updateAttributes() {
        if (_dirtyAttributes) {
            version(Windows) {
                calcAttributes();
                SetConsoleTextAttribute(_hstdout, _attr);
            } else {
            }
            _dirtyAttributes = false;
        }
    }

    protected bool _batchMode;
    @property bool batchMode() { return _batchMode; }
    @property void batchMode(bool batch) { 
        if (_batchMode == batch)
            return;
        if (batch) {
            // batch mode turned ON
            _batchBuf.clear(ConsoleChar.init);
            _batchMode = true;
        } else {
            // batch mode turned OFF
            flush();
            _batchMode = false;
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
