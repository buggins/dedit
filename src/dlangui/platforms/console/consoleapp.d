module dlangui.platforms.console.consoleapp;

import dlangui.platforms.common.platform;
import dlangui.graphics.drawbuf;
private import dcons.dconsole;

class ConsoleWindow : Window {
    ConsolePlatform _platform;
    this(ConsolePlatform platform) {
        _platform = platform;
    }
    /// show window
    override void show() {
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
        // TODO
    }
    /// close window
    override void close() {
        // TODO
    }
}

class ConsolePlatform : Platform {
    protected Console _console;
    protected ConsoleDrawBuf _drawBuf;
    this() {
        _console = new Console();
        _console.keyEvent = &onConsoleKey;
        _console.mouseEvent = &onConsoleMouse;
        _console.resizeEvent = &onConsoleResize;
        _console.init();
        _drawBuf = new ConsoleDrawBuf(_console);
    }
    @property DrawBuf drawBuf() { return _drawBuf; }
    protected bool onConsoleKey(KeyEvent event) {
        return false;
    }
    protected bool onConsoleMouse(MouseEvent event) {
        return false;
    }
    protected bool onConsoleResize(int width, int height) {
        return false;
    }

    /**
    * close window
    * 
    * Closes window earlier created with createWindow()
    */
    override void closeWindow(Window w) {
        // TODO
    }
    /**
    * Starts application message loop.
    * 
    * When returned from this method, application is shutting down.
    */
    override int enterMessageLoop() {
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

    Console _console;

    this(Console console) {
        _console = console;
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
    }

    /// fill rectangle with solid color (clipping is applied)
    override void fillRect(Rect rc, uint color) {
        // TODO
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

