module dlangui.platforms.console.consoleapp;

import dlangui.core.logger;
import dlangui.platforms.common.platform;
import dlangui.graphics.drawbuf;
import dlangui.graphics.fonts;
import dlangui.widgets.styles;
import dlangui.platforms.console.consolefont;
private import dcons.dconsole;

class ConsoleWindow : Window {
    ConsolePlatform _platform;
    ConsoleWindow _parent;
    this(ConsolePlatform platform, dstring caption, Window parent, uint flags) {
        _platform = platform;
        _parent = cast(ConsoleWindow)parent;
        _dx = _platform.console.width;
        _dy = _platform.console.height;
        backgroundColor = 0x808080;
    }
    /// show window
    override void show() {
        _visible = true;
    }
    private dstring _windowCaption;
    /// returns window caption
    override @property dstring windowCaption() {
        return _windowCaption;
    }
    /// sets window caption
    override @property void windowCaption(dstring caption) {
        _windowCaption = caption;
    }
    /// sets window icon
    override @property void windowIcon(DrawBufRef icon) {
        // ignore
    }
    /// request window redraw
    override void invalidate() {
        _platform.update();
    }
    /// close window
    override void close() {
        Log.d("ConsoleWindow.close()");
        _platform.closeWindow(this);
    }
    protected bool _visible;
    /// returns true if window is shown
    @property bool visible() {
        return _visible;
    }
}

class ConsolePlatform : Platform {
    protected Console _console;

    @property Console console() { return _console; }

    protected ConsoleDrawBuf _drawBuf;
    this() {
        _console = new Console();
        _console.batchMode = true;
        _console.keyEvent = &onConsoleKey;
        _console.mouseEvent = &onConsoleMouse;
        _console.resizeEvent = &onConsoleResize;
        _console.inputIdleEvent = &onInputIdle;
        _console.init();
        _drawBuf = new ConsoleDrawBuf(_console);
    }

    ConsoleWindow[] _windowList;

    /**
    * create window
    * Args:
    *         windowCaption = window caption text
    *         parent = parent Window, or null if no parent
    *         flags = WindowFlag bit set, combination of Resizable, Modal, Fullscreen
    *      width = window width 
    *      height = window height
    * 
    * Window w/o Resizable nor Fullscreen will be created with size based on measurement of its content widget
    */
    override Window createWindow(dstring windowCaption, Window parent, uint flags = WindowFlag.Resizable, uint width = 0, uint height = 0) {
        ConsoleWindow res = new ConsoleWindow(this, windowCaption, parent, flags);
        _windowList ~= res;
        return res;
    }


    ConsoleWindow activeWindow() {
        if (!_windowList.length)
            return null;
        return _windowList[$ - 1];
    }

    @property DrawBuf drawBuf() { return _drawBuf; }
    protected bool onConsoleKey(KeyEvent event) {
        auto w = activeWindow;
        if (!w)
            return false;
        if (w.dispatchKeyEvent(event)) {
            _needRedraw = true;
            return true;
        }
        return false;
    }

    protected bool onConsoleMouse(MouseEvent event) {
        auto w = activeWindow;
        if (!w)
            return false;
        if (w.dispatchMouseEvent(event)) {
            _needRedraw = true;
            return true;
        }
        return false;
    }

    protected bool onConsoleResize(int width, int height) {
        foreach(w; _windowList) {
            w.onResize(width, height);
        }
        return false;
    }

    protected bool _needRedraw = true;
    void update() {
        _needRedraw = true;
    }

    protected void redraw() {
        if (!_needRedraw)
            return;
        foreach(w; _windowList) {
            if (w.visible) {
                _drawBuf.fillRect(Rect(0, 0, w.width, w.height), w.backgroundColor);
                w.onDraw(_drawBuf);
            }
        }
        _needRedraw = false;
    }
    protected bool onInputIdle() {
        redraw();
        _console.flush();
        return false;
    }

    /**
    * close window
    * 
    * Closes window earlier created with createWindow()
    */
    override void closeWindow(Window w) {
        for (int i = 0; i < _windowList.length; i++) {
            if (_windowList[i] is w) {
                for (int j = i; j + 1 < _windowList.length; j++)
                    _windowList[j] = _windowList[j + 1];
                _windowList[$ - 1] = null;
                _windowList.length--;
                destroy(w);
                return;
            }
        }
    }
    /**
    * Starts application message loop.
    * 
    * When returned from this method, application is shutting down.
    */
    override int enterMessageLoop() {
        while (_console.pollInput()) {
            if (_windowList.length == 0)
                break;
        }
        // TODO
        return 0;
    }
    private dstring _clipboardText;
    /// retrieves text from clipboard (when mouseBuffer == true, use mouse selection clipboard - under linux)
    override dstring getClipboardText(bool mouseBuffer = false) {
        return _clipboardText;
    }
    /// sets text to clipboard (when mouseBuffer == true, use mouse selection clipboard - under linux)
    override void setClipboardText(dstring text, bool mouseBuffer = false) {
        _clipboardText = text;
    }

    /// calls request layout for all windows
    override void requestLayout() {
        // TODO
    }
}

/// drawing buffer - image container which allows to perform some drawing operations
class ConsoleDrawBuf : DrawBuf {

    protected Console _console;
    @property Console console() { return _console; }

    this(Console console) {
        _console = console;
        resetClipping();
    }

    ~this() {
    }

    /// returns current width
    override @property int width() { return _console.width; }
    /// returns current height
    override @property int height() { return _console.height; }

    /// reserved for hardware-accelerated drawing - begins drawing batch
    override void beforeDrawing() {
        // TODO?
    }
    /// reserved for hardware-accelerated drawing - ends drawing batch
    override void afterDrawing() { 
        // TODO?
    }
    /// returns buffer bits per pixel
    override @property int bpp() { return 4; }
    // returns pointer to ARGB scanline, null if y is out of range or buffer doesn't provide access to its memory
    //uint * scanLine(int y) { return null; }
    /// resize buffer
    override void resize(int width, int height) {
        // IGNORE
    }

    //========================================================
    // Drawing methods.

    /// fill the whole buffer with solid color (no clipping applied)
    override void fill(uint color) {
        // TODO
        Log.d("fill");
    }

    private struct RGB {
        int r;
        int g;
        int b;
        int match(int rr, int gg, int bb) immutable {
            int dr = rr - r;
            int dg = gg - g;
            int db = bb - b;
            if (dr < 0) dr = -dr;
            if (dg < 0) dg = -dg;
            if (db < 0) db = -db;
            return dr + dg + db;
        }
    }
    static immutable RGB CONSOLE_COLORS_RGB[16] = [
        RGB(0,0,0),
        RGB(0,0,128),
        RGB(0,128,0),
        RGB(0,128,128),
        RGB(128,0,0),
        RGB(128,0,128),
        RGB(128,128,0),
        RGB(128,128,128),
        RGB(192,192,192),
        RGB(0,0,255),
        RGB(0,255,0),
        RGB(0,255,255),
        RGB(255,0,0),
        RGB(255,0,255),
        RGB(255,255,0),
        RGB(255,255,255),
    ];

    static ubyte toConsoleColor(uint color) {
        int r = (color >> 16) & 0xFF;
        int g = (color >> 8) & 0xFF;
        int b = (color >> 0) & 0xFF;
        int bestMatch = CONSOLE_COLORS_RGB[0].match(r,g,b);
        int bestMatchIndex = 0;
        for (int i = 1; i < 16; i++) {
            int m = CONSOLE_COLORS_RGB[i].match(r,g,b);
            if (m < bestMatch) {
                bestMatch = m;
                bestMatchIndex = i;
            }
        }
        return cast(ubyte)bestMatchIndex;
    }


    static immutable dstring SPACE_STRING = 
        "                                                                                                    "
        "                                                                                                    "
        "                                                                                                    "
        "                                                                                                    "
        "                                                                                                    ";

    /// fill rectangle with solid color (clipping is applied)
    override void fillRect(Rect rc, uint color) {
        // TODO
        Log.d("fillRect");
        uint alpha = color >> 24;
        if (alpha >= 128)
            return; // transparent
        _console.backgroundColor = toConsoleColor(color);
        if (applyClipping(rc)) {
            int w = rc.width;
            foreach(y; rc.top .. rc.bottom) {
                _console.setCursor(rc.left, y);
                _console.writeText(SPACE_STRING[0 .. w]);
            }
        }
    }

    /// fill rectangle with solid color and pattern (clipping is applied) 0=solid fill, 1 = dotted
    override void fillRectPattern(Rect rc, uint color, int pattern) {
        // default implementation: does not support patterns
        fillRect(rc, color);
    }

    /// draw pixel at (x, y) with specified color 
    override void drawPixel(int x, int y, uint color) {
        // TODO
    }

    /// draw 8bit alpha image - usually font glyph using specified color (clipping is applied)
    override void drawGlyph(int x, int y, Glyph * glyph, uint color) {
        // TODO
    }

    /// draw source buffer rectangle contents to destination buffer
    override void drawFragment(int x, int y, DrawBuf src, Rect srcrect) {
        // not supported
    }

    /// draw source buffer rectangle contents to destination buffer rectangle applying rescaling
    override void drawRescaled(Rect dstrect, DrawBuf src, Rect srcrect) {
        // not supported
    }

    override void clear() {
        resetClipping();
    }
}

// entry point for console app
extern(C) int DLANGUImain(string[] args) {
    initLogs();
    Platform.setInstance(new ConsolePlatform());
    FontManager.instance = new ConsoleFontManager();
    initResourceManagers();

    currentTheme = createDefaultTheme();
    Log.i("Entering UIAppMain: ", args);
    int result = -1;
    try {
        result = UIAppMain(args);
        Log.i("UIAppMain returned ", result);
    } catch (Exception e) {
        Log.e("Abnormal UIAppMain termination");
        Log.e("UIAppMain exception: ", e);
    }

    releaseResourcesOnAppExit();

    Log.d("Exiting main");

    return result;
}
