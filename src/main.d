import std.stdio;
import dcons.dconsole;
//version = DCONSOLE_TEST

version (DCONSOLE_TEST) {
    int main(string[] argv)
    {
        writeln("Hello D-World!");
        Console console = new Console();
        if (!console.init()) {
            writeln("Not in console");
            return 1;
        }
        writeln("In console: width=", console.width, " height=", console.height);
        console.batchMode = true;
        console.textColor = TextColor.WHITE;
        console.backgroundColor = TextColor.BLACK;
        console.clearScreen();
        console.setCursor(10, 10);
        console.textColor = TextColor.MAGENTA;
        console.underline = true;
        console.writeText("Text");
        console.backgroundColor = TextColor.DARK_GREY;
        console.textColor = TextColor.CYAN;
        console.writeText(" in ");
        console.backgroundColor = TextColor.BLACK;
        console.writeText("console");
        console.setCursor(12, 12);
        console.writeText("yet another text line");
        console.setCursor(10, 10);
        console.writeText("T");
        console.flush();
        console.textColor = TextColor.WHITE;
        console.setCursor(14, 14);
        console.writeText("one more text line #14");
        console.setCursor(14, 15);
        console.writeText("one more text line #15");
        console.flush();
        while (console.pollInput()) {
        }
        readln();
        return 0;
    }
} else {

    import dlangui.platforms.common.platform;
    import dlangui.platforms.common.startup;
    import dlangui.widgets.widget;
    import dlangui.widgets.controls;
    import dlangui.widgets.layouts;

    mixin APP_ENTRY_POINT;

    /// entry point for dlangui based application
    extern (C) int UIAppMain(string[] args) {
        // create window
        Log.d("Creating window");
        if (!Platform.instance) {
            Log.e("Platform.instance is null!!!");
        }
        Window window = Platform.instance.createWindow("DlangUI example - HelloWorld", null);
        Log.d("Window created");

        VerticalLayout layout = new VerticalLayout();
        layout.addChild(new TextWidget(null, "Some text string"d));
        layout.addChild(new TextWidget(null, "One another text string"d).backgroundColor(0x008000));
        window.mainWidget = layout;

        // show window
        window.show();

        // run message loop
        return Platform.instance.enterMessageLoop();
    }

}
