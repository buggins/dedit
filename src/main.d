import std.stdio;
import dcons.dconsole;
//version = DCONSOLE_TEST;

version (DCONSOLE_TEST) {
    int main(string[] argv)
    {
		import dlangui.core.logger;
		import dlangui.core.events;
		import std.utf;
		Log.setFileLogger(new File("dconsole.log", "w"));
		Log.setLogLevel(LogLevel.Trace);
		writeln("Hello D-World!");
        Console console = new Console();
        if (!console.init()) {
            writeln("Not in console");
            return 1;
        }
		console.keyEvent = delegate(KeyEvent event) {
			Log.d(event);
			console.setCursor(2, 2);
			console.writeText(toUTF32(event.toString ~ "               "));
			console.flush();
			return true;
		};
		console.mouseEvent = delegate(MouseEvent event) {
			Log.d(event);
			console.setCursor(2, 3);
			console.writeText(toUTF32(event.toString ~ "               "));
			console.flush();
			return true;
		};
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
        console.setCursor(2, 12);
        console.writeText("yet another text line");
        console.setCursor(10, 10);
        console.writeText("T");
        console.flush();
        console.textColor = TextColor.WHITE;
        console.setCursor(14, 14);
        console.writeText("one more text line #14");
        console.setCursor(14, 15);
        console.writeText("one more text line #15");

		for (ubyte tc = 0; tc < 16; tc++) {
			for (ubyte bc = 0; bc < 16; bc++) {
				console.setCursor(40 + tc*2, 5 + bc);
				console.textColor = tc;
				console.backgroundColor = bc;
				console.writeText("AA");
			}
		}
		console.backgroundColor = 0;
		console.textColor = 7;

        console.flush();
        while (console.pollInput()) {
        }
        //readln();
        return 0;
    }
} else {

    import dlangui.platforms.common.platform;
    import dlangui.platforms.common.startup;
    import dlangui.widgets.widget;
    import dlangui.widgets.controls;
    import dlangui.widgets.layouts;
    import dlangui.widgets.editors;

    mixin APP_ENTRY_POINT;

    /// entry point for dlangui based application
    extern (C) int UIAppMain(string[] args) {
        // create window
        Log.setLogLevel(LogLevel.Trace);
        Log.d("Creating window");
        if (!Platform.instance) {
            Log.e("Platform.instance is null!!!");
        }
        Window window = Platform.instance.createWindow("DlangUI example - HelloWorld", null);
        Log.d("Window created");

        VerticalLayout layout = new VerticalLayout();
        layout.margins = 2;
        layout.backgroundColor = 0x800000;
        layout.addChild(new TextWidget(null, "Some text string"d).backgroundColor(0x000080).textColor(0xFFFFFF));
        layout.addChild(new TextWidget(null, "One another text string"d).backgroundColor(0x008000).textColor(0xC0C0C0));
        layout.addChild(new TextWidget(null, "Third text string"d));
        layout.addChild(new Button("btn1", "Button1"d));
        layout.addChild(new Button("btn2", "Button2"d));
        layout.addChild(new Button("btn3", "Button3"d));
        layout.addChild(new EditLine("ed1", "Some text"d).backgroundColor(0x800080));
        layout.childById("btn1").click = delegate(Widget w) {
            Log.d("Button btn1 is pressed");
            return true; 
        };
        window.mainWidget = layout;

        // show window
        window.show();

        // run message loop
        return Platform.instance.enterMessageLoop();
    }

}
