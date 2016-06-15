//
//  AppDelegate.m
//  TrueRetina
//
//  Created by Adrian Kemp on 2015-04-08.
//  Copyright (c) 2015 Adrian Kemp (http://adriankemp.com/).
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  Contributors:
//  Adrian Kemp (http://adriankemp.com/)
//

#import "AppDelegate.h"
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

CGDisplayModeRef findDisplayMode(CGFloat width, CGFloat height, CGDirectDisplayID display);

@interface AppDelegate ()

@property (nonatomic, strong) NSStatusItem *menuBarItem;
@property (nonatomic, strong) NSWindowController *resolutionSelectionWindowController;
@property (nonatomic, strong) IBOutlet NSMenu *resolutionMenu;

@end

void findNativeDisplayMode(const void *displayMode, void *nativeDisplayMode) {
    uint32_t ioFlags = CGDisplayModeGetIOFlags(((CGDisplayModeRef)displayMode));
    if (ioFlags & kDisplayModeNativeFlag) {
        *((CGDisplayModeRef *)nativeDisplayMode) = ((CGDisplayModeRef)displayMode);
    }
}


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.menuBarItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];

    self.menuBarItem.image = [NSImage imageNamed:@"TrueRetina"];
    
    NSMenu *menu = [[NSMenu alloc] init];
    NSMenuItem *retinaMenuItem = [menu addItemWithTitle:@"Retina" action:@selector(setRetina:) keyEquivalent:@""];
    [menu addItemWithTitle:@"Standard" action:@selector(setStandard:) keyEquivalent:@""];
    [menu addItem:[NSMenuItem separatorItem]]; // A thin grey line
    [menu addItemWithTitle:@"Quit TrueRetina" action:@selector(terminate:) keyEquivalent:@""];
    self.menuBarItem.menu = menu;
    
    [self setRetina:retinaMenuItem];
}

- (IBAction)setRetina:(NSMenuItem *)sender {
    for (NSMenuItem *menuItem in sender.menu.itemArray) {
        menuItem.state = 0;
    };
    [sender setState:1];
    CGDirectDisplayID mainDisplay = CGMainDisplayID();
    CFArrayRef availableModes = CGDisplayCopyAllDisplayModes(mainDisplay, NULL);
    CFIndex availableModeCount = CFArrayGetCount(availableModes);
    CGDisplayModeRef nativeDisplayMode;
    CFArrayApplyFunction(availableModes, CFRangeMake(0, availableModeCount), findNativeDisplayMode , &nativeDisplayMode);
    
    CGDisplayConfigRef displayConfig;
    if (CGBeginDisplayConfiguration(&displayConfig) == kCGErrorSuccess) {
        CGConfigureDisplayWithDisplayMode(displayConfig, mainDisplay, nativeDisplayMode, NULL);
        CGCompleteDisplayConfiguration(displayConfig, kCGConfigureForSession);
    }
}

- (IBAction)setStandard:(NSMenuItem *)sender {
    for (NSMenuItem *menuItem in sender.menu.itemArray) {
        menuItem.state = 0;
    };
    [sender setState:1];
    CGRestorePermanentDisplayConfiguration();
}

@end

