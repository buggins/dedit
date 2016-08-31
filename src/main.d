import std.stdio;
import dcons.dconsole;

int main(string[] argv)
{
    writeln("Hello D-World!");
    Console console = new Console();
    if (!console.init()) {
        writeln("Not in console");
        return 1;
    }
    writeln("In console: width=", console.width, " height=", console.height);
    console.setCursor(10, 10);
    console.textColor = TextColor.MAGENTA;
    console.underline = true;
    console.writeText("Text");
    console.backgroundColor = TextColor.DARK_GREY;
    console.textColor = TextColor.CYAN;
    console.writeText(" in ");
    console.backgroundColor = TextColor.BLACK;
    console.writeText("console");
    readln();
    return 0;
}
