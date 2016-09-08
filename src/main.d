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

        import dlangui.platforms.console.consoleapp;
        import dlangui.graphics.resources;
        import dlangui.core.types;
        ConsoleDrawBuf drawBuf = new ConsoleDrawBuf(console);
        TextDrawable d = new TextDrawable(q{
            {
                text: ["╔═╗",
                       "║ ║",
                       "╚═╝"],
                backgroundColor: [0x000080],
                textColor: [0xFF0000],
                ninepatch: [1,1,1,1]
            }
        });
        d.drawTo(drawBuf, Rect(3, 5, 12, 10));
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
    import dlangui.widgets.lists;
    import dlangui.widgets.menu;

    mixin APP_ENTRY_POINT;

    /// entry point for dlangui based application
    extern (C) int UIAppMain(string[] args) {
        // create window
        Log.setLogLevel(LogLevel.Trace);
        Log.d("Creating window");
        if (!Platform.instance) {
            Log.e("Platform.instance is null!!!");
        }

        // load theme from file "theme_default.xml"
        Platform.instance.uiTheme = "theme_default";

        Window window = Platform.instance.createWindow("DlangUI example - HelloWorld", null);
        Log.d("Window created");

        VerticalLayout layout = new VerticalLayout();
        //layout.margins = 2;
        layout.backgroundColor = 0x000000;

        MenuItem mainMenuItems = new MenuItem();
        MenuItem fileItem = new MenuItem(new Action(1, "File"d));
        fileItem.add(new Action(2, "Open"d, "document-open", KeyCode.KEY_O, KeyFlag.Control));
        fileItem.add(new Action(3, "Save"d, "document-save", KeyCode.KEY_S, KeyFlag.Control));
        mainMenuItems.add(fileItem);
        MainMenu mainMenu = new MainMenu(mainMenuItems);
        layout.addChild(mainMenu);

        //layout.addChild(new TextWidget(null, "Some text string"d).backgroundColor(0x000080).textColor(0xFFFFFF));
       // layout.addChild(new TextWidget(null, "One another text string"d).backgroundColor(0x008000).textColor(0xC0C0C0));
        layout.addChild(new ScrollBar(null, Orientation.Horizontal));
        //layout.addChild(new TextWidget(null, "Third text string"d));
        layout.addChild(new StringListWidget(null, ["Item 1 is first"d, "Additional item 2"d, "Item #3"d, 
        "Item #4"d, "Item #5 bla bal blah"d, "Item #6"d, "Item #7"d, "Item #8 is last one"d]).minHeight(5).maxHeight(5).backgroundColor(0x000080));
        auto btnLayout = new HorizontalLayout();
        btnLayout.addChild(new Button("btn1", "Button1"d));
        btnLayout.addChild(new Button("btn2", "Button2"d));
        btnLayout.addChild(new Button("btn3", "Button3"d));
        layout.addChild(btnLayout);
        layout.addChild(new EditLine("ed1", "Some text"d));
        layout.addChild(new EditBox("ed2", "Text line 1\nText line 2\nText line 3"d).minHeight(10).backgroundColor(0x000080));
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
