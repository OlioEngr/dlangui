// Written in the D programming language.

/**
This module is just to simplify import of most useful DLANGUI modules.

Synopsis:

----
// helloworld
import dlangui.all;
// required in one of modules
mixin APP_ENTRY_POINT;

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {
    // resource directory search paths
    string[] resourceDirs = [
        appendPath(exePath, "../../../res/"),   // for Visual D and DUB builds
        appendPath(exePath, "../../../../res/"), // for Mono-D builds
        appendPath(exePath, "res/") // when res dir is located at the same directory as executable
    ];

    // setup resource directories - will use only existing directories
	Platform.instance.resourceDirs = resourceDirs;
    // select translation file - for english language
	Platform.instance.uiLanguage = "en";
	// load theme from file "theme_default.xml"
	Platform.instance.uiTheme = "theme_default";

    // create window
    Window window = Platform.instance.createWindow("My Window", null);
    // create some widget to show in window
    window.mainWidget = (new Button()).text("Hello world"d);
    // show window
    window.show();
    // run message loop
    return Platform.instance.enterMessageLoop();
}


----

Copyright: Vadim Lopatin, 2014
License:   Boost License 1.0
Authors:   Vadim Lopatin, coolreader.org@gmail.com
 */
module dlangui.all;

public import dlangui.core.logger;
public import dlangui.core.types;
public import dlangui.platforms.common.platform;
public import dlangui.graphics.images;
public import dlangui.widgets.widget;
public import dlangui.widgets.controls;
public import dlangui.widgets.layouts;
public import dlangui.widgets.lists;
public import dlangui.widgets.tabs;
public import dlangui.widgets.menu;
public import dlangui.widgets.editors;
public import dlangui.graphics.fonts;
public import dlangui.core.i18n;
